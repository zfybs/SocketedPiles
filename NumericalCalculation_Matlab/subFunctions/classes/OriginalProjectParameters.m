classdef OriginalProjectParameters
    %  这个类用来定义一个工程项目中所包含的全部原始参数
    %  其中一共有19个属性，而且这些属性全部是只读的。
    %  对于上覆土为砂层时，砂层的自重并不会直接导致下层岩石的极限承载力的增加。
    % See AlsO: FINITEDIFFERENCE , FDMRESULTS , FDMphysicalConditions , pileType
    properties(SetAccess=public)
        % 一个向量，代表每一层土的类型。土层类型earthType有4种，
        % 分别是clay、sand、rock_smooth（剪切承载力系数为0.2）和rock_rough（剪切承载力系数为0.8），
        % 对应的earthType值分别为1、2、3、4。
        earthType
        % 每一层土中桩的截面类型，此截面类型控制其刚度值，并且控制了此截面的开裂弯矩、极限弯矩，以及随截面弯矩的增加而导致的抗弯刚度衰减的方式。
        % 此属性不一定要赋值，当不考虑桩在弯矩作用下开裂后的刚度减小时，此属性可以为空。但是与之相关的epip属性是一定有赋值的。
        PileType
        % 水中桩段的桩截面类型。默认水中桩段的截面都是一致的。
        PileType_Water
        GSI	%一个向量，代表每个岩石层的地质强度指标 Geological Strength Index
        J	%一个向量，代表每层黏性土的某个系数，其值的范围为0.25~0.5；
        %  一个标量，表示整根桩在土层中的等效半径，用于基本有限差分法中的计算，单位为m。
        %  由于桩是变截面的，所以这里的R是一个等效值，而且在一次有限差分的计算过程中是不变的；
        %  在桩的开裂以及刚度折减的过程中，这个值暂且也认为它是一个不变量。
        R
        cu	%一个向量，代表每层黏性土的极限承载力指标，即黏性土的不排水剪切强度；
        e1	%一个向量，代表每层土的顶端的弹性模量，单位为Pa
        e2	%一个向量，代表每层土的底部的弹性模量，单位为Pa，在一层土中，其弹性模量是按线性分布的；
        epip_water %桩在水中部分的抗弯刚度，单位为Pa*m^4。这个模量值专门用来计算水中桩段在弯矩作用下的弹性响应。
        %         ip	%桩的惯性矩，由桩的几何形状决定；
        l	% 一个向量，从整个土层顶到整个桩底的每一层土的长度，显然有 sum(l) = 桩在土中的的总长度，单位为m；
        lw	%桩在水中的那一段的长度，单位为m；
        mi	%一个向量，代表每个岩石层的
        nlayer	%一个标量，指示桩在土中一共占据了几层；
        phieff	%一个向量，代表每层砂性土的有效摩擦角，即phi_effective，单位为degree，不是弧度。
        reff	%一个向量，代表每层土的有效重度，即effective unit weight，单位为N/m^3；
        sigma_c	%一个向量，代表每个岩石层的无侧限抗压强度，单位为Pa；
        v	%一个向量，代表每层土的泊松比
        %       整个土层的极限承载力表达式，此属性为一个元胞数组，数组中以符号变量保存每一层土中任意深度处的极限承载力的表达式。
        %       在确定新的屈服点后，进行物理参数的修改时，可利用此符号变量来进行积分运算
        %       其中内含的自变量的符号为“pult_z”。
        pultfun
    end
    
    properties(SetAccess=public)
        H	%桩在整个土层顶部（不是桩的顶部）所受到的水平力，单位为N，其默认方向向右。
        M	%桩在整个土层顶部（不是桩的顶部）所受到的弯矩，单位为，其默认方向为顺时针，单位为N*m；
        % 一个向量，代表在用有限差分法计算时，嵌入部分的每一层中的桩的抗弯刚度，单位为 Pa，
        % 在初始时，它代表的是此桩截面在未开裂前的抗弯刚度；
        % 在计算后期，如果桩截面出现屈服，则其值会修改为屈服后的抗弯刚度值，用来在有限差分法中进行计算。
        % 当桩的复合型桩（比如钢套筒的砼桩）时，其ep值按总抗弯ep*ip刚度不变来进行等效；
        epip
    end
    
    properties(SetAccess=private)
        % 嵌岩桩的名称
        ShaftName
    end
    
    properties(GetAccess=private,SetAccess=private)
        % 这两个参数专门用在求任意深度处的极限承载力时的插值向量
        private_depth
        private_pult
    end
    
    %%
    methods
        % -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        function obj = OriginalProjectParameters(shaftName, earthType,GSI,J,R,cu,e1,e2,epip,l,lw, ...
                mi,nlayer,phieff,reff,sigma_c,v,varargin)
            % 输入参数说明
            % earthType：一个向量，代表每一层土的类型。土层类型earthType有4种，分别是clay、sand、rock_smooth（剪切承载力系数为0.2）和rock_rough（剪切承载力系数为0.8），对应的earthType值分别为1、2、3、4。
            % GSI：一个向量，代表每个岩石层的地质强度指标 Geological Strength Index
            % J：一个向量，代表每层黏性土的
            % R： 一个标量，表示整根桩的半径，单位为m。由于桩是变截面的，所以这里的R是一个等效值，而且在一次有限差分的计算过程中是不变的；
            % cu：一个向量，代表每层黏性土的极限承载力指标，即黏性土的不排水剪切强度；
            % e1：一个向量，代表每层土的顶端的弹性模量，单位为MPa
            % e2：一个向量，代表每层土的底部的弹性模量，单位为MPa，在一层土中，其弹性模量是按线性分布的；
            % ep：桩在嵌入部分的弹性模量，单位为Pa，当桩的复合型桩（比如钢套筒的砼桩）时，其ep值按总抗弯ep*ip刚度不变来进行等效；
            % epw： 桩在水中部分的弹性模量，单位为Pa。这个模量值专门用来计算水中桩段在弯矩作用下的弹性响应。
            % ip：桩的惯性矩，由桩的几何形状决定；
            % l：桩的总长度
            % lw：桩在水中的那一段的长度
            % mi：一个向量，代表每个岩石层的
            % nlayer：一个标量，指示桩在土中一共占据了几层；
            %　phieff：一个向量，代表每层砂性土的有效摩擦角
            % reff：一个向量，代表每层土的有效重度
            % sigma_c：一个向量，代表每个岩石层的无侧限抗压强度
            % v：一个向量，代表每层土的泊松比
            if nargin > 0
                obj.ShaftName = shaftName;
                obj.earthType=earthType;
                obj.GSI=GSI;
                obj.J=J;
                obj.R=R;
                obj.cu=cu;
                obj.e1=e1;
                obj.e2=e2;
                obj.epip=epip;
                obj.l=l;
                obj.lw=lw;
                obj.mi=mi;
                obj.nlayer=nlayer;
                obj.phieff=phieff;
                obj.reff=reff;
                obj.sigma_c=sigma_c;
                obj.v=v;
                % 计算得到一些属性值
                obj.pultfun=obj.getpultfun;
                [obj.private_depth,obj.private_pult]=obj.GetDepthPultPare;
                
                % 如果要考虑桩在弯矩作用下刚度的下降，则应该为pileType属性赋值，否则，可以不为这个属性赋值。
                if ~isempty(varargin)
                    obj.PileType=varargin{1};
                    if length(varargin)>1
                        obj.PileType_Water=varargin{2};
                        obj.epip_water=obj.PileType_Water.BendingStiffness(1);
                    end
                end
            end
        end % OriginalProjectParameters
        
        % -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        % 利用极限承载力的符号表达式，来获取指定深度处的极限承载力向量。
        function pult=GetPult_symfun(obj,z)
            % 由指定的深度位置返回对应的极限承载力向量，实现的方法为计算每一个深度值所对应的符号函数的值。
            % 此函数一般不进行实际的调用，因为耗时太长，同样的功能可以通过数值插值来实现。
            % 输入参数
            % z 	一个行向量或者列向量，用以返回指定深度位置的极限承载力；
            %       z 的值是相对于整个土层的顶部（即桩在水层的底部位置）的，而不是未屈服段的顶部位移的。
            %       由于pultfun中含有的符号为pult_z，所以pult函数的自变量只能设为pult_z，
            %       如果设为其他变量，就会出现subs不能赋值的情况，从而出错。
            % 输出参数：
            % pult 	一个数值列向量，代表指定的z位置处的极限承载力
            pultf=obj.pultfun;
            suml=0;
            psym=0;
            for i=1:obj.nlayer
                logic=(z>=suml & z<sum(obj.l(1:i)));
                zlogic=z.*logic;
                pult_part=pultf{i}(zlogic).*logic;
                psym=pult_part+psym;
                suml=sum(obj.l(1:i));
            end
            if max(z)==sum(obj.l)
                ind=find(z==sum(obj.l));
                psym(ind)=psym(ind)+pultf{obj.nlayer}(sum(obj.l));
            end
            pult=double(psym);
        end  % GetPult_symfun
        
        % -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        % 利用向量的线性插值，返回指定的深度位置处对应的极限承载力向量。
        function  p=GetPult(obj,z)
            % 由指定的深度位置返回对应的极限承载力向量，实现的方法为向量的线性插值。
            %   具体的方法为：利用类中已经得到的 depth 与 pult 这两个向量，用p=interp1(depth,pult,z)函数进行线性插值即可。
            % 输入参数
            % z 	一个行向量或者列向量，用以返回指定深度位置的极限承载力；
            %       z 的值是相对于整个土层的顶部（即桩在水层的底部位置）的，而不是未屈服段的顶部位移的。
            % 输出参数：
            % p 	一个列向量，代表指定的z位置处的极限承载力
            p=interp1(obj.private_depth,obj.private_pult,z);
        end % GetPult
        
        % -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        function h_curve=plot_pult(obj,ax)
            % 绘制从整个土层的顶部到整个桩的底部的极限承载力分布曲线
            % ax 进行图形绘制的坐标轴的句柄值。
            % 绘图的节点的密度大概取为2cm一段。
            k=0.02;
            % 下面这种处理X_depth是为了保证在不同土层交界面处都能取到相应的点，从而在绘图时不会遗漏交界处的关键数据。
            start=0;
            Y_depth=[];
            for i =1:length(obj.l)
                count=obj.l(i)/k;
                Y_depth=[Y_depth;linspace(start+eps(start),start+obj.l(i),count+1)'];
                start=sum(obj.l(1:i));
            end
            X_pult=obj.GetPult(Y_depth);
            %             a=plot(ax,obj.private_pult,obj.private_depth,'*');
            %             hold on
            h_curve=plot(ax,X_pult,Y_depth,'k-');   %以变量y为x轴，变量x为y轴
            set(ax,'YDir','reverse')  % 将y轴数值区间的起始点和终止点调换
            title('Pult(N/m)')
            ylabel('z(m)')
            hold on
        end % plot_pult
    end
    %%
    methods(Access='private')
        % 极限承载力的符号表达时所用到的符号表达式。
        function pult=getpultfun(obj)
            % 得到每一层土的极限承载力的符号表达式
            % 对于n层 黏性土/砂性土/岩石层 的统一编程
            % 输出参数：
            % pult      一个向量，向量中以符号变量保存每一层土中任意深度处的极限承载力的表达式。
            %           其中内含的自变量的符号为“pult_z”。
            pult_z=sym('pult_z');
            q=0; %上覆土的重力荷载；不考虑水的重力荷载
            upperLayerType=0; % 上层介质的类型，0代表水。此参数是用来判断是否要将上层土的自重施加于下层土中。
            pult=cell(obj.nlayer,1);
            zstart=0; %土层顶部的深度
            for i=1:obj.nlayer
                switch obj.earthType(i)  %考虑土层类型
                    case 1   % 黏性土
                        np=3+(q+obj.reff(i)*(pult_z-zstart))/obj.cu(i)+obj.J(i)*(pult_z-zstart)/2/obj.R;
                        pult{i}(pult_z)=np*obj.cu(i)*2*obj.R;
                    case 2    %砂性土
                        kp=tan(45*pi/180+obj.phieff(i)/2*pi/180)^2;
                        pult{i}(pult_z)=kp^2*2*obj.R*(q+obj.reff(i)*(pult_z-zstart));
                    case 3    %岩石，smooth socket
                        tmax=0.2*(obj.sigma_c(i)/1e6)^0.5*1e6; %侧面抗剪承载力
                        % 一定要考虑sigma的单位！！
                        if obj.GSI(i)<25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=0;
                            a=0.65-obj.GSI(i)/200;
                        elseif obj.GSI(i)>25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=exp((obj.GSI(i)-100)/9);
                            a=0.5;
                        end
                        normal_limited_resistance=(q+obj.reff(i)*(pult_z-zstart))+obj.sigma_c(i)*(mb*(q+obj.reff(i)*(pult_z-zstart))/obj.sigma_c(i)+s)^a;    % 正方向极限承载力
                        pult{i}(pult_z)=(normal_limited_resistance+tmax)*2*obj.R;
                    case 4     %岩石，rough socket
                        tmax=0.8*(obj.sigma_c(i)/1e6)^0.5*1e6; %侧面抗剪承载力
                        if obj.GSI(i)<25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=0;
                            a=0.65-obj.GSI(i)/200;
                        elseif obj.GSI(i)>25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=exp((obj.GSI(i)-100)/9);
                            a=0.5;
                        end
                        normal_limited_resistance=(q+obj.reff(i)*(pult_z-zstart))+obj.sigma_c(i)*(mb*(q+obj.reff(i)*(pult_z-zstart))/obj.sigma_c(i)+s)^a;    % 正方向极限承载力
                        pult{i}(pult_z)=(normal_limited_resistance+tmax)*2*obj.R;
                end
                % ------------
                % 对于上覆土为砂层时，砂层的自重并不会直接导致下层岩石的极限承载力的增加。
                % 但是从代码设计上而言，这里在逻辑上是有问题的，比如当砂层位于两层岩石中间时，就不能这么写。
                % 所以，这里一定要保证参数条件为：砂层或者黏土层位于所有岩石层的上面。
                if ((obj.earthType(i)==1 || obj.earthType(i)~=2) && (upperLayerType==1 || upperLayerType==2)) ...
                        ||((obj.earthType(i)==3 || obj.earthType(i)~=4) && (upperLayerType==3 || upperLayerType==4))
                    q=q+obj.reff(i)*obj.l(i);  % 考虑reff*(z-suml)的叠加效果
                else  % 遇到砂与岩石的交界时，将上覆荷载清空
                    q=0;
                end
                q=dot(obj.reff(1:i),obj.l(1:i));
                % ------------
                upperLayerType=obj.earthType(i);
                zstart=sum(obj.l(1:i));
            end
        end
        
        % 得到极限承载力的插值向量
        function [depth,pult]=GetDepthPultPare(obj)
            % 根据整个项目工程中的物理参数，得到不同深度处的极限承载力组合向量。
            % 有了这两个向量后，整个土层中的任意深度下的极限承载力，都可以通过线性插值得到
            % 输出参数
            % depth      一个向量，其值的范围从0到桩在土层中的总长，单位为m；
            %            这个向量中必须有几个关键深度值：0、每一层土的底部的深度、
            %            从第一层土开始，其顶部的深度值由于不能与上一层的底部深度相同，所以这层土的第一个深度值取为上一层土的底部深度d再加上eps(d)。
            % pult       一个向量，向量中元素的个数与depth中的元素个数是相等的，
            %            它代表depth中每一个深度处的对应的极限承载力。单位为N/m
            
            % 从第一层开始，在每一层增加相应的插值节点。
            depth=zeros(30,1); % 为向量预定义大小，以避免动态改变数组大小。
            pult=zeros(30,1);  % 为向量预定义大小，以避免动态改变数组大小。
            % 最终结果中，向量中实际包含有所有有效元素的个数。为了避免动态增加数组的尺寸。
            % 也是下一层土开始计算时的起始点的前一个点的点号。
            PointsCount=1;
            % 第一层土的第一个深度点为z=0的点，而不是eps(0)的点，所以要特殊考虑。
            depth(1)=0;
            switch obj.earthType(1)
                case 1  % 黏性土
                    pult(1)=3*obj.cu(1)*obj.J(1);
                case 2  % 砂性土
                    pult(1)=0;
                case 3     %岩石，smooth socket
                    tmax=0.2*(obj.sigma_c(1)/1e6)^0.5*1e6; %侧面抗剪承载力
                    % 一定要考虑sigma的单位！！
                    if obj.GSI(1)<25
                        mb=exp((obj.GSI(1)-100)/28)*obj.mi(1);
                        s=0;
                        a=0.65-obj.GSI(1)/200;
                    elseif obj.GSI(1)>=25
                        mb=exp((obj.GSI(1)-100)/28)*obj.mi(1);
                        s=exp((obj.GSI(1)-100)/9);
                        a=0.5;
                    end
                    normal_limited_resistance=obj.sigma_c(1)*s^a;    % 正方向极限承载力
                    pult(1)=(normal_limited_resistance+tmax)*2*obj.R;
                case 4     %岩石，rough socket
                    tmax=0.8*(obj.sigma_c(1)/1e6)^0.5*1e6; %侧面抗剪承载力
                    % 一定要考虑sigma的单位！！
                    if obj.GSI(1)<25
                        mb=exp((obj.GSI(1)-100)/28)*obj.mi(1);
                        s=0;
                        a=0.65-obj.GSI(1)/200;
                    elseif obj.GSI(1)>=25
                        mb=exp((obj.GSI(1)-100)/28)*obj.mi(1);
                        s=exp((obj.GSI(1)-100)/9);
                        a=0.5;
                    end
                    normal_limited_resistance=obj.sigma_c(1)*s^a;    % 正方向极限承载力
                    pult(1)=(normal_limited_resistance+tmax)*2*obj.R;
            end
            
            % 从第一层开始，在每一层中添加相应的插值点。
            startDepth=0; %土层顶部的深度
            upperLayerType=0; % 上层介质的类型，0代表水。此参数是用来判断是否要将上层土的自重施加于下层土中。
            q=0;    % 本层土的上覆土重，其单位为N/m^2；
            for i=1:obj.nlayer
                switch obj.earthType(i)  %考虑土层类型
                    case 1   % 黏性土，线性增加，加两个点
                        % 第一个点
                        D=startDepth+eps(startDepth); % 此层的顶部深度+eps()。
                        depth(PointsCount+1)=D; % 此层的顶部深度+eps()。
                        pult(PointsCount+1)=obj.cu(i)*2*obj.R*(3+(q+obj.reff(i)*(D-startDepth))/obj.cu(i)+obj.J(i)*(D-startDepth)/2/obj.R);
                        %第二个点
                        D=sum(obj.l(1:i));    % 此层的底部深度
                        depth(PointsCount+2)=D;
                        pult(PointsCount+2)=obj.cu(i)*2*obj.R*(3+(q+obj.reff(i)*(D-startDepth))/obj.cu(i)+obj.J(i)*(D-startDepth)/2/obj.R);
                        %
                        PointsCount=PointsCount+2;
                    case 2    %砂性土，线性增加，加两个点
                        kp=tan(45*pi/180+obj.phieff(i)/2*pi/180)^2;
                        % 第一个点
                        D=startDepth+eps(startDepth); % 此层的顶部深度+eps()。
                        depth(PointsCount+1)=D; % 此层的顶部深度+eps()。
                        pult(PointsCount+1)=kp^2*2*obj.R*(q+obj.reff(i)*(D-startDepth));
                        %第二个点
                        D=sum(obj.l(1:i));    % 此层的底部深度
                        depth(PointsCount+2)=D;
                        pult(PointsCount+2)=kp^2*2*obj.R*(q+obj.reff(i)*(D-startDepth));
                        %
                        PointsCount=PointsCount+2;
                    case 3    %岩石，smooth socket，按一定比例增加6个点。
                        tmax=0.2*(obj.sigma_c(i)/1e6)^0.5*1e6; %侧面抗剪承载力
                        % 一定要考虑sigma的单位！！
                        if obj.GSI(i)<25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=0;
                            a=0.65-obj.GSI(i)/200;
                        elseif obj.GSI(i)>25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=exp((obj.GSI(i)-100)/9);
                            a=0.5;
                        end
                        % 下面这种分布方式是根据论文中给出的极限承载力表达式随深度的变化剧烈程序来分布的。
                        D=startDepth+[eps(startDepth),obj.l(i)*0.05,obj.l(i)*0.1,obj.l(i)*0.2,obj.l(i)*0.35,obj.l(i)*0.6,obj.l(i)]';
                        depth(PointsCount+[1,2,3,4,5,6,7])=D;
                        % 正方向极限承载力，此处为一个向量
                        normal_limited_resistance=(q+obj.reff(i)*(D-startDepth))+obj.sigma_c(i)*(mb*(q+obj.reff(i)*(D-startDepth))/obj.sigma_c(i)+s).^a;
                        pult(PointsCount+[1,2,3,4,5,6,7])=(normal_limited_resistance+tmax)*2*obj.R;
                        %
                        PointsCount=PointsCount+7;
                    case 4     %岩石，rough socket，按一定比例增加6个节点。
                        tmax=0.8*(obj.sigma_c(i)/1e6)^0.5*1e6; %侧面抗剪承载力
                        % 一定要考虑sigma的单位！！
                        if obj.GSI(i)<25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=0;
                            a=0.65-obj.GSI(i)/200;
                        elseif obj.GSI(i)>25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=exp((obj.GSI(i)-100)/9);
                            a=0.5;
                        end
                        % 下面这种分布方式是根据论文中给出的极限承载力表达式随深度的变化剧烈程序来分布的。
                        D=startDepth+[eps(startDepth),obj.l(i)*0.05,obj.l(i)*0.1,obj.l(i)*0.2,obj.l(i)*0.35,obj.l(i)*0.6,obj.l(i)]';
                        depth(PointsCount+[1,2,3,4,5,6,7])=D;
                        % 正方向极限承载力，此处为一个向量
                        normal_limited_resistance=(q+obj.reff(i)*(D-startDepth))+obj.sigma_c(i)*(mb*(q+obj.reff(i)*(D-startDepth))/obj.sigma_c(i)+s).^a;
                        pult(PointsCount+[1,2,3,4,5,6,7])=(normal_limited_resistance+tmax)*2*obj.R;
                        %
                        PointsCount=PointsCount+7;
                end
                % ------------
                % 对于上覆土为砂层时，砂层的自重并不会直接导致下层岩石的极限承载力的增加。
                % 但是从代码设计上而言，这里在逻辑上是有问题的，比如当砂层位于两层岩石中间时，就不能这么写。
                % 所以，这里一定要保证参数条件为：砂层或者黏土层位于所有岩石层的上面。
                if ((obj.earthType(i)==1 || obj.earthType(i)~=2) && (upperLayerType==1 || upperLayerType==2)) ...
                        ||((obj.earthType(i)==3 || obj.earthType(i)~=4) && (upperLayerType==3 || upperLayerType==4))
                    q=q+obj.reff(i)*obj.l(i);  % 考虑reff*(z-suml)的叠加效果
                else  % 遇到砂与岩石的交界时，将上覆荷载清空
                    q=0;
                end
                q=dot(obj.reff(1:i),obj.l(1:i));  % 考虑reff*(z-suml)的叠加效果
                % ------------
                startDepth=sum(obj.l(1:i));
            end
            % 最后调整向量中元素的个数，向量中实际包含的元素个数为PointsCount。
            if PointsCount<30
                depth=depth(1:PointsCount) ;
                pult=pult(1:PointsCount) ;
            end
            
        end
    end
end