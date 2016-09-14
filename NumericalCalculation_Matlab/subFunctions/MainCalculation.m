function [depth_disp,depth_Moment,displacement,FDMres,curve,Zy,yieldzone] = MainCalculation(handles,OriPar,H)
%
% 输出参数：
%       depth_disp ：整根桩（包括水中）的位移曲线
%       depth_Moment ：整个嵌固端所有的节点的深度值与对应的弯矩。
%       其他的输出参数是最后一次水平荷载的最后一次 overall 计算结果。

global Dir_Results;
global considerYieldofPileInWater  % 是否考虑水中桩在弯矩作用下的开裂与对应的刚度减小。
global ConsiderCrackofPileInEarth  % 是否考虑土中桩在弯矩作用下的开裂与对应的刚度减小。
considerYieldofPileInWater=true;
ConsiderCrackofPileInEarth=considerYieldofPileInWater;

%% 修改原始参数
direction = zeros(length(H),1);
H_D = [H,direction];

%% 基本参数修正
global SearchingDirection
Hs3=H_D(:,1);
Direction=H_D(:,2);   % 屈服点搜索的方向
%
M=Hs3*OriPar.lw;
% OriPar.lw=0;
%
EI=OriPar.epip;   % 修正弹性模量
%%
count_Load=length(Hs3);
u_pileHead=zeros(count_Load,1); % 整个桩顶
topu_unYield=zeros(count_Load,1);  % 未屈服区顶部的位移
topr_unYield=topu_unYield;  % 未屈服区顶部的位移

% 要提取的坐标与位移、弯矩信息
temp_c  = cell(1,count_Load);
depth_disp=struct('Depth',temp_c,'Disp',temp_c);     % 整根桩的位移曲线
depth_Moment=struct('Depth',temp_c,'Moment',temp_c);     % 整个嵌固端所有的节点的深度值与对应的弯矩。

%
curve_u=cell(count_Load,1);   % 每一级荷载作用的最终的位移曲线
%%
Count=1;    % 总共计算的次数
for i=1:count_Load
    blnYield=true;    % 桩中是否有屈服
    norm_diff=1000000;
    j_norm=1;
    SearchingDirection=Direction(i);
    % 关于桩截面是否屈服并要再一次迭代的判断，根据经验，当桩出现了两次屈服后，
    % 再次修正桩的抗弯刚度值，对最终的结果影响已经很小了，所以这里设置最多考虑三次桩本身的屈服。
    while norm_diff>5000 && blnYield  && j_norm<=3
        fprintf(2,[' -------------------\n 第',num2str(i),'级加载，荷载为',num2str(Hs3(i)/1000),'KN\n -------------------\n'])
        fprintf([' -------------------\n 桩截面第',num2str(j_norm),'次屈服迭代。\n -------------------\n', ...
            ' 开始第',num2str(Count),'次计算…… \n -------------------\n'])
        Count=Count+1;
        %
        OriPar.H=Hs3(i);
        OriPar.M=M(i);
        OriPar.epip=EI;
        % 执行有限差分计算
        [displacement,FDMres,curve,Zy,yieldzone]=overall(handles,OriPar);
        res=FDMres(end);
        %
        topu_unYield(i)=res.top_u;
        topr_unYield(i)=res.top_r;
        % 岩石层顶部的位移
        %     u_pileHead(i)=displacement.u_water(1);
        
        % 嵌固段顶部的位移
        if  yieldzone.exists % 说明有屈服段
            %
            depth_Moment(i).Depth=yieldzone.NodeDepth;
            depth_Moment(i).Moment=yieldzone.BendingMoment;
        else  % 说明没有屈服段
            %
            depth_Moment(i).Depth=[];
            depth_Moment(i).Moment=[];
        end
        
        % 将未屈服区中的位移与对应的深度添加进去
        for j=1:length(res.u)
            depth_Moment(i).Depth=[depth_Moment(i).Depth;res.NodeDepth{j}+res.physicalConditions.Zy];
            depth_Moment(i).Moment=[depth_Moment(i).Moment;res.BendingMoment{j}];
        end
        % -------------------------------------------------------------------
        
        %消除“深度-弯矩”组合向量中的相同深度
        temp1=depth_Moment(i).Depth(1:end-1)-depth_Moment(i).Depth(2:end)==0;
        depth_Moment(i).Depth(temp1)=[];
        depth_Moment(i).Moment(temp1)=[];
        
        % 判断桩中是否有屈服
        %         curve=plot(ax,depth_Moment{i}.moment,depth_Moment{i}.depth);
        % 对桩中的屈服段进行处理
        [blnYield, EI]=yieldInPile(OriPar,depth_Moment(i).Depth,depth_Moment(i).Moment);
        EI_now=EI;
        if j_norm==1
            norm_diff=1000000;
            % set(curve,'color','red')
        else
            norm_diff=norm(EI_now-EI_last,2);
        end
        EI_last=EI_now;
        j_norm=j_norm+1;         % 因为桩的屈服而迭代的次数
    end
    
    curve_u{i}=curve.u;     % 每一级荷载作用的最终的位移曲线
    
    % Depth_disp:在这一荷载下的计算结果中，整个桩段的所有节点的标高及对应的位移
    Depth_disp_local=res.GetDepth_u;
    
    if isfield(displacement, 'u_water') % 说明计算的水中桩段长度不为0。
        u_pileHead(i)=displacement.u_water(1);
        
        % 分别提取整根桩（水中、屈服区，未屈服区）中的坐标（土层顶为0）与对应的位移。
        depth_disp(i).Depth=[depth_disp(i).Depth;
            displacement.depth_Water - displacement.depth_Water(end);
            yieldzone.NodeDepth;
            Depth_disp_local(:,1)];
        depth_disp(i).Disp=[depth_disp(i).Disp;
            displacement.u_water;
            yieldzone.u;
            Depth_disp_local(:,2)];
        
    else   % 说明计算的水中桩段长度为0，可以不考虑水中的桩段。
        %
        if res.physicalConditions.Zy>0  % 说明有屈服区
            u_pileHead(i)=displacement.u_yield(1);  % 桩顶位移即为嵌固段顶部位置
        else  % 说明整个嵌固段都没有屈服
            u_pileHead(i)=displacement.unyieldtopdi;  % 桩顶位移即为嵌固段顶部位置
        end
        
        % 分别提取整根桩嵌岩部分（屈服区，未屈服区）中的坐标（土层顶为0）与对应的位移。
        depth_disp(i).Depth=[depth_disp(i).Depth;
            yieldzone.NodeDepth;
            Depth_disp_local(:,1)];
        depth_disp(i).Disp=[depth_disp(i).Disp;
            yieldzone.u;
            Depth_disp_local(:,2)];
    end
    
    %消除“深度-位移”组合向量中的相同深度
    temp1=depth_disp(i).Depth(1:end-1)-depth_disp(i).Depth(2:end)==0;
    depth_disp(i).Depth(temp1)=[];
    depth_disp(i).Disp(temp1)=[];    
end

% 启用相应的控件
set([handles.menu_Pz_Pult,handles.menu_tfd,...
    handles.generate,handles.menu_gama,handles.menu_V,handles.menu_OverView],'enable','on')

% 将计算结果进行保存
matFilePath = fullfile(Dir_Results,[OriPar.ShaftName,'.mat']);
save(matFilePath,'depth_disp','depth_Moment');