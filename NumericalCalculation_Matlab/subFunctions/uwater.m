function [uw rw]=uwater(OriginalParameters,depthInWater,di,ro)
% ����ˮ��׮�ε�λ�ƺ�ת�ǡ�
% ���������������Ӷȱ��ʽ��y=F*(x^2)*(3l-x)/(6EI)-ro.*x+di;  diΪ����ʾλ�����ң�roΪ����ʾ׮����ƫת��
%
% �������
% OriginalParameters
% di,ro     �����ײ���ˮƽλ����ת�ǣ� diΪ����ʾλ�����ң�roΪ����ʾ׮����ƫת��
% depthInWater  һ��������uwater�����᷵�ش�������ָ����ȴ���λ����ת�ǡ�
%               depthInWater��ȡֵ����0��Zy֮��,depthInWater=0��ʾ׮����depthInWater=Zy��ʾ�������洦��
% �������
% uw    һ��������������ˮƽָ����ȴ���ˮƽλ��
% rw    һ��������������ˮƽָ����ȴ���ת��
%
% see also: OriginalProjectParameters
%% ������ֵ
L=OriginalParameters.lw;
PTW=OriginalParameters.PileType_Water; %ˮ��׮�εĽ�������
H=OriginalParameters.H;
di=double(di);  % diΪ����ʾλ������
ro=-double(ro);  % ��ro�ķ���ת��Ϊ׮���ҡ�ƫת��Ϊ��������
n=length(depthInWater);
%% ����������ر��ʽ��M=EIy"��
global considerYieldofPileInWater;   % �Ƿ�Ҫ����ˮ��׮������������µ��������Լ�������׮�ĸնȵļ�С
if considerYieldofPileInWater   
    % ����ȷ���Ὺ�ѵĽ��洦�����
    Lcr=PTW.Mcr/H;
    if Lcr>L  % ˵��ˮ��׮��ȫ�嶼û������
        EI=PTW.BendingStiffness(1);
        [uw,rw]=upperDisplacementRotation(0,H,di,ro,EI,L,L-depthInWater);
        return
    else  % ˵��ˮ�е�׮Ҳ����������
        fprintf(2,['ˮ�е�׮Ҳ�������������������Ϊ��  ',num2str(Lcr),'\n'])
        % ����׮�²�����ؽϴ�����ڽ�ˮ��׮���е���������1m�ָ�Ϊ���׮��
        nodes=(Lcr:1:L)';
        if nodes(end)~=L
            nodes=[nodes;L];  % ��֤����nodes������������Ԫ�أ��������һ��Ԫ�ص�ֵΪl����ˮ��׮�ĵײ���
        end
        bot_d=di;        % ������һС�εĵײ���λ�ƣ���Ƕ�̶˶�����λ�ơ�
        bot_r=ro;          % ������һС�εĵײ���ת�ǣ���Ƕ�̶˶�����ת�ǡ�
        uw=zeros(n,1);
        rw=zeros(n,1);
        eleRemain=n;   % Ҫ���ص�λ����ת�������У���δ������ݵ�Ԫ�ظ���
        for i=length(nodes)-1:-1:1  % ��ʼ����ˮ���������е�ÿһС�ε�λ�Ʒֲ�
            bottom=nodes(i+1);  % �˶εײ�����ȣ�׮�����ֵΪ0��
            top=nodes(i);  %  �˶ζ�������ȣ�׮�����ֵΪ0.
            top_M=H*top;  % ��С�εĶ��������ֵ
            middle=(bottom+top)/2;     % �Դ�С�ε��е�������Ϊ��С�εĴ������ֵ
            EI=PTW.NewStiffness(H*middle);   % �ڴ�С��׮�Ĵ�����������£�׮������µĿ���ն�ֵ��
            depths=depthInWater(depthInWater<=bottom & depthInWater>top);
            ndp=length(depths);   % ������������Ԫ�صĸ���
            % ����ָ����ȴ���λ����ת��
            [D,R]=upperDisplacementRotation(top_M,H,bot_d,bot_r,EI,bottom-top,bottom-depths);
            % �������
            uw(eleRemain-ndp+1:eleRemain)=D;
            rw(eleRemain-ndp+1:eleRemain)=R;
            % ��С�ε�����һ�εĵײ�λ�Ʊ߽磬�˴�С�εĶ���λ�ơ�
            [bot_d,bot_r]=upperDisplacementRotation(top_M,H,bot_d,bot_r,EI,bottom-top,bottom-top);
            %
            eleRemain=eleRemain-length(depths); % ��ʣ���ٸ�Ԫ��δ���
        end
        % ˮ��δ��������λ����ת�ǽ�
        depths=depthInWater(depthInWater<=Lcr & depthInWater>=0);
        EI=PTW.BendingStiffness(1);
        [D,R]=upperDisplacementRotation(0,H,bot_d,bot_r,EI,Lcr,Lcr-depths);
        % �������
        uw(1:eleRemain)=D;
        rw(1:eleRemain)=R;
    end
else    % ��Ҫ����ˮ��׮������������µ��������Լ�������׮�ĸնȵļ�С����ʱ����׮�ΰ��������������㼴�ɡ�
    EI=PTW.BendingStiffness(1);
    [uw,rw]=upperDisplacementRotation(0,H,di,ro,EI,L,L-depthInWater);
    % ���Խⷨ����
    %{ 
    % λ�Ʊ��ʽ��y=F*(y^2)*(3l-x)/(6EI)+ro.*y+di;  diΪ����ʾλ�����ң�roΪ����ʾ׮����ƫת��
    deflection = @(y) H.*y.^2/6/EI.*(3*L-y)+ro.*y+di;  % yΪ0��ʾ��ˮ��׮�ײ�����
    rotation=@(y) H/2/EI*(2*L*y-y.^2)+ro;
    uw1=deflection(L-depthInWater);
    rw1=rotation(L-depthInWater);
    %}
end
% �������ת�ǵ�������ת��Ϊ��roΪ����ʾ׮����ƫת��
rw=-rw;
end

function [D,R]=upperDisplacementRotation(M,H,di,ro,EI,L,y)
% ����һ�εȸնȵ�׮���������ڲ����ֲܷ����ص�����£���֪���϶ˡ����ܵ������������Լ����¶ˡ���λ����ת�Ǳ߽磬����һ�ߵ�λ����ת�ǡ�
% ���������                                                             H,M
% M�� ׮���϶ˣ���ˣ����ܵ���أ����϶ˣ���ˣ���ʱ��Ϊ��             ^    ___
% H�� ׮���϶ˣ���ˣ����ܵļ��������϶ˣ���ˣ����ң����ϣ�Ϊ��      y  |   |  |
% di,ro�� ׮���±߽��λ����ת�ǣ�λ��������Ϊ����ת��������ת��Ϊ��     |   |  |
% EI���˶�׮�ĳ����뿹��ն�                                         0 |___|__|__> x
% L���˶�׮���ܳ���
% y�� һ�����������е�Ԫ�ش���ĳ���浽׮�εײ��ľ��룬��ֵ�ķ�Χ��0��L��
%     ��y=Lʱ������ļ���׮���϶˲���λ����ת�ǣ���y=0ʱ��D��R��ֵ��Ϊdi��ro��
%
% ���������
% D��׮���϶˵�λ��
% R: ׮���϶˵�ת��
D=(H*y.^3/3/EI)+((M+H*(L-y)).*y.^2/2/EI)+(di+ro*y);
R=(H*y.^2/2/EI)+((M+H*(L-y)).*y/EI)+(ro);

% ��������������£�
% D_H=H*y.^3/3/EI;  % ׮�߽紦�ļ�������ָ��׮���洦��λ�ƵĹ���
% R_H=H*y.^2/2/EI;  % ׮�߽紦�ļ�������ָ��׮���洦��ת�ǵĹ���
% D_M=(M+H*(L-y)).*y.^2/2/EI;  % ׮�߽紦����ض���ָ��׮���洦��λ�ƵĹ���
% R_M=(M+H*(L-y)).*y/EI;  % ׮�߽紦����ض���ָ��׮���洦��ת�ǵĹ���
% D_di_ro=di+ro*y;  % ׮�±߽紦��λ����ת�Ƕ���ָ��׮���洦��λ�ƵĹ���
% R_di_ro=ro;  % ׮�±߽紦��λ����ת�Ƕ���ָ��׮���洦��ת�ǵĹ���
% D=D_H+D_M+D_di_ro;
% R=R_H+R_M+R_di_ro;

end
