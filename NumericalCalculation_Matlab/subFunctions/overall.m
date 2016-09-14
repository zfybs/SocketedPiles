function [displacement,FDMres,curve,Zy,yieldzone]=overall(handles,OriginalParameters)
% 对于屈服的处理思路是分为，有限差分计算、得出屈服点、参数截断，在新参数下有限差分计算...
% 当未屈服区不超过1cm里，认为整个土层屈服，此时应该修改原始参数。
% 输入参数：
% handles   GUI界面窗口中的handles；
% OriginalParameters    整个工程项目的原始物理参数
%
% 输出参数：
% FDMres    一个类数组，每一个元素都是一个 FDMResults 类，其中定义了在一次有限差分计算中所需要的物理参数，以及所有的计算结果。
% yieldzone 一个类，代表了屈服区中的相关数据
% curve     界面窗口中所有绘制的plot曲线的句柄值
%
% see also:Rock_Socketed_Shafts,OriginalProjectParameters,FDMResults

% % 绘制极限承载力曲线
% figure
% save 1
% OriginalParameters.plot_pult(gca);
% grid on
% return
hold(handles.axes1,'on');
hold(handles.axes2,'on')
grid(handles.axes1,'on')
grid(handles.axes2,'on')
%% 基本参数设定
% assignin('base','OriginalParameters',OriginalParameters) % 用于测试查看
R=OriginalParameters.R;
l=OriginalParameters.l;
epip=OriginalParameters.epip;
% ip=OriginalParameters.ip;
e1=OriginalParameters.e1;
e2=OriginalParameters.e2;
v=OriginalParameters.v;
H=OriginalParameters.H;
M=OriginalParameters.M;
nlayer=OriginalParameters.nlayer;
lw=OriginalParameters.lw;
pultfun=OriginalParameters.pultfun;% 得到表示极限承载力的变量pultf，为后面的pultz函数调用。
% set(handles.figure1,'CurrentAxes',handles.axes1)
curve.pult=OriginalParameters.plot_pult(handles.axes1);
%% 下面用有限差分法求解位移u，剪力V，与反力p
%
physicalConditions = FDMphysicalConditions(R,l,epip,e1,e2,v,H,M,nlayer,0);
results=finitedifference(physicalConditions); %执行有限差分法，其需要的13个参数由上面的load调用得来。
FDMres=results;
%[nseg r u V pz]
nseg=results.nseg;
r=results.r;
u=results.u;
pz=results.pz;
% 
% save forplot.mat
%% 此时可以查看第一次有限差分后得到的位移，分布力等。
% 绘制第一条反力曲线
curve_pz_num=1;
% curve.pz(curve_pz_num)=results.plot_pz(handles.axes1,curve_pz_num); 
drawnow
%% 考虑屈服 改变参数 进行迭代，求出最终的屈服深度Zy
zy=zeros(1,10); %一个向量，其中第i个元素都代表进行第i次有限差分计算后得到的屈服深度的增量。
zy(1)=zyield(OriginalParameters,results); %求出屈服深度zy，zy(1)表示第一次有限差分后得到的屈服深度。
%%
r_logic=(r~=0);    % 一共迭代了(r_logic-2)次，第一个值是假设的，没有用，最后一个用来结束循环，不进行有限差分计算。
r_logic(1)=0;
r_data=num2cell(r(r_logic)); %表中显示的r的值
r_length=length(r_data);
data_for_table=get(handles.uitable1,'data');
data_for_table{2,1}=r_length-1;
data_for_table{1,1}=zy(1);
data_for_table(3:2+r_length,1)=r_data;
rowname_table1=get(handles.uitable1,'rowname');
set(handles.uitable1,'data',data_for_table,'rowname',[rowname_table1;num2cell((1:r_length)')])
%%
zynum=0;
while zy(zynum+1)>0.05  %在zyield函数中，当新的屈服长度小于5cm时，认为新段没有发生屈服。
    zynum=zynum+1; % zynum 的值就是整根桩已经发生屈服的次数
    % 观察一下H变化的趋势。
    [H M e1 e2 v epip l nlayer,zy]=parachange(OriginalParameters,physicalConditions,pultfun,zy,zynum);
    physicalConditions = FDMphysicalConditions(R,l,epip,e1,e2,v,H,M,nlayer,sum(zy));
    results=finitedifference(physicalConditions); %执行有限差分法
    FDMres=[FDMres;results];
    %[nseg r u V pz]
    nseg=results.nseg;
    r=results.r;
    u=results.u;
    pz=results.pz;
    %-----------
    %此时可以查看第(zynum+1)次有限差分后得到的位移，分布力等。
    %pz的区间为[0,l]+sum(zy)
    %交点为下一次比对出zyield得到的屈服深度（即为sum(zy)+zy(zynum+1)），pz的起点为上一次屈服的截断处，即为sum(zy)
    %由此次计算得到的pz划分新的屈服段
    %% 此时可以查看第i次有限差分后得到的位移，分布力等。
    curve_pz_num=curve_pz_num+1;
%      curve.pz(curve_pz_num)=results.plot_pz(handles.axes1,curve_pz_num);  
    drawnow
    zy(zynum+1)=zyield(OriginalParameters,results);  %求出第(zynum+1)段的相对屈服深度
    %%
    %更新最近的有限差分法的迭代次数。
    r_logic=(r~=0);    % 一共迭代了(r_logic-2)次，第一个值是假设的，没有用，最后一个用来结束循环，不进行有限差分计算。
    r_logic(1)=0;
    r_data=num2cell(r(r_logic)); %表中显示的r的值
    r_length=length(r_data);
    data_for_table=get(handles.uitable1,'data');
    data_for_table{2,zynum+1}=r_length-1;
    data_for_table{1,zynum+1}=zy(zynum+1);
    data_for_table(3:2+r_length,zynum+1)=r_data; % 以赋值的方式进行cell的组合。
    % 设置rowname
    rowname_table1=get(handles.uitable1,'rowname');
    rowmax=max(size(rowname_table1,1)-2,r_length);
    rowname_table1=rowname_table1(1:2);
    %
    set(handles.uitable1,'data',data_for_table,'rowname',[rowname_table1;num2cell((1:rowmax)')]);
    %%
    if sum(l)-zy(zynum+1)<0.1
        error('土层全部屈服，请修改土层参数')
        % 如果整根桩剩下的未屈服段的长度不足10cm，认为整个土层屈服，此桩不能用于实际。
        % 也是为了防止当l过小时，假设的bessel函数的值过小，导致计算出错。
    end
end
curve.pz(curve_pz_num)=results.plot_pz(handles.axes1,curve_pz_num);
%% 得到了迭代后的最终屈服深度Zy，第一部分告一段落。
Zy=sum(zy)-zy(zynum+1);
% 这里减去zy(zynum+1)是为了消除在while判断中给出的那个小于0.001m的误差。
% ----------------------
displacement.u=u;
% loadings.p=pz;
% loadings.v=V;
%
%将屈服区的深度与分段数传递给表格。
promptText = {['屈服区段数: ',num2str(length(find(zy)))];
    ['屈服截面深度 : ',num2str(Zy), ' m'];};
set(handles.text1,'string',promptText);
%
%%
%------------------------------------------------------------------------
% 得到了迭代后的最终屈服深度Zy，第一部分告一段落。
% 下面开始进行嵌固段中屈服区的位移与转角计算，以及水中和水上部分的桩段的位移和转角计算。
% -----------------------------------------------------------------------
%% 求解嵌固桩中屈服段的位移和转角
displacement.unyieldtopdi=results.top_u;
displacement.unyieldtopro=results.top_r;
waterbottomdi=results.top_u;%用于计算水中段底部位移。
waterbottomro=results.top_r;%用于计算水中段底部转角。
%

if Zy==0
    yieldzone=YieldZone();
else
    yieldzone=YieldZone(OriginalParameters,results.top_u,results.top_r,Zy);
    waterbottomdi=yieldzone.top_u;
    waterbottomro=yieldzone.top_r;
    %
    densey=40;
    depthYieldZone=linspace(0,Zy,densey)';
    [uYield,rYield,moment_Yield]=uyzone(OriginalParameters,results,depthYieldZone); % 自变量的取值范围只能是从0到Zy

    displacement.depth_Yield=depthYieldZone;    % 屈服区中每一个节点所在的深度（相对于嵌固端顶部）。
    displacement.u_yield=uYield';
    displacement.r_yield=rYield';
    displacement.moment_Yield=moment_Yield';
    %屈服段的顶部的位移和转角分别是上面两向量的第一个元素。
    %得到嵌固桩中屈服段顶端的位移和转角，以供下面求解水中的桩的位移和转角之用。
    waterbottomdi=uYield(1) ;% 也即等于 uYield(1);%如果有屈服段，则水中段底部位移就是屈服段顶部位移，否则就是上面的未屈服段顶的位移。
    waterbottomro=rYield(1) ;% 也即等于 rYield(1);
    %}
end
%% 求解水中桩段的位移和转角
if lw~=0
    densew=40;
    depthInWater=linspace(0,lw,densew)';
    % 确定海床底部的水平位移与转角边界条件
    if Zy==0
        waterbottomdi=u{1}(3);
        waterbottomro=(u{1}(4)-u{1}(3))/(l(1)/nseg(1));
    end
%
    [uw rw]=uwater(OriginalParameters,depthInWater,waterbottomdi,waterbottomro);
    displacement.u_water=uw;
    displacement.r_water=rw;
    displacement.depth_Water=depthInWater;
end
%% 至此整根桩的位移全部计算完成。
% ------------------------------------------------------------------------
% 至此整根桩的位移全部计算完成。
% 未屈服区的位移由有限差分法得出。
% 屈服区的位移由uyzone()函数得到，反力为屈服区的极限承载力，从pultfun符号变量得到。。
% 水中桩段的位移由uwater()函数得到，不考虑水的反力。
%
% 未屈服区的位移由变量u表示，每层土为u{i}(3,nseg(i)+3);
% 屈服区的位移与转角由变量 uyield 与 ryield 表示，嵌固端顶的位移与转角分别是变量 usoketed_top=subs(di) 与 rsoketed_top ;
% 水中段的位移与转角分别是变量 uw 与 rw ，整根桩顶的位移与转角分别是变量 utop 与 rtop 。
% -----------------------------------------------------------------------
%% 绘出整根桩的位移曲线。
% set(handles.figure1,'CurrentAxes',handles.axes2)
% 绘制未屈服桩段的位移曲线
curve.u(1)=results.plot_Displacement(handles.axes2);
% 绘制屈服区的位移曲线，注意桩深度值的范围（从0到Zy），因为对于全局而言，其基准面是土层顶部，而不是水面或桩顶。
if Zy~=0
    curve.u(2)=yieldzone.plot_u(handles.axes2); % plot(handles.axes2,yield.u,yieldzone.NodeDepth,'r');
end

% 绘制水中桩的位移曲线，注意桩深度值的范围（从-lw到0），因为对于全局而言，其基准面是土层顶部，而不是水面或桩顶。
if lw~=0
    i=linspace(-lw,0,densew)';
    curve.u(3)=plot(handles.axes2,uw,i,'b');
    set(curve.u(3),'linewidth',2)
end
%% THE END
end