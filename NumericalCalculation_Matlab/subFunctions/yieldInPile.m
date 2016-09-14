function [blnYield, EI]=yieldInPile(OriPar,depth,moment)
% ��ÿһ���׮�Ƿ������������ж�
% ���Ҹ��ݵ�ǰ�����ֵ�����µĿ���ն�ֵ
% �Ƿ�Ҫ����׮��������
global ConsiderCrackofPileInEarth
%
if ConsiderCrackofPileInEarth   % ˵��Ҫ����׮�Ŀ��ѣ��Լ�׮���Ѻ������׮�Ŀ���նȣ�flexural rigidity���ı仯
    EI1=OriPar.epip;
    l=OriPar.l;
    n=OriPar.nlayer;
    EI=zeros(n,1);
    %
    blnYield=false;
    startDepth=0;
    for i=1:OriPar.nlayer
        PT=OriPar.PileType{i};  % ��һ�����е�׮������
        % ÿһ�������нڵ�����
        subMoment=interp1(depth,moment,linspace(startDepth,sum(l(1:i)),100));
        characteristicMoment=mean(abs(subMoment)); % �˲��зֲ�����ص�ƽ������ֵ
        if characteristicMoment>PT.Mcr   % �Դ���Ϊ�˶ε�׮�Ƿ������ı�׼
            EI(i)=PT.NewStiffness(characteristicMoment);
            blnYield=true;
        else
            EI(i)=EI1(i);
        end
        startDepth=sum(l(1:i));
    end
else  % ˵��������׮�Ŀ��ѣ���׮�Ŀ���նȣ�flexural rigidity���ĺ㲻��
    blnYield=false;
    EI=OriPar.epip;
end
end

