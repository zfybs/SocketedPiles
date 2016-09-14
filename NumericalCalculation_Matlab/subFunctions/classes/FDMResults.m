classdef FDMResults    %Finite-Different Model Results
    % �����ж�������ĳһ�����޲�ַ�������ɺ����õ��Ĺ�����һδ�����ε�������ز�����
    % �������µ��������������׮����δ�����εķֲ㣬�µĵ���ģ���ֲ��ȣ����µĺ��أ�
    % �Լ�������������¼���õ��Ľڵ�λ��u�����M������V���ͷ���p�ķֲ������
    % ���������б�ʾÿ���������ʵ������У��±�ֵԽ�󣬱�ʾԽ����׮�ס�������ʵ�ʵ�׮�У�u{1}���ڵ�������u{2}���������档
    % See Also: FINITEDIFFERENCE , FDMPHYSICALCONDITIONS , OriginalProjectParameters
    
    %% ����
    properties(SetAccess = private)
        %�˴����޲�ַ����������õ�������������������β�������������ȣ����а������ֶ��У�
        % R      ׮�İ뾶������һ����������
        % l      �µķ������ε�׮���ܳ�������ͨ�����޲�ַ�����õ��ķ����ֲ�������ļ��޳������ֲ�
        %        ���бȽϺ�õ��ĳ��ȣ���p_z<p_ult��׮�εĳ��ȣ�
        % ep     ׮�ĵ���ģ��������һ����������
        % ip     ׮�Ĺ��Ծأ�����һ����������
        % e1     ����һ��������������δ��������ÿһ�����Ķ����ĵ���ģ����
        % e2     ����һ��������������δ��������ÿһ�����ĵײ��ĵ���ģ����������м�ĵ���ģ������Ϊ�����Էֲ��ģ�
        % v      ����һ��������������δ��������ÿһ�����Ĳ��ɱȣ�
        % H      �µ�δ����׮�εĶ�����ˮƽ���أ�
        % M      �µ�δ����׮�εĶ�������أ�
        % nlayer �µ�δ����׮����ռ����������
        % Zy     �����������޲�ַ�����������Ҫ�����ԣ�����������Ϊһ����ȵĻ�׼ֵ��
        %        �������޲�ַ�����ʱ������Ե�ǰ��δ�������Ķ���Ϊ��׼�ģ�����ȫ����˵�����е���ȶ�������������Ķ����Ļ�׼�ģ�
        %        ����Zy������ǿ�ʼ�������޲�ּ���֮ǰ������������Ķ�����Ҫ���м����δ�������Ķ����ĳ���ֵ��
        physicalConditions
        
        nseg	%	δ��������ÿһ�����ķֶ���
        r	%	�������޲�ַ��ĵ���������ÿһ����gamaֵ����������һ��������(length(r)-2)�Σ���һ��ֵ�Ǽ���ģ�û���ã����һ����������ѭ�������������޲�ּ��㡣
        u	%	δ��������ÿһ�����е�λ�Ʒֲ���ÿһ��������nseg+5��λ�ƽڵ㣬����ǰ2���ڵ����2���ڵ�������ģ�����u(3)�����������������ĵ�һ���ڵ㣻
        %   һ��Ԫ�����飬����ÿһ����������δ��������ÿһ�����е�ת�Ƿֲ���ÿ���������У�nseg+1����ֵ������ÿһ�����е�(nseg+1)��λ�ƽڵ㣻
        rotation
        %	һ��Ԫ�����飬��ʾ��������ÿһ�����еķ����ֲ���ÿһ��������nseg�������ڵ㣬ÿһ���ڵ�ֵ����˶εķ���ƽ��ֵ��
        %   �����ķ���������Ϊ���������е�H��M������Ϊ����������Ҫע�⣺pz=-(dQ/dz)����������ֵ�Ǽ����ĵ������෴����
        %   ע�⣬������λ��u���Ƶ��У����������������������Ϊ�߽������ģ�������õĽ���У�
        %       ��һ�����ײ��ڵ�ļ��������ֵһ��������һ���������ڵ�Ķ�Ӧֵ����ȵġ�
        %       �����ڲ�ͬ���㽻���洦�ķ���ȴ��������������������
        pz
        % �ɿ��Ʒ��̣�5a���õ��ķ������ʽ
        % ��Ԫ��������ÿһ�������е�Ԫ�ض�����ÿһ��ʵ�ʵ�λ�ƽڵ㴦�ķ���ֵ�������Ǵ�����һ�ε�ƽ��ֵ��
        % ����������Ԫ�صĸ���Ϊnseg+1��������nseg����
        pzFromGoverningEquation
        %       NodeDepth ����δ��������ÿһ��ʵ�ʵ�λ�ƽڵ�����Ӧ����ȡ�
        %       �����ֵΪ������δ�������Ķ����ڵ�Ϊ��׼������pz{1}(1)��ȴ��Ķ�Ӧλ��Ϊu{1}(3)
        %       ����Ҫע�⣬��ȫ��������ȫ�ֵ����ֵ��������ˮ������Ķ�������ˮ�еײ�λ�ã�Ϊ��׼�ģ�
        %       �����ڻ�ͼʱҪ����һ�����㣬����������׮�������εĳ���ֵ��
        NodeDepth
        %           �ֶ� ShearForce ��ֵ��һ��Ԫ�����飬���а�����nlayer��double����D��
        %           Ԫ������D���±�ֵԽ�󣬱�ʾ���δ��������Խ����׮�ĵײ���
        %           Ԫ������D�е�Ԫ�ش�����һ��δ�������е�ÿһ���ڵ�ļ�����
        %           Ԫ������D����n+1��ֵ����ÿһ��ֵ������һ����ʵ�Ľ��ļ�����
        ShearForce
        BendingMoment % ���а�����nlayer��double����D������D�е�˵����ShearForce����ͬ��
        % ����δ�������Ķ�����ˮƽλ�ơ���λ������u�Ľڵ㶨������������ֵ�����u{1}(3)
        top_u
        % ����δ�������Ķ����ڵ��ת�ǡ�����ֵ�����rotation{1}(1)
        top_r
    end
    
    %% ���캯��
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
                % ͨ������õ����������Բ���������
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
        
        % �õ���������µ�ˮƽ����
        function load_p=GetPz(obj,z)
            % ��δ��������ÿһ��ķֶ�ƽ�����������в�ֵ�õ���������µ�ˮƽ������
            % z     һ����������������������е�ÿһ��ֵ���ض�Ӧ��ȴ��ķ���ֵ��
            %       ע�⣺z��ֵ���൱�ڴ�δ�������Ķ����ģ��������������������Ķ�����
            %       ����z=0�Ǳ�ʾδ�������Ķ�����λ�á�
            load_p=interp1(obj.private_pz_depth,obj.private_pz,z+obj.physicalConditions.Zy);
        end
        
        % ���δ�������е����е���Ч�ڵ��Լ���Ӧ����ȣ����������Ƕ�̶εĶ�����
        function Depth_disp=GetDepth_u(obj)
            % ����һ��ӵ���������ݵ����飬���е�һ��Ϊ����δ���������нڵ����ȣ����������Ƕ�̶εĶ�������
            % ���е�һ������Ϊδ�����������Ľڵ㡣
            % �ڶ���Ϊ��Ӧ��ȴ���ˮƽλ�ơ�
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
    
    %% ��ͼ
    methods
        % ---------------------------------------------------------------------------------------------------------------
        function curve=plot_Displacement(obj,ax)
            % ��ָ�����������л���λ�Ʒֲ�ͼ
            data_X=obj.u{1}(3:length(obj.u{1})-2);
            data_Y=obj.NodeDepth{1};
            nlayers=length(obj.u);
            if nlayers>1
                for i=2:nlayers
                    % ��һ���Ժ��ÿһ�㣬��ȡ�����һ���ڵ㣬��Ϊ����ڵ��ֵ����һ������һ���ڵ��ֵ���ظ��ġ�
                    data_X=[data_X;obj.u{i}(4:length(obj.u{i})-2)];
                    data_Y=[data_Y;obj.NodeDepth{i}(2:end)];
                end
            end
            data_Y=data_Y+obj.physicalConditions.Zy;
            curve= plot(ax,data_X,data_Y,'g-');
            set(curve, 'linewidth',2)
            set(ax,'YDir','reverse')  % ��y����ֵ�������ʼ�����ֹ�����
            title('Displacement(mm)')
            ylabel('z(m)')
            grid on
            hold on
        end
        
        % ---------------------------------------------------------------------------------------------------------------
        function  curve=plot_Rotation(obj,ax)
            % ��ָ�����������л��ƽڵ�ת�Ƿֲ�ͼ
            data_X=obj.rotation{1};
            data_Y=obj.NodeDepth{1};
            nlayers=length(obj.rotation);
            if nlayers>1
                for i=2:nlayers
                    % ��һ���Ժ��ÿһ�㣬��ȡ�����һ���ڵ㣬��Ϊ����ڵ��ֵ����һ������һ���ڵ��ֵ���ظ��ġ�
                    data_X=[data_X;obj.rotation{i}(2:end)];
                    data_Y=[data_Y;obj.NodeDepth{i}(2:end)];
                end
            end
            data_Y=data_Y+obj.physicalConditions.Zy;
            curve= plot(ax,data_X,data_Y,'-*');
            set(curve, 'markersize',2)
            set(ax,'YDir','reverse')  % ��y����ֵ�������ʼ�����ֹ�����
            title('Rotation')
            ylabel('z(m)')
            grid on
        end
        
        % ---------------------------------------------------------------------------------------------------------------
        function curve=plot_pz(obj,ax,varargin)
            % ��ָ�����������л������㷴���ֲ�ͼ
            % ע�⣺pz����ÿһ�������е�Ԫ�ظ������ڴ˲����ķֶ�������ÿһ��Ԫ��ֵ����������е���һ�ε�ƽ��ֵ��
            % Ҳ����˵��pz�����е�Ԫ�ظ�����NodeDepth�����е�Ԫ�ظ�����һ����
            % �������
            % varargin  varargin{1}��ֵ��ʾ���������еĵڼ����������ߣ�����Ϊ����ͬһ�������жԶ����������߽������֡�
            Y_depth=obj.private_pz_depth;
            X_pz=interp1(obj.private_pz_depth,obj.private_pz,Y_depth);
            % ��ͼ
            if isempty(varargin)  % û��ָ����һ���������ߵı�ţ���Ϊ�������еĵڼ����������ߡ�
                i=1;
            else
                % varargin{1}��ֵ��ʾ���������еĵڼ����������ߣ�����Ϊ����ͬһ�������жԶ����������߽������֡�
                % ���ֵ���Ҫ��ʽ����ɫ���ֵȡ�
                i=mod(varargin{1},3);
            end
            switch i
                case 1
                    curve=plot(ax,X_pz,Y_depth,'r-*');   %�Ա���yΪx�ᣬ����xΪy��
                case 2
                    curve=plot(ax,X_pz,Y_depth,'m-*');   %�Ա���yΪx�ᣬ����xΪy��
                case 0
                    curve=plot(ax,X_pz,Y_depth,'b-*');   %�Ա���yΪx�ᣬ����xΪy��
            end
            set(curve, 'markersize',2)
            set(ax,'YDir','reverse')  % ��y����ֵ�������ʼ�����ֹ�����
            title('Distributed Reaction Force _ pz (KN/m)')
            ylabel('z(m)')
            grid on
        end
        
        % ---------------------------------------------------------------------------------------------------------------
        function curve=plot_ShearForce(obj,ax)
            % ��ָ�����������л��Ƽ����ֲ�ͼ
            data_X=obj.ShearForce{1};
            data_Y=obj.NodeDepth{1};
            nlayers=length(obj.ShearForce);
            if nlayers>1
                for i=2:nlayers
                    % ��һ���Ժ��ÿһ�㣬��ȡ�����һ���ڵ㣬��Ϊ����ڵ��ֵ����һ������һ���ڵ��ֵ���ظ��ġ�
                    data_X=[data_X;obj.ShearForce{i}(2:end)];
                    data_Y=[data_Y;obj.NodeDepth{i}(2:end)];
                end
            end
            data_Y=data_Y+obj.physicalConditions.Zy;
            curve= plot(ax,data_X,data_Y,'k-*');
            set(curve, 'markersize',2)
            set(ax,'YDir','reverse')  % ��y����ֵ�������ʼ�����ֹ�����
            title('shear Force (KN)')
            ylabel('z(m)')
            grid on
        end
        
        % ---------------------------------------------------------------------------------------------------------------
        function curve=plot_BendingMoment(obj,ax)
            % ��ָ�����������л�����طֲ�ͼ
            data_X=obj.BendingMoment{1};
            data_Y=obj.NodeDepth{1};
            nlayers=length(obj.BendingMoment);
            if nlayers>1
                for i=2:nlayers
                    % ��һ���Ժ��ÿһ�㣬��ȡ�����һ���ڵ㣬��Ϊ����ڵ��ֵ����һ������һ���ڵ��ֵ���ظ��ġ�
                    data_X=[data_X;obj.BendingMoment{i}(2:end)];
                    data_Y=[data_Y;obj.NodeDepth{i}(2:end)];
                end
            end
            data_Y=data_Y+obj.physicalConditions.Zy;
            curve= plot(ax,data_X,data_Y,'r-*');
            set(curve, 'markersize',2)
            set(ax,'YDir','reverse')  % ��y����ֵ�������ʼ�����ֹ�����
            title('Bending Moment (KN*m)')
            ylabel('z(m)')
            grid on
        end
    end
    
    %% ˽�з���
    methods(Access='private')
        % ---------------------------------------------------------------------------------------------------------------
        function [pz]=ComputeDistributedReactionForce(obj,nseg,ShearForce)
            % p{i}(1)����������εĵ�1���ڵ�Σ�����z=0��z=hs��һ�ε�ƽ������
            % ÿһ��pz��ֵ����Ӧ�����λ��NodeDepth�����ж�Ӧ�±괦����������·�һ���ڵ��Ӧ��ȵ��м䡣
            % ��pz{1}(1)���ڵ����ΪNodeDepth{1}(1)��NodeDepth{1}(2)���������ֵ���м�ֵ��
            % ��������p��Ԫ�ظ���������ShearForce��Ԫ�ظ�����һ����
            nlayer=length(nseg);
            h=obj.physicalConditions.l./nseg;
            pz=cell(1,nlayer);
            for i=1:nlayer
                % �����й�ʽ��37a����37b��
                pz{i}=(ShearForce{i}(1:nseg(i))-ShearForce{i}(2:nseg(i)+1))/h(i);
            end
        end
        
        % ---------------------------------------------------------------------------------------------------------------
        function [depth,postpz]=GetDepthPzPare(obj)
            % ��δ��������ÿһ��ķֶ�ƽ��������ͨ��һ���ĺ���������õ���ͬ���depth����ˮƽ����postpz�����������
            % �������������������������е���������µ�ˮƽ������������ͨ�����Բ�ֵ�õ�
            % �������
            % depth      һ����������ֵ�ķ�Χ��0��׮�������е��ܳ�����λΪm��
            %            ��������б����м����ؼ����ֵ��0��ÿһ�����ĵײ�����ȡ�
            %            �ӵ�һ������ʼ���䶥�������ֵ���ڲ�������һ��ĵײ������ͬ������������ĵ�һ�����ֵȡΪ��һ�����ĵײ����d�ټ���eps(d)��
            % postpz       һ��������������Ԫ�صĸ�����depth�е�Ԫ�ظ�������ȵģ�
            %           ��ֵ��ͨ����õ�ÿһС���е�ƽ��ˮƽ�������к���postprocess�����õ��Ĺؼ��ڵ㴦��ˮƽ������
            %            ������depth��ÿһ����ȴ��Ķ�Ӧ��ˮƽ��������λΪN/m
            %   ע�⣬������λ��u���Ƶ��У����������������������Ϊ�߽������ģ�������õĽ���У�
            %           ��һ�����ײ��ڵ�ļ��������ֵһ��������һ���������ڵ�Ķ�Ӧֵ����ȵġ�
            %           �����ڲ�ͬ���㽻���洦�ķ���ȴ��������������������
            
            %% ��������
            %  avgpzΪһ������������δ��������ÿһ������ÿһ�ε�ƽ��������
            % ���� avgpz ��ֵ��ʾ���ڵ�֮�����һ�ε�ƽ��ֵ����ô��Ӧ����������µķ���ֵ����ͨ����ֵ�õ���
            avgpz=obj.pz;
            l=obj.physicalConditions.l;
            Zy=obj.physicalConditions.Zy;
            % ����һ�����������������������ָ����ȴ���ˮƽ����ֵ�����ݵ�(x1,y1)��(x2,y2)������x3����y3ֵ��
            outfit=@(x1,y1,x2,y2,x3) ((x3-x1)*y2-(x3-x2)*y1)/(x2-x1);
            % �ӵ�һ�㿪ʼ����ÿһ��������Ӧ�Ĳ�ֵ�ڵ㡣
            depth=zeros(80,1); % Ϊ����Ԥ�����С���Ա��⶯̬�ı������С��
            postpz=zeros(80,1);  % Ϊ����Ԥ�����С���Ա��⶯̬�ı������С��
            PointsCount=1; % ���ս���У�������ʵ�ʰ�����������ЧԪ�صĸ�����Ϊ�˱��⶯̬��������ĳߴ硣Ҳ����һ������ʼ����ʱ����ʼ���ǰһ����ĵ�š�
            % ��һ�����ĵ�һ����ȵ�Ϊz=0�ĵ㣬������eps(0)�ĵ㣬����Ҫ���⿼�ǡ�
            depth(1)=Zy;
            postpz(1)=outfit(0.5,avgpz{1}(1),1.5,avgpz{1}(2),0);
            % �ӵ�һ�㿪ʼ����ÿһ���������Ӧ�Ĳ�ֵ�㡣
            startDepth=Zy; %���㶥�������
            for i=1:obj.physicalConditions.nlayer
                h=l(i)/obj.nseg(i);   % ��һ������ÿһС�εĳ���
                % �˲�Ķ����ڵ�
                depth(PointsCount+1)=startDepth+eps(startDepth);
                postpz(PointsCount+1)=outfit(0.5*h,avgpz{i}(1),1.5*h,avgpz{i}(2),eps(startDepth));
                % �˲���м�ڵ㣬����h/2����l-h/2����n����
                depth(PointsCount+(2:(obj.nseg(i)+1)))=linspace(startDepth+0.5*h,startDepth+l(i)-0.5*h,obj.nseg(i)); %��h/2����l-h/2����n����
                postpz(PointsCount+(2:(obj.nseg(i)+1)))=obj.pz{i};
                % �˲�ĵײ��ڵ�
                depth(PointsCount+obj.nseg(i)+2)=startDepth+l(i);
                postpz(PointsCount+obj.nseg(i)+2)=outfit(0,obj.pz{i}(end-1),1,obj.pz{i}(end),1.5);
                %
                PointsCount=PointsCount+obj.nseg(i)+2;
                startDepth=startDepth+l(i);
            end
            % ������������Ԫ�صĸ�����������ʵ�ʰ�����Ԫ�ظ���ΪPointsCount��
            if PointsCount<80
                depth=depth(1:PointsCount) ;
                postpz=postpz(1:PointsCount) ;
            end
        end
        
        % ���ɿ��Ʒ��̵õ��ķ���pz���������������-�����������顣
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
    
    %% רΪ��δ��������ÿһ�����еķֶ�ƽ���������к�������Ҫ�ı���
    properties(GetAccess=private,SetAccess=private)
        % ���-�����������е����������
        % ע�⣺�������е����ֵ��������������㶥���������������δ�������Ķ����ġ�
        % �������б�����������ؼ����ֵ��Zy����δ��������������ÿ�����Ķ�����ʵ��Ϊ�˲㶥+eps����ÿ�����ĵײ���
        private_pz_depth
        % ��Ӧ��ȴ���ˮƽ������
        private_pz
    end    
end