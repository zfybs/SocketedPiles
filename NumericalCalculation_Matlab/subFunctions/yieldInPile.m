function [blnYield, EI]=yieldInPile(OriPar,depth,moment)
% 对每一层的桩是否发生屈服进行判断
% 并且根据当前的弯矩值返回新的抗弯刚度值
% 是否要考虑桩的屈服。
global ConsiderCrackofPileInEarth
%
if ConsiderCrackofPileInEarth   % 说明要考虑桩的开裂，以及桩开裂后引起的桩的抗弯刚度（flexural rigidity）的变化
    EI1=OriPar.epip;
    l=OriPar.l;
    n=OriPar.nlayer;
    EI=zeros(n,1);
    %
    blnYield=false;
    startDepth=0;
    for i=1:OriPar.nlayer
        PT=OriPar.PileType{i};  % 这一层土中的桩的类型
        % 每一层中所有节点的弯矩
        subMoment=interp1(depth,moment,linspace(startDepth,sum(l(1:i)),100));
        characteristicMoment=mean(abs(subMoment)); % 此层中分布的弯矩的平均代表值
        if characteristicMoment>PT.Mcr   % 以此作为此段的桩是否屈服的标准
            EI(i)=PT.NewStiffness(characteristicMoment);
            blnYield=true;
        else
            EI(i)=EI1(i);
        end
        startDepth=sum(l(1:i));
    end
else  % 说明不考虑桩的开裂，即桩的抗弯刚度（flexural rigidity）的恒不变
    blnYield=false;
    EI=OriPar.epip;
end
end

