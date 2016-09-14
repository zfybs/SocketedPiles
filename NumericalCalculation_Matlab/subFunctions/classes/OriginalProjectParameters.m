classdef OriginalProjectParameters
    %  �������������һ��������Ŀ����������ȫ��ԭʼ����
    %  ����һ����19�����ԣ�������Щ����ȫ����ֻ���ġ�
    %  �����ϸ���Ϊɰ��ʱ��ɰ������ز�����ֱ�ӵ����²���ʯ�ļ��޳����������ӡ�
    % See AlsO: FINITEDIFFERENCE , FDMRESULTS , FDMphysicalConditions , pileType
    properties(SetAccess=public)
        % һ������������ÿһ���������͡���������earthType��4�֣�
        % �ֱ���clay��sand��rock_smooth�����г�����ϵ��Ϊ0.2����rock_rough�����г�����ϵ��Ϊ0.8����
        % ��Ӧ��earthTypeֵ�ֱ�Ϊ1��2��3��4��
        earthType
        % ÿһ������׮�Ľ������ͣ��˽������Ϳ�����ն�ֵ�����ҿ����˴˽���Ŀ�����ء�������أ��Լ��������ص����Ӷ����µĿ���ն�˥���ķ�ʽ��
        % �����Բ�һ��Ҫ��ֵ����������׮����������¿��Ѻ�ĸնȼ�Сʱ�������Կ���Ϊ�ա�������֮��ص�epip������һ���и�ֵ�ġ�
        PileType
        % ˮ��׮�ε�׮�������͡�Ĭ��ˮ��׮�εĽ��涼��һ�µġ�
        PileType_Water
        GSI	%һ������������ÿ����ʯ��ĵ���ǿ��ָ�� Geological Strength Index
        J	%һ������������ÿ���������ĳ��ϵ������ֵ�ķ�ΧΪ0.25~0.5��
        %  һ����������ʾ����׮�������еĵ�Ч�뾶�����ڻ������޲�ַ��еļ��㣬��λΪm��
        %  ����׮�Ǳ����ģ����������R��һ����Чֵ��������һ�����޲�ֵļ���������ǲ���ģ�
        %  ��׮�Ŀ����Լ��ն��ۼ��Ĺ����У����ֵ����Ҳ��Ϊ����һ����������
        R
        cu	%һ������������ÿ��������ļ��޳�����ָ�꣬��������Ĳ���ˮ����ǿ�ȣ�
        e1	%һ������������ÿ�����Ķ��˵ĵ���ģ������λΪPa
        e2	%һ������������ÿ�����ĵײ��ĵ���ģ������λΪPa����һ�����У��䵯��ģ���ǰ����Էֲ��ģ�
        epip_water %׮��ˮ�в��ֵĿ���նȣ���λΪPa*m^4�����ģ��ֵר����������ˮ��׮������������µĵ�����Ӧ��
        %         ip	%׮�Ĺ��Ծأ���׮�ļ�����״������
        l	% һ�����������������㶥������׮�׵�ÿһ�����ĳ��ȣ���Ȼ�� sum(l) = ׮�����еĵ��ܳ��ȣ���λΪm��
        lw	%׮��ˮ�е���һ�εĳ��ȣ���λΪm��
        mi	%һ������������ÿ����ʯ���
        nlayer	%һ��������ָʾ׮������һ��ռ���˼��㣻
        phieff	%һ������������ÿ��ɰ��������ЧĦ���ǣ���phi_effective����λΪdegree�����ǻ��ȡ�
        reff	%һ������������ÿ��������Ч�ضȣ���effective unit weight����λΪN/m^3��
        sigma_c	%һ������������ÿ����ʯ����޲��޿�ѹǿ�ȣ���λΪPa��
        v	%һ������������ÿ�����Ĳ��ɱ�
        %       ��������ļ��޳��������ʽ��������Ϊһ��Ԫ�����飬�������Է��ű�������ÿһ������������ȴ��ļ��޳������ı��ʽ��
        %       ��ȷ���µ�������󣬽�������������޸�ʱ�������ô˷��ű��������л�������
        %       �����ں����Ա����ķ���Ϊ��pult_z����
        pultfun
    end
    
    properties(SetAccess=public)
        H	%׮���������㶥��������׮�Ķ��������ܵ���ˮƽ������λΪN����Ĭ�Ϸ������ҡ�
        M	%׮���������㶥��������׮�Ķ��������ܵ�����أ���λΪ����Ĭ�Ϸ���Ϊ˳ʱ�룬��λΪN*m��
        % һ�������������������޲�ַ�����ʱ��Ƕ�벿�ֵ�ÿһ���е�׮�Ŀ���նȣ���λΪ Pa��
        % �ڳ�ʼʱ����������Ǵ�׮������δ����ǰ�Ŀ���նȣ�
        % �ڼ�����ڣ����׮�����������������ֵ���޸�Ϊ������Ŀ���ն�ֵ�����������޲�ַ��н��м��㡣
        % ��׮�ĸ�����׮���������Ͳ����׮��ʱ����epֵ���ܿ���ep*ip�նȲ��������е�Ч��
        epip
    end
    
    properties(SetAccess=private)
        % Ƕ��׮������
        ShaftName
    end
    
    properties(GetAccess=private,SetAccess=private)
        % ����������ר��������������ȴ��ļ��޳�����ʱ�Ĳ�ֵ����
        private_depth
        private_pult
    end
    
    %%
    methods
        % -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        function obj = OriginalProjectParameters(shaftName, earthType,GSI,J,R,cu,e1,e2,epip,l,lw, ...
                mi,nlayer,phieff,reff,sigma_c,v,varargin)
            % �������˵��
            % earthType��һ������������ÿһ���������͡���������earthType��4�֣��ֱ���clay��sand��rock_smooth�����г�����ϵ��Ϊ0.2����rock_rough�����г�����ϵ��Ϊ0.8������Ӧ��earthTypeֵ�ֱ�Ϊ1��2��3��4��
            % GSI��һ������������ÿ����ʯ��ĵ���ǿ��ָ�� Geological Strength Index
            % J��һ������������ÿ���������
            % R�� һ����������ʾ����׮�İ뾶����λΪm������׮�Ǳ����ģ����������R��һ����Чֵ��������һ�����޲�ֵļ���������ǲ���ģ�
            % cu��һ������������ÿ��������ļ��޳�����ָ�꣬��������Ĳ���ˮ����ǿ�ȣ�
            % e1��һ������������ÿ�����Ķ��˵ĵ���ģ������λΪMPa
            % e2��һ������������ÿ�����ĵײ��ĵ���ģ������λΪMPa����һ�����У��䵯��ģ���ǰ����Էֲ��ģ�
            % ep��׮��Ƕ�벿�ֵĵ���ģ������λΪPa����׮�ĸ�����׮���������Ͳ����׮��ʱ����epֵ���ܿ���ep*ip�նȲ��������е�Ч��
            % epw�� ׮��ˮ�в��ֵĵ���ģ������λΪPa�����ģ��ֵר����������ˮ��׮������������µĵ�����Ӧ��
            % ip��׮�Ĺ��Ծأ���׮�ļ�����״������
            % l��׮���ܳ���
            % lw��׮��ˮ�е���һ�εĳ���
            % mi��һ������������ÿ����ʯ���
            % nlayer��һ��������ָʾ׮������һ��ռ���˼��㣻
            %��phieff��һ������������ÿ��ɰ��������ЧĦ����
            % reff��һ������������ÿ��������Ч�ض�
            % sigma_c��һ������������ÿ����ʯ����޲��޿�ѹǿ��
            % v��һ������������ÿ�����Ĳ��ɱ�
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
                % ����õ�һЩ����ֵ
                obj.pultfun=obj.getpultfun;
                [obj.private_depth,obj.private_pult]=obj.GetDepthPultPare;
                
                % ���Ҫ����׮����������¸նȵ��½�����Ӧ��ΪpileType���Ը�ֵ�����򣬿��Բ�Ϊ������Ը�ֵ��
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
        % ���ü��޳������ķ��ű��ʽ������ȡָ����ȴ��ļ��޳�����������
        function pult=GetPult_symfun(obj,z)
            % ��ָ�������λ�÷��ض�Ӧ�ļ��޳�����������ʵ�ֵķ���Ϊ����ÿһ�����ֵ����Ӧ�ķ��ź�����ֵ��
            % �˺���һ�㲻����ʵ�ʵĵ��ã���Ϊ��ʱ̫����ͬ���Ĺ��ܿ���ͨ����ֵ��ֵ��ʵ�֡�
            % �������
            % z 	һ�����������������������Է���ָ�����λ�õļ��޳�������
            %       z ��ֵ���������������Ķ�������׮��ˮ��ĵײ�λ�ã��ģ�������δ�����εĶ���λ�Ƶġ�
            %       ����pultfun�к��еķ���Ϊpult_z������pult�������Ա���ֻ����Ϊpult_z��
            %       �����Ϊ�����������ͻ����subs���ܸ�ֵ��������Ӷ�����
            % ���������
            % pult 	һ����ֵ������������ָ����zλ�ô��ļ��޳�����
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
        % �������������Բ�ֵ������ָ�������λ�ô���Ӧ�ļ��޳�����������
        function  p=GetPult(obj,z)
            % ��ָ�������λ�÷��ض�Ӧ�ļ��޳�����������ʵ�ֵķ���Ϊ���������Բ�ֵ��
            %   ����ķ���Ϊ�����������Ѿ��õ��� depth �� pult ��������������p=interp1(depth,pult,z)�����������Բ�ֵ���ɡ�
            % �������
            % z 	һ�����������������������Է���ָ�����λ�õļ��޳�������
            %       z ��ֵ���������������Ķ�������׮��ˮ��ĵײ�λ�ã��ģ�������δ�����εĶ���λ�Ƶġ�
            % ���������
            % p 	һ��������������ָ����zλ�ô��ļ��޳�����
            p=interp1(obj.private_depth,obj.private_pult,z);
        end % GetPult
        
        % -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        function h_curve=plot_pult(obj,ax)
            % ���ƴ���������Ķ���������׮�ĵײ��ļ��޳������ֲ�����
            % ax ����ͼ�λ��Ƶ�������ľ��ֵ��
            % ��ͼ�Ľڵ���ܶȴ��ȡΪ2cmһ�Ρ�
            k=0.02;
            % �������ִ���X_depth��Ϊ�˱�֤�ڲ�ͬ���㽻���洦����ȡ����Ӧ�ĵ㣬�Ӷ��ڻ�ͼʱ������©���紦�Ĺؼ����ݡ�
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
            h_curve=plot(ax,X_pult,Y_depth,'k-');   %�Ա���yΪx�ᣬ����xΪy��
            set(ax,'YDir','reverse')  % ��y����ֵ�������ʼ�����ֹ�����
            title('Pult(N/m)')
            ylabel('z(m)')
            hold on
        end % plot_pult
    end
    %%
    methods(Access='private')
        % ���޳������ķ��ű��ʱ���õ��ķ��ű��ʽ��
        function pult=getpultfun(obj)
            % �õ�ÿһ�����ļ��޳������ķ��ű��ʽ
            % ����n�� �����/ɰ����/��ʯ�� ��ͳһ���
            % ���������
            % pult      һ���������������Է��ű�������ÿһ������������ȴ��ļ��޳������ı��ʽ��
            %           �����ں����Ա����ķ���Ϊ��pult_z����
            pult_z=sym('pult_z');
            q=0; %�ϸ������������أ�������ˮ����������
            upperLayerType=0; % �ϲ���ʵ����ͣ�0����ˮ���˲����������ж��Ƿ�Ҫ���ϲ���������ʩ�����²����С�
            pult=cell(obj.nlayer,1);
            zstart=0; %���㶥�������
            for i=1:obj.nlayer
                switch obj.earthType(i)  %������������
                    case 1   % �����
                        np=3+(q+obj.reff(i)*(pult_z-zstart))/obj.cu(i)+obj.J(i)*(pult_z-zstart)/2/obj.R;
                        pult{i}(pult_z)=np*obj.cu(i)*2*obj.R;
                    case 2    %ɰ����
                        kp=tan(45*pi/180+obj.phieff(i)/2*pi/180)^2;
                        pult{i}(pult_z)=kp^2*2*obj.R*(q+obj.reff(i)*(pult_z-zstart));
                    case 3    %��ʯ��smooth socket
                        tmax=0.2*(obj.sigma_c(i)/1e6)^0.5*1e6; %���濹��������
                        % һ��Ҫ����sigma�ĵ�λ����
                        if obj.GSI(i)<25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=0;
                            a=0.65-obj.GSI(i)/200;
                        elseif obj.GSI(i)>25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=exp((obj.GSI(i)-100)/9);
                            a=0.5;
                        end
                        normal_limited_resistance=(q+obj.reff(i)*(pult_z-zstart))+obj.sigma_c(i)*(mb*(q+obj.reff(i)*(pult_z-zstart))/obj.sigma_c(i)+s)^a;    % �������޳�����
                        pult{i}(pult_z)=(normal_limited_resistance+tmax)*2*obj.R;
                    case 4     %��ʯ��rough socket
                        tmax=0.8*(obj.sigma_c(i)/1e6)^0.5*1e6; %���濹��������
                        if obj.GSI(i)<25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=0;
                            a=0.65-obj.GSI(i)/200;
                        elseif obj.GSI(i)>25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=exp((obj.GSI(i)-100)/9);
                            a=0.5;
                        end
                        normal_limited_resistance=(q+obj.reff(i)*(pult_z-zstart))+obj.sigma_c(i)*(mb*(q+obj.reff(i)*(pult_z-zstart))/obj.sigma_c(i)+s)^a;    % �������޳�����
                        pult{i}(pult_z)=(normal_limited_resistance+tmax)*2*obj.R;
                end
                % ------------
                % �����ϸ���Ϊɰ��ʱ��ɰ������ز�����ֱ�ӵ����²���ʯ�ļ��޳����������ӡ�
                % ���ǴӴ�������϶��ԣ��������߼�����������ģ����統ɰ��λ��������ʯ�м�ʱ���Ͳ�����ôд��
                % ���ԣ�����һ��Ҫ��֤��������Ϊ��ɰ����������λ��������ʯ������档
                if ((obj.earthType(i)==1 || obj.earthType(i)~=2) && (upperLayerType==1 || upperLayerType==2)) ...
                        ||((obj.earthType(i)==3 || obj.earthType(i)~=4) && (upperLayerType==3 || upperLayerType==4))
                    q=q+obj.reff(i)*obj.l(i);  % ����reff*(z-suml)�ĵ���Ч��
                else  % ����ɰ����ʯ�Ľ���ʱ�����ϸ��������
                    q=0;
                end
                q=dot(obj.reff(1:i),obj.l(1:i));
                % ------------
                upperLayerType=obj.earthType(i);
                zstart=sum(obj.l(1:i));
            end
        end
        
        % �õ����޳������Ĳ�ֵ����
        function [depth,pult]=GetDepthPultPare(obj)
            % ����������Ŀ�����е�����������õ���ͬ��ȴ��ļ��޳��������������
            % �������������������������е���������µļ��޳�������������ͨ�����Բ�ֵ�õ�
            % �������
            % depth      һ����������ֵ�ķ�Χ��0��׮�������е��ܳ�����λΪm��
            %            ��������б����м����ؼ����ֵ��0��ÿһ�����ĵײ�����ȡ�
            %            �ӵ�һ������ʼ���䶥�������ֵ���ڲ�������һ��ĵײ������ͬ������������ĵ�һ�����ֵȡΪ��һ�����ĵײ����d�ټ���eps(d)��
            % pult       һ��������������Ԫ�صĸ�����depth�е�Ԫ�ظ�������ȵģ�
            %            ������depth��ÿһ����ȴ��Ķ�Ӧ�ļ��޳���������λΪN/m
            
            % �ӵ�һ�㿪ʼ����ÿһ��������Ӧ�Ĳ�ֵ�ڵ㡣
            depth=zeros(30,1); % Ϊ����Ԥ�����С���Ա��⶯̬�ı������С��
            pult=zeros(30,1);  % Ϊ����Ԥ�����С���Ա��⶯̬�ı������С��
            % ���ս���У�������ʵ�ʰ�����������ЧԪ�صĸ�����Ϊ�˱��⶯̬��������ĳߴ硣
            % Ҳ����һ������ʼ����ʱ����ʼ���ǰһ����ĵ�š�
            PointsCount=1;
            % ��һ�����ĵ�һ����ȵ�Ϊz=0�ĵ㣬������eps(0)�ĵ㣬����Ҫ���⿼�ǡ�
            depth(1)=0;
            switch obj.earthType(1)
                case 1  % �����
                    pult(1)=3*obj.cu(1)*obj.J(1);
                case 2  % ɰ����
                    pult(1)=0;
                case 3     %��ʯ��smooth socket
                    tmax=0.2*(obj.sigma_c(1)/1e6)^0.5*1e6; %���濹��������
                    % һ��Ҫ����sigma�ĵ�λ����
                    if obj.GSI(1)<25
                        mb=exp((obj.GSI(1)-100)/28)*obj.mi(1);
                        s=0;
                        a=0.65-obj.GSI(1)/200;
                    elseif obj.GSI(1)>=25
                        mb=exp((obj.GSI(1)-100)/28)*obj.mi(1);
                        s=exp((obj.GSI(1)-100)/9);
                        a=0.5;
                    end
                    normal_limited_resistance=obj.sigma_c(1)*s^a;    % �������޳�����
                    pult(1)=(normal_limited_resistance+tmax)*2*obj.R;
                case 4     %��ʯ��rough socket
                    tmax=0.8*(obj.sigma_c(1)/1e6)^0.5*1e6; %���濹��������
                    % һ��Ҫ����sigma�ĵ�λ����
                    if obj.GSI(1)<25
                        mb=exp((obj.GSI(1)-100)/28)*obj.mi(1);
                        s=0;
                        a=0.65-obj.GSI(1)/200;
                    elseif obj.GSI(1)>=25
                        mb=exp((obj.GSI(1)-100)/28)*obj.mi(1);
                        s=exp((obj.GSI(1)-100)/9);
                        a=0.5;
                    end
                    normal_limited_resistance=obj.sigma_c(1)*s^a;    % �������޳�����
                    pult(1)=(normal_limited_resistance+tmax)*2*obj.R;
            end
            
            % �ӵ�һ�㿪ʼ����ÿһ���������Ӧ�Ĳ�ֵ�㡣
            startDepth=0; %���㶥�������
            upperLayerType=0; % �ϲ���ʵ����ͣ�0����ˮ���˲����������ж��Ƿ�Ҫ���ϲ���������ʩ�����²����С�
            q=0;    % ���������ϸ����أ��䵥λΪN/m^2��
            for i=1:obj.nlayer
                switch obj.earthType(i)  %������������
                    case 1   % ��������������ӣ���������
                        % ��һ����
                        D=startDepth+eps(startDepth); % �˲�Ķ������+eps()��
                        depth(PointsCount+1)=D; % �˲�Ķ������+eps()��
                        pult(PointsCount+1)=obj.cu(i)*2*obj.R*(3+(q+obj.reff(i)*(D-startDepth))/obj.cu(i)+obj.J(i)*(D-startDepth)/2/obj.R);
                        %�ڶ�����
                        D=sum(obj.l(1:i));    % �˲�ĵײ����
                        depth(PointsCount+2)=D;
                        pult(PointsCount+2)=obj.cu(i)*2*obj.R*(3+(q+obj.reff(i)*(D-startDepth))/obj.cu(i)+obj.J(i)*(D-startDepth)/2/obj.R);
                        %
                        PointsCount=PointsCount+2;
                    case 2    %ɰ�������������ӣ���������
                        kp=tan(45*pi/180+obj.phieff(i)/2*pi/180)^2;
                        % ��һ����
                        D=startDepth+eps(startDepth); % �˲�Ķ������+eps()��
                        depth(PointsCount+1)=D; % �˲�Ķ������+eps()��
                        pult(PointsCount+1)=kp^2*2*obj.R*(q+obj.reff(i)*(D-startDepth));
                        %�ڶ�����
                        D=sum(obj.l(1:i));    % �˲�ĵײ����
                        depth(PointsCount+2)=D;
                        pult(PointsCount+2)=kp^2*2*obj.R*(q+obj.reff(i)*(D-startDepth));
                        %
                        PointsCount=PointsCount+2;
                    case 3    %��ʯ��smooth socket����һ����������6���㡣
                        tmax=0.2*(obj.sigma_c(i)/1e6)^0.5*1e6; %���濹��������
                        % һ��Ҫ����sigma�ĵ�λ����
                        if obj.GSI(i)<25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=0;
                            a=0.65-obj.GSI(i)/200;
                        elseif obj.GSI(i)>25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=exp((obj.GSI(i)-100)/9);
                            a=0.5;
                        end
                        % �������ֲַ���ʽ�Ǹ��������и����ļ��޳��������ʽ����ȵı仯���ҳ������ֲ��ġ�
                        D=startDepth+[eps(startDepth),obj.l(i)*0.05,obj.l(i)*0.1,obj.l(i)*0.2,obj.l(i)*0.35,obj.l(i)*0.6,obj.l(i)]';
                        depth(PointsCount+[1,2,3,4,5,6,7])=D;
                        % �������޳��������˴�Ϊһ������
                        normal_limited_resistance=(q+obj.reff(i)*(D-startDepth))+obj.sigma_c(i)*(mb*(q+obj.reff(i)*(D-startDepth))/obj.sigma_c(i)+s).^a;
                        pult(PointsCount+[1,2,3,4,5,6,7])=(normal_limited_resistance+tmax)*2*obj.R;
                        %
                        PointsCount=PointsCount+7;
                    case 4     %��ʯ��rough socket����һ����������6���ڵ㡣
                        tmax=0.8*(obj.sigma_c(i)/1e6)^0.5*1e6; %���濹��������
                        % һ��Ҫ����sigma�ĵ�λ����
                        if obj.GSI(i)<25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=0;
                            a=0.65-obj.GSI(i)/200;
                        elseif obj.GSI(i)>25
                            mb=exp((obj.GSI(i)-100)/28)*obj.mi(i);
                            s=exp((obj.GSI(i)-100)/9);
                            a=0.5;
                        end
                        % �������ֲַ���ʽ�Ǹ��������и����ļ��޳��������ʽ����ȵı仯���ҳ������ֲ��ġ�
                        D=startDepth+[eps(startDepth),obj.l(i)*0.05,obj.l(i)*0.1,obj.l(i)*0.2,obj.l(i)*0.35,obj.l(i)*0.6,obj.l(i)]';
                        depth(PointsCount+[1,2,3,4,5,6,7])=D;
                        % �������޳��������˴�Ϊһ������
                        normal_limited_resistance=(q+obj.reff(i)*(D-startDepth))+obj.sigma_c(i)*(mb*(q+obj.reff(i)*(D-startDepth))/obj.sigma_c(i)+s).^a;
                        pult(PointsCount+[1,2,3,4,5,6,7])=(normal_limited_resistance+tmax)*2*obj.R;
                        %
                        PointsCount=PointsCount+7;
                end
                % ------------
                % �����ϸ���Ϊɰ��ʱ��ɰ������ز�����ֱ�ӵ����²���ʯ�ļ��޳����������ӡ�
                % ���ǴӴ�������϶��ԣ��������߼�����������ģ����統ɰ��λ��������ʯ�м�ʱ���Ͳ�����ôд��
                % ���ԣ�����һ��Ҫ��֤��������Ϊ��ɰ����������λ��������ʯ������档
                if ((obj.earthType(i)==1 || obj.earthType(i)~=2) && (upperLayerType==1 || upperLayerType==2)) ...
                        ||((obj.earthType(i)==3 || obj.earthType(i)~=4) && (upperLayerType==3 || upperLayerType==4))
                    q=q+obj.reff(i)*obj.l(i);  % ����reff*(z-suml)�ĵ���Ч��
                else  % ����ɰ����ʯ�Ľ���ʱ�����ϸ��������
                    q=0;
                end
                q=dot(obj.reff(1:i),obj.l(1:i));  % ����reff*(z-suml)�ĵ���Ч��
                % ------------
                startDepth=sum(obj.l(1:i));
            end
            % ������������Ԫ�صĸ�����������ʵ�ʰ�����Ԫ�ظ���ΪPointsCount��
            if PointsCount<30
                depth=depth(1:PointsCount) ;
                pult=pult(1:PointsCount) ;
            end
            
        end
    end
end