classdef PileType
    % ÿһ���׮�Ľ������ͣ��˽������Ϳ�����ն�ֵ�����ҿ����˴˽���Ŀ�����ء�������أ��Լ��������ص����Ӷ����µĿ���ն�˥���ķ�ʽ��
    % ����ÿһ�ֲ�ͬ�Ľ�����ʽ������Ч���Ծط����������Ŀ���ն����Ž��濪�Ѷ���С�Ĳ�ֵ������
    % �ο�ACI�淶�У����ڵ�Ч���Ծط��Ľ��ܡ�
    % �����˼·Ϊ�������г�ʼ���Ծ�Ig����������������Ӧ��ﵽ�俪��Ӧ��ʱ����ʱ�п������Mcr��
    % ��ʱ��������������ȫ��������£��ٶ��������Ļ�������ȫ�˳�����������ѹ����������Ӧ�����Էֲ���
    % ��������ﵽһ���µ�ƽ�⣬����ȫ���ѵ�״̬�£�������һ���µĵ�Ч���Ծ�Icr��
    % �����M����Mcrʱ����������ĵ�Ч���Ծش�Ig��ĳ�ַ�ʽ�����κ�����˥����Icr��
    % �������ĸֽ���������ʱ������ﵽ�������Mult��
    % ������������Ϊ�������ĵ���ģ�����䣬��Ϊ�俪��ǰ�ĳ�ʼ����ģ��Ec�����ֲĵ�ģ��Ҳ���䣬��ΪEs��
    
    properties(SetAccess=private)
        % �������͵�����
        name
        % ���������ܵ�����������������ĵ�һ��ֵΪ0���ڶ���ֵΪMcr�����һ��ֵΪMult��
        BendingMoment
        % ������ÿһ��BendingMoment������Ӧ�Ŀ���նȣ����һ��ֵ��ڶ���ֵ��ȣ�ΪEI1����ʾ���濪��ǰ�ĸնȣ����һ��ֵΪEI2����ʾ������ȫ���Ѻ�ĸնȡ�
        BendingStiffness
        % ����Ŀ������
        Mcr
        % ����ļ�����أ�������ڽ���������ֽ�����ʱ����
        Mult
        % ���濪��ǰ�Ŀ���ն�
        EI1
        % ������ȫ����ʱ�Ŀ���ն�
        EI2
    end
    %%
    methods
        % -------------------------------------------------------------------------------------------------
        function obj = PileType(name,BendingMoment,BendingStiffness)
            obj.BendingStiffness=BendingStiffness;
            obj.BendingMoment=BendingMoment;
            obj.name=name;
            obj.Mcr=BendingMoment(2);
            obj.Mult=BendingMoment(end);
            obj.EI1=BendingStiffness(1);
            obj.EI2=BendingStiffness(end);
        end
        
        
        % ��׮���浱ǰ���ܵ������ֵ��ȷ�����ʱ�ĵ�Ч����ն�
        function NewEI=NewStiffness(obj,M)
            % ��׮������ĳһ����������µ��µĿ���նȡ�
            if M>=obj.Mult || M<0
                error('׮�����������ֽ����������������س����伫�޳�����')
            else
                NewEI=interp1(obj.BendingMoment,obj.BendingStiffness,M,'linear','extrap');
            end
        end
        
        
        % ���ƴ˽����ڲ�ͬ��������µĿ���ն�����
        function curve=plot_MEI(obj,varargin)
            % varargin 
            % 1�� ax  ָ��Ҫ������ͼ��������һ�����е���������
            if isempty(varargin)
                curve=plot(gca,obj.BendingMoment,obj.BendingStiffness,'r*-');
            else
                curve=plot(varargin{1},obj.BendingMoment,obj.BendingStiffness,'r*-');
            end
            xlabel('Bending Moment (N*m)')
            ylabel('EI (N*m^2)')
            grid on
        end
    end
end