classdef PileType
    % 每一层的桩的截面类型，此截面类型控制其刚度值，并且控制了此截面的开裂弯矩、极限弯矩，以及随截面弯矩的增加而导致的抗弯刚度衰减的方式。
    % 对于每一种不同的截面形式，按等效惯性矩法计算其截面的抗弯刚度随着截面开裂而减小的插值向量。
    % 参考ACI规范中，对于等效惯性矩法的介绍。
    % 其基本思路为，截面有初始惯性矩Ig，当受拉区混凝土应变达到其开裂应变时，此时有开裂弯矩Mcr，
    % 此时，计算出截面的完全开裂情况下，假定受拉区的混凝土完全退出工作，而受压区混凝土的应变线性分布，
    % 整个截面达到一个新的平衡，此完全开裂的状态下，截面有一个新的等效惯性矩Icr；
    % 当弯矩M大于Mcr时，整个截面的等效惯性矩从Ig按某种方式（三次函数）衰减到Icr；
    % 当最外侧的钢筋受拉屈服时，截面达到极限弯矩Mult；
    % 整个过程中认为混凝土的弹性模量不变，均为其开裂前的初始变形模量Ec；而钢材的模量也不变，均为Es。
    
    properties(SetAccess=private)
        % 截面类型的名称
        name
        % 截面所承受的弯矩向量，此向量的第一个值为0，第二个值为Mcr，最后一个值为Mult。
        BendingMoment
        % 截面在每一个BendingMoment下所对应的抗弯刚度，其第一个值与第二个值相等，为EI1，表示截面开裂前的刚度，最后一个值为EI2，表示截面完全开裂后的刚度。
        BendingStiffness
        % 截面的开裂弯矩
        Mcr
        % 截面的极限弯矩，此弯矩在截面的受拉钢筋屈服时出现
        Mult
        % 截面开裂前的抗弯刚度
        EI1
        % 截面完全开裂时的抗弯刚度
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
        
        
        % 由桩截面当前所受到的弯矩值，确定其此时的等效抗弯刚度
        function NewEI=NewStiffness(obj,M)
            % 此桩截面在某一个弯矩作用下的新的抗弯刚度。
            if M>=obj.Mult || M<0
                error('桩截面的受拉侧钢筋出现屈服，截面弯矩超过其极限承载力')
            else
                NewEI=interp1(obj.BendingMoment,obj.BendingStiffness,M,'linear','extrap');
            end
        end
        
        
        % 绘制此截面在不同弯矩作用下的抗弯刚度曲线
        function curve=plot_MEI(obj,varargin)
            % varargin 
            % 1、 ax  指定要将曲线图绘制在哪一个现有的坐标轴上
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