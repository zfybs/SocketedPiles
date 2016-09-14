function [uw rw]=uwater(OriginalParameters,depthInWater,di,ro)
% 计算水中桩段的位移和转角。
% 索引：悬臂梁的挠度表达式：y=F*(x^2)*(3l-x)/(6EI)-ro.*x+di;  di为正表示位移向右，ro为负表示桩向右偏转。
%
% 输入参数
% OriginalParameters
% di,ro     海床底部的水平位移与转角， di为正表示位移向右，ro为负表示桩向右偏转。
% depthInWater  一个向量，uwater函数会返回此向量中指定深度处的位移与转角。
%               depthInWater的取值是在0到Zy之间,depthInWater=0表示桩顶，depthInWater=Zy表示屈服截面处。
% 输出参数
% uw    一个列向量，代表水平指定深度处的水平位移
% rw    一个列向量，代表水平指定深度处的转角
%
% see also: OriginalProjectParameters
%% 参数赋值
L=OriginalParameters.lw;
PTW=OriginalParameters.PileType_Water; %水中桩段的截面类型
H=OriginalParameters.H;
di=double(di);  % di为正表示位移向右
ro=-double(ro);  % 将ro的方向转换为桩向“右”偏转则为“正”。
n=length(depthInWater);
%% 悬臂梁中弯矩表达式：M=EIy"；
global considerYieldofPileInWater;   % 是否要考虑水中桩段在弯矩作用下的屈服，以及屈服后桩的刚度的减小
if considerYieldofPileInWater   
    % 首先确定会开裂的截面处的深度
    Lcr=PTW.Mcr/H;
    if Lcr>L  % 说明水中桩段全体都没有屈服
        EI=PTW.BendingStiffness(1);
        [uw,rw]=upperDisplacementRotation(0,H,di,ro,EI,L,L-depthInWater);
        return
    else  % 说明水中的桩也发生了屈服
        fprintf(2,['水中的桩也发生了屈服，屈服深度为：  ',num2str(Lcr),'\n'])
        % 由于桩下部的弯矩较大，因此在将水中桩段中的屈服区按1m分割为多个桩段
        nodes=(Lcr:1:L)';
        if nodes(end)~=L
            nodes=[nodes;L];  % 保证向量nodes中至少有两个元素，而且最后一个元素的值为l，即水中桩的底部。
        end
        bot_d=di;        % 最下面一小段的底部的位移，即嵌固端顶部的位移。
        bot_r=ro;          % 最下面一小段的底部的转角，即嵌固端顶部的转角。
        uw=zeros(n,1);
        rw=zeros(n,1);
        eleRemain=n;   % 要返回的位移与转角向量中，还未填充数据的元素个数
        for i=length(nodes)-1:-1:1  % 开始计算水中屈服区中的每一小段的位移分布
            bottom=nodes(i+1);  % 此段底部的深度，桩顶深度值为0；
            top=nodes(i);  %  此段顶部的深度，桩顶深度值为0.
            top_M=H*top;  % 此小段的顶部的弯矩值
            middle=(bottom+top)/2;     % 以此小段的中点的弯矩作为此小段的代表弯矩值
            EI=PTW.NewStiffness(H*middle);   % 在此小段桩的代表弯矩作用下，桩截面的新的抗弯刚度值。
            depths=depthInWater(depthInWater<=bottom & depthInWater>top);
            ndp=length(depths);   % 进行数据填充的元素的个数
            % 计算指定深度处的位移与转角
            [D,R]=upperDisplacementRotation(top_M,H,bot_d,bot_r,EI,bottom-top,bottom-depths);
            % 填充数据
            uw(eleRemain-ndp+1:eleRemain)=D;
            rw(eleRemain-ndp+1:eleRemain)=R;
            % 此小段的上面一段的底部位移边界，此此小段的顶部位移。
            [bot_d,bot_r]=upperDisplacementRotation(top_M,H,bot_d,bot_r,EI,bottom-top,bottom-top);
            %
            eleRemain=eleRemain-length(depths); % 还剩多少个元素未填充
        end
        % 水中未屈服区的位移与转角解
        depths=depthInWater(depthInWater<=Lcr & depthInWater>=0);
        EI=PTW.BendingStiffness(1);
        [D,R]=upperDisplacementRotation(0,H,bot_d,bot_r,EI,Lcr,Lcr-depths);
        % 填充数据
        uw(1:eleRemain)=D;
        rw(1:eleRemain)=R;
    end
else    % 不要考虑水中桩段在弯矩作用下的屈服，以及屈服后桩的刚度的减小，此时整个桩段按弹性悬臂梁计算即可。
    EI=PTW.BendingStiffness(1);
    [uw,rw]=upperDisplacementRotation(0,H,di,ro,EI,L,L-depthInWater);
    % 弹性解法二：
    %{ 
    % 位移表达式：y=F*(y^2)*(3l-x)/(6EI)+ro.*y+di;  di为正表示位移向右，ro为正表示桩向右偏转。
    deflection = @(y) H.*y.^2/6/EI.*(3*L-y)+ro.*y+di;  % y为0表示是水中桩底部截面
    rotation=@(y) H/2/EI*(2*L*y-y.^2)+ro;
    uw1=deflection(L-depthInWater);
    rw1=rotation(L-depthInWater);
    %}
end
% 将输出的转角的正方向转换为：ro为负表示桩向右偏转。
rw=-rw;
end

function [D,R]=upperDisplacementRotation(M,H,di,ro,EI,L,y)
% 对于一段等刚度的桩（梁），在不承受分布荷载的情况下，已知“上端”所受的弯矩与剪力，以及“下端”的位移与转角边界，求另一边的位移与转角。
% 输入参数：                                                             H,M
% M： 桩的上端（左端）所受的弯矩，以上端（左端）逆时针为正             ^    ___
% H： 桩的上端（左端）所受的剪力，以上端（左端）向右（向上）为正      y  |   |  |
% di,ro： 桩的下边界的位移与转角，位移以向右为正，转角以向右转动为正     |   |  |
% EI：此段桩的长度与抗弯刚度                                         0 |___|__|__> x
% L：此段桩的总长度
% y： 一个向量，其中的元素代表某截面到桩段底部的距离，其值的范围从0到L，
%     当y=L时，所求的即是桩的上端部的位移与转角；当y=0时，D与R的值即为di与ro。
%
% 输出参数：
% D：桩的上端的位移
% R: 桩的上端的转角
D=(H*y.^3/3/EI)+((M+H*(L-y)).*y.^2/2/EI)+(di+ro*y);
R=(H*y.^2/2/EI)+((M+H*(L-y)).*y/EI)+(ro);

% 各分项的意义如下：
% D_H=H*y.^3/3/EI;  % 桩边界处的剪力对于指定桩截面处的位移的贡献
% R_H=H*y.^2/2/EI;  % 桩边界处的剪力对于指定桩截面处的转角的贡献
% D_M=(M+H*(L-y)).*y.^2/2/EI;  % 桩边界处的弯矩对于指定桩截面处的位移的贡献
% R_M=(M+H*(L-y)).*y/EI;  % 桩边界处的弯矩对于指定桩截面处的转角的贡献
% D_di_ro=di+ro*y;  % 桩下边界处的位移与转角对于指定桩截面处的位移的贡献
% R_di_ro=ro;  % 桩下边界处的位移与转角对于指定桩截面处的转角的贡献
% D=D_H+D_M+D_di_ro;
% R=R_H+R_M+R_di_ro;

end
