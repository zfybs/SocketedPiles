function Results= finitedifference(physicalConditions)
% 输入参数与输出参数都是针对于截断了非屈服区后的新的几何或荷载参数下的结果所得到的！
% 可能出现的出错情况：
% 1、当向量l中的第一层太小的时候，其对应的平均分段的长度h也会很小，此时Ax=b中的b向量中，
%       由公式（34a）与（34b）所确定的唯二的两个非零值也会很接近于0，此时解得的x很可能全为0.
%       这种情况要通过正确地处理屈服点的位置来调整（比如非屈服区中第一层的长度小于1cm时，即认为非屈服区中没有这一层）。
%
% 输入参数：physicalConditions 它是一个类，代表进行有限差分计算所需要的所有物理参数，它包括如下属性：
% R      桩的半径，这是一个不变量；
% l      新的非屈服段的桩的总长，它是通过有限差分法计算得到的反力分布与土层的极限承载力分布
%        进行比较后得到的长度，即p_z<p_ult的桩段的长度；
% ep     桩的弹性模量，这是一个不变量；
% ip     桩的惯性矩，这是一个不变量；
% e1     这是一个向量，它代表未屈服区的每一层土的顶部的弹性模量；
% e2     这是一个向量，它代表未屈服区的每一层土的底部的弹性模量，这层土中间的弹性模量被认为是线性分布的；
% v      这是一个向量，它代表未屈服区的每一层土的泊松比；
% H      新的未屈服桩段的顶部的水平荷载；
% M      新的未屈服桩段的顶部的弯矩；
% nlayer 新的未屈服桩段所占的土层数；
%
% 输出参数 Results：[nseg r u ConcentratedReactionForce p]
% nseg  屈服区中每一层土的分段数
% r     本次有限差分法的迭代计算中每一步的gam a值，整个过程一共迭代了(length(r)-2)次，
%       第一个值是假设的，没有用，最后一个用来结束循环，不进行有限差分计算。
% u     屈服区中每一层土中的位移分布，每一层土中有nseg+5个位移节点，其中前2个节点与后2个节点是虚拟的，
%       所以u(3)代表的是这层土顶部的第一个节点；
% V     屈服区中每一层土中的剪力分布，每一层土中有nseg+1个剪力节点；
% p     屈服区中每一层土中的反力分布，每一层土中有nseg个反力节点，每一个节点值代表此段的返回平均值。
%       注意，这里的反力p是以节点来定义的，在后面的M函数文件中会将其转换到以深度z为变量的连续函数；；
%
% see also: FDMphysicalConditions , FDMResults , OriginalProjectParameters

%% 参数调用
% 执行整个运算所需要的变量有：R,H,M,ep,ip,nlayer,以及行向量e1,e2,l,v
R= physicalConditions.R;
l= physicalConditions.l;
e1= physicalConditions.e1;
e2= physicalConditions.e2;
v= physicalConditions.v;
H= physicalConditions.H;
M= physicalConditions.M;
nlayer= physicalConditions.nlayer;
epip= physicalConditions.epip;   % 每一层土中桩的抗弯刚度
%% 节点分段,设定每一层的分段数，最少为5段。
% n_seg_per_meter=8;
nseg=ceil(l*5);  % 自己先假定为0.2m一段
nsegult=(nseg<5);   % 每层至少k分为5段
nseg=5*nsegult+nseg.*~nsegult;
%%
etolerance=0.0001;  %容许的收敛误差
r=zeros(10,1);
r(1)=10;  %保证初始状态能够运行，即abs(r(nr)-r(nr-1))>etolerance成立
r(2)=1; %假设值;
nr=2;
%%
while abs(r(nr)-r(nr-1))>etolerance
    %% r与m1、m2不随土层的层数而变
    % 当gama的值大于2.5后，bessel(gama)就很接近于0了，那么，当bessel(gama)用作分母时，
    %就会产生很大的数值上的舍入误差，此时的迭代很有可能不收敛。
    k1_r=besselk(1,sym(r(nr)));
    k0_r=besselk(0,sym(r(nr)));
    % 这里要转换为符号变量是为了解决在r的值过大（大约大于2.5），k0与k1的值过小
    % 然后在下面的m1与m2的计算时，由于k0与k1的值过小，就会产生很大的数值上的舍入误差，此时的迭代很有可能不收敛。
    m1=(k1_r^2-k0_r^2)/(2*k0_r^2);
    m2=((k1_r+r(nr)*k0_r)^2-(r(nr)^2+1)*k1_r^2)/(2*k0_r^2);
    m1=double(m1); % 这里又转回浮点数是因为，用符号变量虽然精度高，但是计算速度过慢。
    m2=double(m2);
    %% 对于nlayer个不同的土层，创建出对应的[nlayer,1]的参数t,k,eta,h,alpha,beta
    t=(pi.*e2*R^2*m1)./(2*(1+v));
    k=(pi*(3-4*v).*e2*m2)./(2*(1+v).*(1-2*v));
    eta=e1./e2;
    h=l./nseg;   % 在某一层土中，每一段的长度
    alpha=2.*t.*h.^2./epip;
    beta=k.*h.^4./epip;
    %%
    % --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    % 对于nlayer=1的情况单独写一段代码，以避免出现后面的下标(nlayer-1)=0的情况。
    % --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    % 对应的位移的变量为 uol（即 u for one layer）
    if nlayer==1
        N=nseg+5;           % 一共有(nseg+5)个计算节点
        A=zeros(N,N);       % Ax=b 的系数矩阵
        b=zeros(N,1);       % Ax=b 的非奇次项
        % 桩顶第一个边界条件：论文中公式（34a）
        A(1,[1 2 4 5])=[1,-(2+alpha*eta),(2+alpha*eta),-1];
        b(1)=-(2*H*h^3)/(epip);
        % 桩顶第2个边界条件，论文中公式（34b）
        A(2,[2 3 4])=[1,-2,1];
        b(2)=M*h^2/(epip);      % 注意这里的公式与论文中公式（34b）有一个加减号的区别。
        % 桩的中间节点的控制方程，论文中公式（30）或公式（32）
        for i=3:N-2
            A(i,[i-2,i-1,i,i+1,i+2]) =[
                1
                -(4+alpha*(eta+(1-eta)*(i-3)/nseg-(1-eta)/(2*nseg))) % 注意这里的公式与论文中公式（30）有一个加减号的区别。
                (6+(2*alpha+beta)*(eta+(1-eta)*(i-3)/nseg))
                -(4+alpha*(eta+(1-eta)*(i-3)/nseg+(1-eta)/(2*nseg))) % 注意这里的公式与论文中公式（30）有一个加减号的区别。
                1
                ];         %      b(i)=0;
        end
        %------------------------------------------
        % 桩底的第1个边界条件：论文中的公式（34h）    弯矩为零：A(N-1,[N-3,N-2,N-1])=[1,-2,1];
        % 转角为零：A(N-1,[N-3,N-2,N-1])=[-1,0,1];
        A(N-1,[N-3,N-2,N-1])=[1,-2,1];   % b(n-1)=0
        % b(N-1)=(4e6)/epip(end)*h(end)^2;
        %-------------------------------------------
        % 桩底的第2个边界条件：论文中的公式（34i）
        A(N,[N-4,N-3,N-2,N-1,N])=[-1
            2+alpha
            -alpha*h*sqrt(k*(1+2*m1)/(t*m1))
            -(2+alpha)
            1];             % b(n)=0
        % ------------------------------------------------------------------------------------------
        % ----------------------- % 有不止一个土层的情况 --------------------------------------------
    else
        N=sum(nseg)+5*nlayer;         % 整根桩在所有土层中的所有计算节点数目。
        A=zeros(N,N);       % Ax=b 的系数矩阵
        b=zeros(N,1);       % Ax=b 的非奇次项
        % 整个桩顶第一个边界条件：论文中公式（34a）
        A(1,[1 2 4 5])=[1,-(2+alpha(1)*eta(1)),(2+alpha(1)*eta(1)),-1];
        b(1)=-(2*H*h(1)^3)/(epip(1));
        % 桩顶第2个边界条件，论文中公式（34b）
        A(2,[2 3 4])=[1,-2,1];
        b(2)=M*h(1)^2/(epip(1));      % 注意这里的公式与论文中公式（34b）有一个加减号的区别。
        %---------------------------------------------
        % 桩底的第1个边界条件：论文中的公式（34h）    弯矩为零：A(N-1,[N-3,N-2,N-1])=[1,-2,1];
        % 转角为零：A(N-1,[N-3,N-2,N-1])=[-1,0,1];
        A(N-1,[N-3,N-2,N-1])=[1,-2,1];   % b(n-1)=0
%          b(N-1)=(4e6)/epip(end)*h(end)^2;
%          b(N-1)=2*h(end)*0.0001;
        %---------------------------------------------
        % 桩底的第2个边界条件：论文中的公式（34i）
        A(N,[N-4,N-3,N-2,N-1,N])=[
            -1
            2+alpha(nlayer)
            -alpha(nlayer)*h(nlayer)*sqrt(k(nlayer)*(1+2*m1)/(t(nlayer)*m1))
            -(2+alpha(nlayer))
            1];             % b(n)=0
        % 不同土层交界处的四个边界条件：论文中的公式（34d）（34e）（34f）（34g）
        start=0;
        for layer=1:nlayer-1
            row=start+nseg(layer)+4;    % 交界处第一个边界条件在系数矩阵中的行号
            A(row,[row-1,row+4])=[1,-1];                            % 公式（34d）
            A(row+1,[row-2,row,row+3,row+5])=[                      % 公式（34e）
                h(layer+1),-h(layer+1),-h(layer),h(layer)];
            A(row+2,[row-2,row-1,row,row+3,row+4,row+5])=[          % 公式（34f） 这里考虑了不同土层中桩的刚度不同
                epip(layer)*h(layer+1)^2*[1,-2,1], ...
                -epip(layer+1)*h(layer)^2*[1,-2,1]];
            A(row+3,[row-3,row-2,row,row+1,row+2,row+3,row+5,row+6])=[   % 公式（34g）
                epip(layer)/h(layer)^3*[-1,(2+alpha(layer)),-(2+alpha(layer)),1],...
                -epip(layer+1)/h(layer+1)^3*[-1,(2+alpha(layer+1)*eta(layer+1)),-(2+alpha(layer+1)*eta(layer+1)),1]];
            start=sum(nseg(1:layer))+5*layer;
        end
        % 每一个土层的中间结节处的控制方程，论文中公式（30）或公式（32）
        start=0;
        for layer=1:nlayer
            for  row=start+3:start+3+nseg(layer)       % 控制方程在系数矩阵A中的行号
                A(row,[row-2,row-1,row,row+1,row+2]) =[
                    1
                    -(4+alpha(layer)*(eta(layer)+(1-eta(layer))*(row-3)/nseg(layer)-(1-eta(layer))/(2*nseg(layer)))) % 注意这里的公式与论文中公式（30）有一个加减号的区别。
                    (6+(2*alpha(layer)+beta(layer))*(eta(layer)+(1-eta(layer))*(row-3)/nseg(layer)))
                    -(4+alpha(layer)*(eta(layer)+(1-eta(layer))*(row-3)/nseg(layer)+(1-eta(layer))/(2*nseg(layer)))) % 注意这里的公式与论文中公式（30）有一个加减号的区别。
                    1
                    ];         %      b(i)=0;
            end
            start=sum(nseg(1:layer))+5*layer;
        end
    end
    % ---------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    % --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    %% 求解线性方程组 Ax=b
    %   x=A\b;
    x=GaussMainEli(A,b);
    u=cell(1,nlayer);
    start=0;
    for i=1:nlayer
        u{i}=x((start+1):(start+nseg(i)+5)) ;
        start=sum(nseg(1:i))+5*i;
    end
    %% 反算出新的r，用梯形公式进行数值积分的方法，参考论文中公式（28）
    %
    r_num_int=zeros(1,nlayer); % nlayer层的分子上的积分项
    r_den_int=zeros(1,nlayer); %% nlayer层的分母上的积分项
    for i=1:nlayer              % 每层土中的积分项的表达
        r_i=linspace(0,l(i),nseg(i)+1)';     % 线性插值积分的x向量
        
        r_num=(eta(i)+(1-eta(i))*r_i/l(i)).*((u{i}(4:nseg(i)+4)-u{i}(2:nseg(i)+2))/2/h(i)).^2;    % 分子项中，用于线性插值积分的y向量
        r_num_int(i)=2*t(i)*trapz(r_i,r_num);    % 在论文中的公式中只给出了土层与岩石层两项，但是在实际操作中，每一层土都有对应的这一项。
        
        r_den=(eta(i)+(1-eta(i))*r_i/l(i)).*(u{i}(3:nseg(i)+3)).^2;    % 分母项中，用于线性插值积分的y向量
        r_den_int(i)=k(i)*trapz(r_i,r_den);      % 在论文中的公式中只给出了土层与岩石层两项，但是在实际操作中，每一层土都有对应的这一项。
    end
    % 底部桩端的那一项的表达
    r_num_end=sqrt(t(nlayer)*k(nlayer)*m1/(1+2*m1))*u{nlayer}(nseg(nlayer)+3)^2;
    r_den_end=0.5*sqrt(t(nlayer)*k(nlayer)*(1+2*m1)/m1)*u{nlayer}(nseg(nlayer)+3)^2;
    % -------------------------------------------------------------------------------------
    nr=nr+1;
    % 一共迭代了(nr-2)次，第一个值是假设的，没有用，最后一个用来结束循环，不进行有限差分计算。
    r(nr)=sqrt(m2/m1*(sum(r_num_int)+r_num_end)/(sum(r_den_int)+r_den_end));  %用表示r的公式算出新的r的值
end
% u{1}(3)  % 顶部节点的位移
% (u{1}(4)-u{1}(2))/2/h(1)  % 顶部节点的转角
%{
将最终的结果（稀疏矩阵的形式）转换为全矩阵
for i =1:nlayer
    u{i}=full(u{i}) ;
end
%}
%---------------------------------------------------------------------------
%% 计算节点反力 ConcentratedReactionForce：弯矩 BendingMoment 与剪力 ShearForce
% 剪力V是一个结构体，其中有两个字段，字段ShearForce的值是一个元胞数组，其中包含了nlayer个double数组D；
% 元素数组D的下标值越大，表示这层未屈服的土越靠近桩的底部。
% 元素数组D中的元素代表这一层未屈服土中的每一个节点的剪力；
% 元素数组D中有n+1个值，其每一个值都代表一个真实的结点的剪力。
% 字段NodeDepth代表未屈服区的每一个节点所对应的深度。此深度值为正，以未屈服区的顶部节点为基准。
% 但是要注意，从全局来看，全局的深度值是以整个水下土体的顶部（即水中底部位置）为基准的，
% 所以在绘图时要进行一个换算，即加上整个桩的屈服段的长度值。
ShearForce=cell(1,nlayer);
BendingMoment=cell(1,nlayer);
NodeDepth=cell(1,nlayer);
pzFromGoverningEquation=cell(1,nlayer);
top=0;
% X=[];
% Y=[];
for i=1:nlayer
    % 参考论文中公式（35a）或（35b）
    % 此表达式的公式有可能有误
    ShearForce{i}=(epip(i)./2/h(i)^3)*(u{i}(5:nseg(i)+5)-2*u{i}(4:nseg(i)+4)+2*u{i}(2:nseg(i)+2)-u{i}(1:nseg(i)+1))...
        -t(i)/h(i)*(eta(i)+(1-eta(i))*((0:nseg(i))')/nseg(i)).*(u{i}(4:nseg(i)+4)-u{i}(2:nseg(i)+2));
    % 参考论文中公式（36a）或（36b）
    BendingMoment{i}=(epip(i)./h(i)^2)*(u{i}(4:nseg(i)+4)-2*u{i}(3:nseg(i)+3)+u{i}(2:nseg(i)+2));
    NodeDepth{i}=linspace(top,l(i)+ top,nseg(i)+1)';
    top=sum(l(1:i));
    % 由论文中控制方程（5a）推导的反力表达式，此pz向量中每一个元素的值即为土层中这一节点的的邻域微段内的土层反力值。
    pzFromGoverningEquation{i}=k(i)*(eta(i)+(1-eta(i))*((0:nseg(i))')/nseg(i)).*u{i}(3:nseg(i)+3);
%     X=[X;NodeDepth{i}];
%     Y=[Y;pz{i}];
end
%ShearForce{i}(1)即代表土层段的第1个节点，即z=0的点
%ShearForce{i}(nseg(i)+1)即代表土层段的第(nseg(i)+1)个节点，即z=l(i)的点

%%
 Results=FDMResults(physicalConditions,nseg,r,u,NodeDepth,ShearForce,BendingMoment,pzFromGoverningEquation);
%% THE END

% figure;hold on
%  Results.plot_BendingMoment(gca);
%  Results.plot_ShearForce(gca);
% % Results.plot_pz(gca);
% % figure,hold on
% % Results.plot_Displacement(gca)
% % figure,hold on
% Results.plot_pz(gca);
% plot(Y,X,'bo-')
% fprintf(['顶点位移值为：\n ' num2str(Results.top_u*1000) ' mm.\n'] )
end