classdef FDMResults    %Finite-Different Model Results
    % 此类中定义了在某一次有限差分法计算完成后，所得到的关于这一未屈服段的所有相关参数。
    % 包括其新的物理参数（比如桩长，未屈服段的分层，新的弹性模量分布等）、新的荷载，
    % 以及在这此新条件下计算得到的节点位移u，弯矩M，剪力V，和反力p的分布情况。
    % 属性中所有表示每层土的性质的向量中，下标值越大，表示越靠近桩底。比如在实际的桩中，u{1}所在的土层在u{2}的土层上面。
    % See Also: FINITEDIFFERENCE , FDMPHYSICALCONDITIONS , OriginalProjectParameters
    
    %% 属性
    properties(SetAccess = private)
        %此次有限差分法计算中所用到的物理参数，包括几何参数与荷载条件等，其中包括的字段有：
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
        % Zy     它并不是有限差分法计算中所需要的属性，但是它是作为一个深度的基准值。
        %        由于有限差分法计算时，深度以当前的未屈服区的顶部为基准的；而从全局来说，所有的深度都是以整个土层的顶部的基准的，
        %        所以Zy代表的是开始进行有限差分计算之前，从整个土层的顶部到要进行计算的未屈服区的顶部的长度值。
        physicalConditions
        
        nseg	%	未屈服区中每一层土的分段数
        r	%	本次有限差分法的迭代计算中每一步的gama值，整个过程一共迭代了(length(r)-2)次，第一个值是假设的，没有用，最后一个用来结束循环，不进行有限差分计算。
        u	%	未屈服区中每一层土中的位移分布，每一层土中有nseg+5个位移节点，其中前2个节点与后2个节点是虚拟的，所以u(3)代表的是这层土顶部的第一个节点；
        %   一个元胞数组，其中每一个向量代表未屈服区中每一层土中的转角分布，每个向量中有（nseg+1）个值，代表每一层土中的(nseg+1)个位移节点；
        rotation
        %	一个元胞数组，表示屈服区中每一层土中的反力分布，每一层土中有nseg个反力节点，每一个节点值代表此段的返回平均值。
        %   反力的方向以向左为正（荷载中的H与M以向右为正），所以要注意：pz=-(dQ/dz)，即反力的值是剪力的导数的相反数。
        %   注意，由于在位移u的推导中，剪力连续与弯矩连续是作为边界条件的，所以求得的结果中，
        %       上一层土底部节点的剪力或弯矩值一定是与下一层土顶部节点的对应值是相等的。
        %       但是在不同土层交界面处的反力却并不满足连续性条件。
        pz
        % 由控制方程（5a）得到的反力表达式
        % 此元胞数组中每一个向量中的元素都代表每一个实际的位移节点处的反力值，而不是代表这一段的平均值。
        % 所以向量中元素的个数为nseg+1，而不是nseg个。
        pzFromGoverningEquation
        %       NodeDepth 代表未屈服区的每一个实际的位移节点所对应的深度。
        %       此深度值为正，以未屈服区的顶部节点为基准，即有pz{1}(1)深度处的对应位移为u{1}(3)
        %       但是要注意，从全局来看，全局的深度值是以整个水下土体的顶部（即水中底部位置）为基准的，
        %       所以在绘图时要进行一个换算，即加上整个桩的屈服段的长度值。
        NodeDepth
        %           字段 ShearForce 的值是一个元胞数组，其中包含了nlayer个double数组D；
        %           元素数组D的下标值越大，表示这层未屈服的土越靠近桩的底部。
        %           元素数组D中的元素代表这一层未屈服土中的每一个节点的剪力；
        %           元素数组D中有n+1个值，其每一个值都代表一个真实的结点的剪力。
        ShearForce
        BendingMoment % 其中包含了nlayer个double数组D；数组D中的说明与ShearForce中相同。
        % 整个未屈服区的顶部的水平位移。从位移向量u的节点定义来看，它的值恒等于u{1}(3)
        top_u
        % 整个未屈服区的顶部节点的转角。它的值恒等于rotation{1}(1)
        top_r
    end
    
    %% 构造函数
    methods
        function obj = FDMResults(physicalConditions,nseg,r,u,NodeDepth,ShearForce,BendingMoment,pzFromGoverningEquation)
            if nargin > 0
                obj.physicalConditions = physicalConditions;
                obj.nseg = nseg;
                obj.r = r;
                obj.u = u;
                obj.NodeDepth=NodeDepth;
                obj.ShearForce=ShearForce;
                obj.BendingMoment=BendingMoment;
                obj.pzFromGoverningEquation=pzFromGoverningEquation;
                % 通过计算得到其他的属性并保存下来
                obj.top_u=u{1}(3);
                
                %
                nlayers=length(nseg);
                ro=cell(1,nlayers);
                for i=1:nlayers
                    ro{i}=(obj.u{i}(4:nseg(i)+4)-obj.u{i}(2:obj.nseg(i)+2))/(2*obj.physicalConditions.l(i)/nseg(i));
                end
                obj.rotation=ro;
                obj.top_r=ro{1}(1);
                %
                
                obj.pz=obj.ComputeDistributedReactionForce(nseg,ShearForce);
                [obj.private_pz_depth,obj.private_pz]=obj.GetDepthPzPare();
                
                % 
                obj.pz=pzFromGoverningEquation;
                [obj.private_pz_depth,obj.private_pz]=obj.GetDepthPzPareFromGoverningEquation();
            end
        end % FDMResults
        
        % 得到任意深度下的水平反力
        function load_p=GetPz(obj,z)
            % 由未屈服区中每一层的分段平均反力，进行插值得到任意深度下的水平反力。
            % z     一个向量，函数会根据向量中的每一个值返回对应深度处的反力值；
            %       注意：z的值是相当于此未屈服区的顶部的，而不是相对于整个土层的顶部。
            %       即，z=0是表示未屈服区的顶部的位置。
            load_p=interp1(obj.private_pz_depth,obj.private_pz,z+obj.physicalConditions.Zy);
        end
        
        % 获得未屈服区中的所有的有效节点以及对应的深度（相对于整个嵌固段的顶部）
        function Depth_disp=GetDepth_u(obj)
            % 返回一个拥有两列数据的数组，其中第一列为整个未屈服区所有节点的深度（相对于整个嵌固段的顶部），
            % 其中第一行数据为未屈服区顶部的节点。
            % 第二列为对应深度处的水平位移。
            startpoint=1;
            Depth_disp=zeros(100,2);
            for i=1:length(obj.u)
                l=length(obj.NodeDepth{i});
                endpoint=startpoint+l-2;
                Depth_disp(startpoint:endpoint,1)=obj.NodeDepth{i}(1:end-1)+obj.physicalConditions.Zy;
                Depth_disp(startpoint:endpoint,2)=obj.u{i}(3:end-3);
                startpoint=endpoint+1;
            end
            
            Depth_disp(endpoint+1,[1,2])=[obj.NodeDepth{end}(end)+obj.physicalConditions.Zy,obj.u{end}(end-2)];
            Depth_disp=Depth_disp(1:endpoint+1,:);
        end
    end
    
    %% 绘图
    methods
        % ---------------------------------------------------------------------------------------------------------------
        function curve=plot_Displacement(obj,ax)
            % 在指定的坐标轴中绘制位移分布图
            data_X=obj.u{1}(3:length(obj.u{1})-2);
            data_Y=obj.NodeDepth{1};
            nlayers=length(obj.u);
            if nlayers>1
                for i=2:nlayers
                    % 第一层以后的每一层，都取消其第一个节点，因为这个节点的值与上一层的最后一个节点的值是重复的。
                    data_X=[data_X;obj.u{i}(4:length(obj.u{i})-2)];
                    data_Y=[data_Y;obj.NodeDepth{i}(2:end)];
                end
            end
            data_Y=data_Y+obj.physicalConditions.Zy;
            curve= plot(ax,data_X,data_Y,'g-');
            set(curve, 'linewidth',2)
            set(ax,'YDir','reverse')  % 将y轴数值区间的起始点和终止点调换
            title('Displacement(mm)')
            ylabel('z(m)')
            grid on
            hold on
        end
        
        % ---------------------------------------------------------------------------------------------------------------
        function  curve=plot_Rotation(obj,ax)
            % 在指定的坐标轴中绘制节点转角分布图
            data_X=obj.rotation{1};
            data_Y=obj.NodeDepth{1};
            nlayers=length(obj.rotation);
            if nlayers>1
                for i=2:nlayers
                    % 第一层以后的每一层，都取消其第一个节点，因为这个节点的值与上一层的最后一个节点的值是重复的。
                    data_X=[data_X;obj.rotation{i}(2:end)];
                    data_Y=[data_Y;obj.NodeDepth{i}(2:end)];
                end
            end
            data_Y=data_Y+obj.physicalConditions.Zy;
            curve= plot(ax,data_X,data_Y,'-*');
            set(curve, 'markersize',2)
            set(ax,'YDir','reverse')  % 将y轴数值区间的起始点和终止点调换
            title('Rotation')
            ylabel('z(m)')
            grid on
        end
        
        % ---------------------------------------------------------------------------------------------------------------
        function curve=plot_pz(obj,ax,varargin)
            % 在指定的坐标轴中绘制土层反力分布图
            % 注意：pz属性每一个向量中的元素个数等于此层土的分段数，即每一个元素值代表这层土中的这一段的平均值。
            % 也就是说，pz向量中的元素个数比NodeDepth向量中的元素个数少一个。
            % 输入参数
            % varargin  varargin{1}的值表示是坐标轴中的第几条反力曲线，这是为了在同一坐标轴中对多条反力曲线进行区分。
            Y_depth=obj.private_pz_depth;
            X_pz=interp1(obj.private_pz_depth,obj.private_pz,Y_depth);
            % 绘图
            if isempty(varargin)  % 没有指定这一条反力曲线的编号，即为坐标轴中的第几条反力曲线。
                i=1;
            else
                % varargin{1}的值表示是坐标轴中的第几条反力曲线，这是为了在同一坐标轴中对多条反力曲线进行区分。
                % 区分的主要方式有颜色区分等。
                i=mod(varargin{1},3);
            end
            switch i
                case 1
                    curve=plot(ax,X_pz,Y_depth,'r-*');   %以变量y为x轴，变量x为y轴
                case 2
                    curve=plot(ax,X_pz,Y_depth,'m-*');   %以变量y为x轴，变量x为y轴
                case 0
                    curve=plot(ax,X_pz,Y_depth,'b-*');   %以变量y为x轴，变量x为y轴
            end
            set(curve, 'markersize',2)
            set(ax,'YDir','reverse')  % 将y轴数值区间的起始点和终止点调换
            title('Distributed Reaction Force _ pz (KN/m)')
            ylabel('z(m)')
            grid on
        end
        
        % ---------------------------------------------------------------------------------------------------------------
        function curve=plot_ShearForce(obj,ax)
            % 在指定的坐标轴中绘制剪力分布图
            data_X=obj.ShearForce{1};
            data_Y=obj.NodeDepth{1};
            nlayers=length(obj.ShearForce);
            if nlayers>1
                for i=2:nlayers
                    % 第一层以后的每一层，都取消其第一个节点，因为这个节点的值与上一层的最后一个节点的值是重复的。
                    data_X=[data_X;obj.ShearForce{i}(2:end)];
                    data_Y=[data_Y;obj.NodeDepth{i}(2:end)];
                end
            end
            data_Y=data_Y+obj.physicalConditions.Zy;
            curve= plot(ax,data_X,data_Y,'k-*');
            set(curve, 'markersize',2)
            set(ax,'YDir','reverse')  % 将y轴数值区间的起始点和终止点调换
            title('shear Force (KN)')
            ylabel('z(m)')
            grid on
        end
        
        % ---------------------------------------------------------------------------------------------------------------
        function curve=plot_BendingMoment(obj,ax)
            % 在指定的坐标轴中绘制弯矩分布图
            data_X=obj.BendingMoment{1};
            data_Y=obj.NodeDepth{1};
            nlayers=length(obj.BendingMoment);
            if nlayers>1
                for i=2:nlayers
                    % 第一层以后的每一层，都取消其第一个节点，因为这个节点的值与上一层的最后一个节点的值是重复的。
                    data_X=[data_X;obj.BendingMoment{i}(2:end)];
                    data_Y=[data_Y;obj.NodeDepth{i}(2:end)];
                end
            end
            data_Y=data_Y+obj.physicalConditions.Zy;
            curve= plot(ax,data_X,data_Y,'r-*');
            set(curve, 'markersize',2)
            set(ax,'YDir','reverse')  % 将y轴数值区间的起始点和终止点调换
            title('Bending Moment (KN*m)')
            ylabel('z(m)')
            grid on
        end
    end
    
    %% 私有方法
    methods(Access='private')
        % ---------------------------------------------------------------------------------------------------------------
        function [pz]=ComputeDistributedReactionForce(obj,nseg,ShearForce)
            % p{i}(1)即代表土层段的第1个节点段，即从z=0到z=hs这一段的平均抗力
            % 每一个pz的值所对应的深度位于NodeDepth向量中对应下标处的深度与其下方一个节点对应深度的中间。
            % 即pz{1}(1)所在的深度为NodeDepth{1}(1)与NodeDepth{1}(2)这两个深度值的中间值。
            % 所以向量p的元素个数比向量ShearForce的元素个数少一个。
            nlayer=length(nseg);
            h=obj.physicalConditions.l./nseg;
            pz=cell(1,nlayer);
            for i=1:nlayer
                % 论文中公式（37a）或（37b）
                pz{i}=(ShearForce{i}(1:nseg(i))-ShearForce{i}(2:nseg(i)+1))/h(i);
            end
        end
        
        % ---------------------------------------------------------------------------------------------------------------
        function [depth,postpz]=GetDepthPzPare(obj)
            % 由未屈服区中每一层的分段平均反力，通过一定的后处理操作，得到不同深度depth处的水平反力postpz的组合向量。
            % 有了这两个向量后，整个土层中的任意深度下的水平反力，都可以通过线性插值得到
            % 输出参数
            % depth      一个向量，其值的范围从0到桩在土层中的总长，单位为m；
            %            这个向量中必须有几个关键深度值：0、每一层土的底部的深度、
            %            从第一层土开始，其顶部的深度值由于不能与上一层的底部深度相同，所以这层土的第一个深度值取为上一层土的底部深度d再加上eps(d)。
            % postpz       一个向量，向量中元素的个数与depth中的元素个数是相等的，
            %           其值是通过求得的每一小段中的平均水平反力进行后处理postprocess后所得到的关键节点处的水平反力。
            %            它代表depth中每一个深度处的对应的水平反力。单位为N/m
            %   注意，由于在位移u的推导中，剪力连续与弯矩连续是作为边界条件的，所以求得的结果中，
            %           上一层土底部节点的剪力或弯矩值一定是与下一层土顶部节点的对应值是相等的。
            %           但是在不同土层交界面处的反力却并不满足连续性条件。
            
            %% 参数设置
            %  avgpz为一个向量，代表未屈服区的每一层土的每一段的平均反力；
            % 由于 avgpz 的值表示两节点之间的这一段的平均值，那么对应的任意深度下的反力值可以通过插值得到。
            avgpz=obj.pz;
            l=obj.physicalConditions.l;
            Zy=obj.physicalConditions.Zy;
            % 定义一个匿名函数，用来外推求得指定深度处的水平反力值。根据点(x1,y1)与(x2,y2)来外推x3处的y3值。
            outfit=@(x1,y1,x2,y2,x3) ((x3-x1)*y2-(x3-x2)*y1)/(x2-x1);
            % 从第一层开始，在每一层增加相应的插值节点。
            depth=zeros(80,1); % 为向量预定义大小，以避免动态改变数组大小。
            postpz=zeros(80,1);  % 为向量预定义大小，以避免动态改变数组大小。
            PointsCount=1; % 最终结果中，向量中实际包含有所有有效元素的个数。为了避免动态增加数组的尺寸。也是下一层土开始计算时的起始点的前一个点的点号。
            % 第一层土的第一个深度点为z=0的点，而不是eps(0)的点，所以要特殊考虑。
            depth(1)=Zy;
            postpz(1)=outfit(0.5,avgpz{1}(1),1.5,avgpz{1}(2),0);
            % 从第一层开始，在每一层中添加相应的插值点。
            startDepth=Zy; %土层顶部的深度
            for i=1:obj.physicalConditions.nlayer
                h=l(i)/obj.nseg(i);   % 这一层土的每一小段的长度
                % 此层的顶部节点
                depth(PointsCount+1)=startDepth+eps(startDepth);
                postpz(PointsCount+1)=outfit(0.5*h,avgpz{i}(1),1.5*h,avgpz{i}(2),eps(startDepth));
                % 此层的中间节点，即从h/2到（l-h/2）的n个点
                depth(PointsCount+(2:(obj.nseg(i)+1)))=linspace(startDepth+0.5*h,startDepth+l(i)-0.5*h,obj.nseg(i)); %从h/2到（l-h/2）的n个点
                postpz(PointsCount+(2:(obj.nseg(i)+1)))=obj.pz{i};
                % 此层的底部节点
                depth(PointsCount+obj.nseg(i)+2)=startDepth+l(i);
                postpz(PointsCount+obj.nseg(i)+2)=outfit(0,obj.pz{i}(end-1),1,obj.pz{i}(end),1.5);
                %
                PointsCount=PointsCount+obj.nseg(i)+2;
                startDepth=startDepth+l(i);
            end
            % 最后调整向量中元素的个数，向量中实际包含的元素个数为PointsCount。
            if PointsCount<80
                depth=depth(1:PointsCount) ;
                postpz=postpz(1:PointsCount) ;
            end
        end
        
        % 从由控制方程得到的反力pz向量来反力“深度-反力”向量组。
         function [depth,postpz]=GetDepthPzPareFromGoverningEquation(obj)
             Zy=obj.physicalConditions.Zy;
             NodesCount=sum(obj.nseg)+length(obj.nseg)+1;
             depth=zeros(NodesCount,1);
             postpz=zeros(NodesCount,1);
             %
             depth(1)=Zy;
             postpz(1)=obj.pzFromGoverningEquation{1}(1);
             start=2;
             for i=1:obj.physicalConditions.nlayer
                 n=obj.nseg(i);
                 depth(start:start+n)=obj.NodeDepth{i}+Zy;
                 depth(start)=depth(start)+eps(depth(start));
                 %
                 postpz(start:start+n)=obj.pzFromGoverningEquation{i};
                 start=start+n+1;
             end
         end
    end
    
    %% 专为对未屈服区的每一层土中的分段平均反力进行后处理所需要的变量
    properties(GetAccess=private,SetAccess=private)
        % 深度-反力向量组中的深度向量。
        % 注意：此向量中的深度值是相对于整个土层顶部，而不是相对于未屈服区的顶部的。
        % 此向量中必须包含几个关键深度值：Zy（即未屈服区顶部），每层土的顶部（实际为此层顶+eps），每层土的底部。
        private_pz_depth
        % 对应深度处的水平反力。
        private_pz
    end    
end