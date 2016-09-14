function SectionDefinitions = ConstructShaftSections(SectionParameters,systemProperties)
% 将桩截面定义转换为对应的 .mat 文件
% 输出参数：SectionDefinitions  一个结构体列向量，其中每一个元素为一个桩截面定义中所对应的信息

% ------ 定义结构体 -------
n =length(SectionParameters);
c = cell(n,1);
SectionDefinitions = struct( ...
'ID'            ,c, ...  & 每一个截面的标识名称
'Name'            ,c, ...  & 每一个截面的标识名称
'EA'              ,c, ...
'BendingMoment'   ,c, ...
'BendingStiffness',c, ...
'Mcr'             ,c, ...
'Mult'            ,c, ...
'EI1'             ,c, ...
'EI2'             ,c);

% ------ 材料参数 -------
fy=systemProperties.fy;
fcp=systemProperties.fcy;
Es=systemProperties.Es; % 钢材的弹性模量，单位为KPa。
for i = 1:n
    section = SectionParameters(i).ATTRIBUTE;
    M_EI.ID = SectionParameters(i).ID;
    M_EI.Name = section.Name;
    [thickness_steeltube,D_tube,D_bar,n,D_SteelCage]=configureSection(section);
    
    %%
    
    %% 二次参数
    % 钢套管
    R_tube=D_tube/2;
    I_tube=pi/4*(R_tube^4-(R_tube-thickness_steeltube)^4);   % 钢套管对于截面中心轴的惯性矩
    
    % 混凝土
    D_sec=D_tube-thickness_steeltube*2;  % 桩的毛截面直径
    R=D_sec/2;      % 桩的半径
    I_sec=pi*D_sec^4/64; % 桩的毛截面惯性矩
    fr=19.7*fcp^0.5;  % 混凝土抗拉强度
    
    % 钢筋
    coverThickness=R-D_SteelCage/2;   % 保护层厚度
    e_y=fy/200e6;   % 钢筋的屈服应变
    R_bar=D_sec/2-coverThickness-D_bar/2;   % 钢筋的中心点距离桩中心的距离
    I_steel=steelMoment(D_sec,D_bar,n,coverThickness,0,2,0);
    EI_SteelBar=Es*I_steel;           % 钢筋的抗弯刚度
    
    %% 开裂前
    % 混凝土的贡献
    Ec=151000*fcp^0.5;  % 混凝土的初始弹性模量；即e=0时的切线模量。单位为KPa
    e_c_tensile=fr/Ec;  % 混凝土受拉开裂时的应变
    fai=e_c_tensile/R;  % 即将开裂时，平截面的弯曲角度
    % 开裂前的刚度由钢套管、混凝土与纵筋提供
    B_preCrack=Ec*I_sec+EI_SteelBar+Es*I_tube;    %截面的初始刚度
    % 开裂弯矩值，其中混凝土与纵筋的部分由文献中给出的公式确定，钢套管的部分由弹性解确定
    Mcr=fr*I_sec/R_bar+Es*I_tube*fai;   %即将开裂时的弯矩值
    
    %% 开裂后的惯性矩
    
    % Acr：对于圆形截面的指定中性轴，位于其受压侧的混凝土的面积。
    % 其中：R代表圆截面的半径；xcr代表指定的中性轴，如果中性轴中圆截面的水平半径轴，则xcr=0。
    % 当xcr的值为负时，表示的是求受拉侧的面积。
    Acr=@(R,Xcr) acos(Xcr/R)*R^2-Xcr*sqrt(R^2-Xcr^2);    %R^2*(pi/2-asin(Xcr/R)-Xcr/R*sqrt(1-(Xcr/R)^2))
    
    % Scr：在平截面假定下，在指定中性轴的受压侧混凝土，关于中性轴的面积矩，即每一微元的面积与其到中性轴的距离的乘积。
    % 其中：R代表圆截面的半径；xcr代表指定的中性轴，如果中性轴中圆截面的水平半径轴，则xcr=0。
    % 当xcr的值为负时，表示的是求受拉侧的面积矩。
    % 如果用符号表达式来求精确解，则Scr的构造方法如下：但是，下面这种符号表达式求积分会非常耗时。
    % x=sym('x'); Scr=@(R,xcr)real(double(2*int((x-xcr)*sqrt(R^2-x^2),x,xcr,R)));
    % 用integral函数的数值积分的方法来求解。
    Scr=@(R,xcr) 2*integral(@(x)(x-xcr).*sqrt(R^2-x.^2),xcr,R);
    
    % Icr：在平截面假定下，在指定中性轴的受压侧混凝土，关于中性轴的惯性矩，即每一微元的面积与其到中性轴的距离的平方的乘积。
    % 其中：R代表圆截面的半径；xcr代表指定的中性轴，如果中性轴中圆截面的水平半径轴，则xcr=0。
    % 当xcr的值为负时，表示的是求受拉侧的惯性矩。
    % 如果用符号表达式来求精确解，则Icr的构造方法如下：但是，下面这种符号表达式求积分会非常耗时。
    % x=sym('x'); Icr=@(R,xcr)real(double(2*int(sqrt(R^2-x^2)*(x-xcr)^2,x,xcr,R)));
    % 用integral函数的数值积分的方法来求解。
    Icr=@(R,xcr) 2*integral(@(x)sqrt(R^2-x.^2).*(x-xcr).^2,xcr,R);
    
    %% 用迭代法求完全开裂后的中性轴，根据 ACI 规范，当混凝土开裂时，认为其整个受拉区全部退出工作。
    oldxcr=R_tube/2-1;	% 初始假定的中性轴
    ubxcr=R_tube;    % 初始假定的中性轴可以浮动的范围的上界
    lbxcr=0;    % 初始假定的中性轴可以浮动的范围的下界
    newxcr=oldxcr+1; % 进行循环的初始值
    while abs(newxcr-oldxcr)>0.0005;    % 容许误差为1mm
        oldxcr=newxcr;
        % ec=sym('ec')
        % fai=ec/(R-oldxcr);  % 截面的变形角度
        pt_s=steelMoment(D_sec,D_bar,n,coverThickness,oldxcr,1,1)*Es;  % *fai  % 受拉区钢筋的合力，受拉区的混凝土全部退出工作
        pp_s=steelMoment(D_sec,D_bar,n,coverThickness,oldxcr,1,-1)*Es; % *fai  % 受压区钢筋的合力
        pp_c=Scr(R,oldxcr)*Ec; % *fai       % 受压区混凝土的合力
        pp_t=(Scr(R_tube,oldxcr)-Scr(R,oldxcr))*Es;      % 受压区的钢套管的合力
        pt_t=(Scr(R_tube,-oldxcr)-Scr(R,-oldxcr))*Es;      % 受拉区的钢套管的合力
        %
        equi=pt_s+pt_t-pp_s-pp_c-pp_t;
        if equi>0   % 说明此假定的中性轴太高，导致受拉区的合力大于受压区的合力
            newxcr=lbxcr+(oldxcr-lbxcr)/2;
            ubxcr=oldxcr;
        else   % 说明此假定的中性轴太低，导致受拉区的合力小于受压区的合力
            newxcr=oldxcr+(ubxcr-oldxcr)/2;
            lbxcr=oldxcr;
        end
    end
    xcr=newxcr;   % 最终的中性轴的位置
    %% 完全开裂后
    % 完全开裂时的截面的等效惯性矩。参考钢筋混凝土原理：第11.3节。它由钢套管、混凝土、纵筋共同组成。
    B_crack=Ec*Icr(R,xcr)+Es*steelMoment(D_sec,D_bar,n,coverThickness,xcr,2,0)+Es*(Icr(R_tube,xcr)-Icr(R,xcr));
    %
    Mult=B_crack*0.015/(R_bar+xcr);    % 受拉区钢筋屈服
    %% 等效惯性矩法（即等效刚度法）
    % 这里认为外面的钢套管的作用与内部的钢筋笼的作用相似，所以仍然按无钢套管的三次式进行衰减
    Beff=@(M) ((Mcr./M).^3*B_preCrack+(1-(Mcr./M).^3)*B_crack);  % 随着弯矩的增大，截面的等效刚度在减小
    %% 考虑轴力
    EA_tube=Es*pi*((D_tube)^2-(D_tube-thickness_steeltube)^2)/4;
    EA_bars=Es*pi*D_bar^2/4*n;
    EA_concrete=Ec*pi*(D_tube-thickness_steeltube)^2/4;
    EA=EA_tube+EA_bars+EA_concrete;
    %% 构造结构体
    M=exp(linspace(log(Mcr),log(Mult),15)');   % 参考的弯矩点按指数级变疏
    Stiffness=Beff(M);
    M=[0;M];
    Stiffness=[Stiffness(1);Stiffness];
    %
    M_EI.EA=EA*1000; % 截面在弹性阶段的抗压刚度。将单位从KN转换为N。
    M_EI.BendingMoment=M*1000;              % 将单位从KN转换为N。
    M_EI.BendingStiffness=Stiffness*1000;   % 将单位从KN转换为N。
    M_EI.Mcr=M_EI.BendingMoment(2);
    M_EI.Mult=M_EI.BendingMoment(end);
    M_EI.EI1=M_EI.BendingStiffness(1);
    M_EI.EI2=M_EI.BendingStiffness(end);
    
    SectionDefinitions(i) = M_EI;
    %
    % filePath = fullfile(sectionDirectory,[M_EI.Name,'.mat']);
    % save(filePath, 'M_EI', 'D_tube', 'thickness_steeltube', 'D_bar','D_SteelCage', 'n','D_SteelCage','fy','fcp')
    %% 绘图检查
%     figure;
%     hold on;
%     plot(M_EI.BendingMoment,M_EI.BendingStiffness,'r*-')
%     xlabel('Bending Moment (N*m)')
%     ylabel('EI (N*m^2)')
%     grid on
    %
end  % 下一个桩截面
end

%%
function [thickness_steeltube,D_tube,D_bar,n,D_SteelCage]=configureSection(section)
% 构造不同类型的桩截面
% 输入参数：
% sectionName: 截面名称
% blnModified: 是否使用文献中所给出的原始截面参数，如果要对截面进行修正，则为True。
%
% 输出参数：
% thickness_steeltube:  钢套管的壁厚，单位为m。如果没有钢套管，则为0。
% D_tube: 桩的外径，单位为m。如果有钢套管，则为钢套管的外径。
% D_bar: 纵向钢筋直径，单位为m
% n: 纵向钢筋的根数
% D_SteelCage: 钢筋笼的直径（外径），单位为m。
% fy:  钢筋的屈服强度，单位为KPa。比如HPB300的屈服强度为300e3 KPa
% fcp: 28天圆柱体抗压强度，单位为KPa。 C40立方体抗压强度标准值为fcu=26.8MPa，等效为28天圆柱体抗压强度fcp=0.79*fcu=21.172Mpa


thickness_steeltube=section.ThicknessOfSteeltube;
D_tube=section.Diameter;
%
D_bar=section.DBar;
n=section.BarsCount;
D_SteelCage=section.DSteelCage;

end


%%
function steel=steelMoment(D,d,n,coverThickness,xcr,varargin)
% 求指定区域的钢筋关于指定中性轴的静矩或者惯性矩
% 此函数只适用于圆形的钢筋笼中的纵筋，而且纵筋沿圆形均匀分布。
% 输入参数
% D     整个圆形截面的直径
% d     钢筋的直径
% n     钢筋的根数，所有的钢筋呈环形均匀分布
% coverThickness    钢筋的保护层厚度，指从圆形截面边缘到钢筋边缘的距离，而不是到钢筋中心的距离
% xcr   关于特定中性轴来求矩，如果是关于圆截面的半径轴，则xcr=0
% varargin
% 1、order：    表示取矩的阶数，如果为1，则表示求一阶矩，即静矩，如果为2，则表示求二阶矩，即惯性矩，默认为求惯性矩。
% 2、portion：  表示要计算哪一部分的矩；如果为-1，则表示求受压区的钢筋的矩，
%                 如果为1，则表示求受拉区的钢筋的矩；如果为0，则表示求整个截面中所有钢筋关于指定中性轴的矩。默认为0。
% 输出参数
% steel     指定条件下所得到的钢筋的面积矩或者惯性矩


% 先设定默认值
order=2;    % 默认求惯性矩，而不是静矩；
portion=0;  % 默认求整个圆截面中所有钢筋关于指定中性轴的矩
% xcr=D/2-xcr;  % 将xcr的概念由中性轴到水平半径轴的距离转换到中性轴到最外边缘的距离
if length(varargin)==1
    order=varargin{1};
elseif length(varargin)==2
    order=varargin{1};
    portion=varargin{2};
end

%
r=d/2;   % 钢筋的半径
R_bar=D/2-coverThickness-r;   % 钢筋的中心点距离桩中心的距离

%
% 整个截面中所有钢筋的排布方式，这里取第一根钢筋的位置为圆截面底部，这是因为，在一般情况下，都是优先将钢筋布置在受拉区。
angle=(linspace(0,360-360/n,n)'+270)/180*pi;
aa=asin(xcr/(D/2))+2*pi;    % 指定中性轴的外边缘点与圆心的直线A，与截面圆的向下的竖直半径轴 B 的顺时针夹角
subAngle=angle>aa & angle<=(5*pi-aa); % 只位于受压区的钢筋
if portion==-1 % 说明只要求受压区的钢筋关于指定中性轴的矩
    angle=angle(subAngle);   % 只位于受压区的钢筋
elseif portion==1 % 说明只要求受拉区的钢筋关于指定中性轴的矩
    angle=angle(~subAngle);   % 只位于受拉区的钢筋
end
distance=abs(R_bar*sin(angle)-xcr);   % 每一根钢筋的中心点到指定的中性轴的距离
if order==2   % 求惯性矩
    S1=pi/4*r^4*length(distance);   % 指定区域的钢筋关于自身的中心的惯性矩
    steel=S1+pi*r^2*(sum(distance.^2));   % 钢筋的惯性矩
else    % 求静矩
    S1=pi*r^2;  % 指定区域的钢筋的面积
    steel=S1*sum(distance);
end
end