classdef FDMphysicalConditions
    % 进行有限差分法计算所需要的所有物理参数。
    % See AlsO: FINITEDIFFERENCE,FDMRESULTS,OriginalProjectParameters
    properties(SetAccess=private)
        R   %桩的半径，这是一个不变量；
        l   %新的非屈服段的桩的总长，它是通过有限差分法计算得到的反力分布与土层的极限承载力分布进行比较后得到的长度，即p_z<p_ult的桩段的长度；
        epip  %桩的抗弯刚度弹性模量，它的值会随着桩的受弯开裂而减小。
        %         ip  %桩的惯性矩，这是一个不变量；
        e1  %这是一个向量，它代表未屈服区的每一层土的顶部的弹性模量；
        e2  %这是一个向量，它代表未屈服区的每一层土的底部的弹性模量，这层土中间的弹性模量被认为是线性分布的；
        v   %这是一个向量，它代表未屈服区的每一层土的泊松比；
        H   %新的未屈服桩段的顶部的水平荷载；
        M   %新的未屈服桩段的顶部的弯矩；
        nlayer  %新的未屈服桩段所占的土层数；
        %       Zy并不是有限差分法计算中所需要的属性，但是它是作为一个深度的基准值。
        %       由于有限差分法计算时，深度以当前的未屈服区的顶部为基准的；而从全局来说，所有的深度都是以整个土层的顶部的基准的，
        %       所以Zy代表的是开始进行有限差分计算之前，从整个土层的顶部到要进行计算的未屈服区的顶部的长度值。
        Zy
    end
    
    methods
        function obj = FDMphysicalConditions(R,l,epip,e1,e2,v,H,M,nlayer,Zy)
            if nargin>0
                obj.R=R;
                obj.l=l;
                obj.epip=epip;
                %                 obj.ip=ip;
                obj.e1=e1;
                obj.e2=e2;
                obj.v=v;
                obj.H=H;
                obj.M=M;
                obj.nlayer=nlayer;
                obj.Zy=Zy;
            end
        end
    end
end