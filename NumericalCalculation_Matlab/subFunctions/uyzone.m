function [uy ry,moment]=uyzone(OriginalParameters,results,z)
% �������������ָ�����λ�ô���ˮƽλ������Ӧ��ת�ǡ�
% �������
% OriginalParameters % ������Ŀ��ԭʼ�������
% results        ���һ�����޲�ַ�����Ľ��
% z     UYZONE �����᷵������z��ָ����ȴ���ˮƽλ��ֵ��
%       z��ȡֵ����0��Zy֮��,z=0��ʾ׮����z=Zy��ʾ�������洦��
%       ���Ա���zΪ������ʱ�������Ϊ����������zΪ������ʱ�����Ϊ����
%       ��������Ƚ�zתΪ��������
%       ��pult������ͬ������uy,ry����zΪ�Ա����ķ��ź���������ֱ�������Ա�������ý��������������Ա���������Ϊ������ţ�����һ��Ҫ��z��
%
% �������
% uy,ry,moment   �������е�λ�ơ�ת������صķֲ�������Ϊ��ֵ�����������Ƿ���������
%               �����εĶ�����λ�ơ�ת������طֱ����������������еĵ�һ��Ԫ�ء�
%

%% �ȼ����������е�λ�Ƶķ��ű��ʽ
[uy_sym ry_sym moment_sym l_uyd]=getuyfun(OriginalParameters,results);
% �ٸ��ݸ�������ȼ����Ӧ��λ������
[uy ry,moment]=GetReaction_YieldZone(z,uy_sym, ry_sym,moment_sym,l_uyd);
%
% H_FDM=results.ShearForce{1}(1)  % ���޲�ַ�����õ��ķ����������������
% M_FDM=results.BendingMoment{1}(1)  % ���޲�ַ�����õ��ķ����������������
% bm1=moment(end)

%{
%% ������ص�������
figure;hold on
subplot(2,1,2)
plot(moment,z,'*-')
set(gca,'ydir','reverse')
xlabel('���')
ylabel('���')
%
subplot(2,2,1)
plot(uy,z,'*-')
set(gca,'ydir','reverse')
xlabel('λ��')
ylabel('���')
%
subplot(2,2,2)
plot(ry,z,'*-')
set(gca,'ydir','reverse')
xlabel('ת��')
ylabel('���')
%}
end

% �õ���pultfun�õ��ķ��ź���uy��ry
function [uy_sym ry_sym moment l_uyd]=getuyfun(OriginalParameters,results)
% ����Ƕ�̶��е������Σ�����λ�Ƽ���
% ���ý����İ취���λ�ƺ�ת�ǵı��ʽ�����ɱ߽������õ�δ֪��c��d
% �ٶ������z������Ӧ��λ�ƺ�ת��
% z��ȡֵ����0��Zy֮��,z=0��ʾ׮����z=Zy��ʾ�������洦��
%
% �������
% OriginalParameters % ������Ŀ��ԭʼ�������
% results        ���һ�����޲�ַ�����Ľ��
%
% �������
% uy_sym,ry_sym,moment
%           Ԫ�����飬���е�ÿһ��Ԫ�ض���һ�����ź���symfun���˺����������ָ����ȴ���λ�ơ�ת������ء�
%           ÿһ�����еķ����Ա����ķ�Χ��Ҫ�����ڴ˲�����ռ�ݵ�����ں����ײ��ľ�����ȣ�����������ڴ˲㶥������ȡ�
% l_uyd     ��������ÿһ��ĳ���
% see also  OriginalProjectParameters,FDMResults

%% ������ֵ
epip=OriginalParameters.epip;
% ip=OriginalParameters.ip;
nlayer=OriginalParameters.nlayer;
M=OriginalParameters.M;
H=OriginalParameters.H;
lstay=OriginalParameters.l;
pultfun=OriginalParameters.pultfun; % һ�����ź���������������ȡˮ������������������ȴ��ļ��޳�������
% ���յ�δ�����ζ����ڵ��λ����ת��
di=results.top_u;
ro=results.top_r;
Zy=results.physicalConditions.Zy;  % �����������������������Ķ��˵���ȡ�
%
%%  ������������ÿһ��ĳ���
for nYieldPart=1:nlayer  % nYieldPart ��ʾ��������λ�ڵػ��ľ��Բ�����
    if Zy<sum(lstay(1:nYieldPart))
        break
    end
end
l_uyd(1:nYieldPart)=lstay(1:nYieldPart); % δ��������ÿ��ĺ�ȡ�
l_uyd(nYieldPart)=lstay(nYieldPart)+Zy-sum(l_uyd);
%% �ȡ��������¡��õ���ر��ʽ
moment=cell(1,nYieldPart);
z0=0;  % ����Ƕ�̶˶��������
z=sym('z');
pult_z=sym('pult_z');
for i=1:nYieldPart  % �������¼������
    % �����z�����������Ƕ��εĶ������������ײ��������
    % ע����ֵ��Ա�����pult_z������ķ��ű���ֻ�൱�ڳ�����
    moment{i}(z)=M+H*(z-z0)-int(pultfun{i}(pult_z)*(z-pult_z),pult_z,z0,z); % ÿһ��������z�ĺ�����
    M=moment{i}(z0+l_uyd(i));  % ��i��ײ�����أ�����i+1�㶥�������
    H=H-int(pultfun{i}(pult_z),pult_z,z0,z0+l_uyd(i));% ��i��ײ���ˮƽ��������i+1�㶥����ˮƽ��
    z0=z0+l_uyd(i);
end
%% �١��������ϡ����ѵõ�����غ������λ�ƺ�����
uy_sym=cell(1,nYieldPart);
ry_sym=cell(1,nYieldPart);
for i_inverse=1:nYieldPart
    syms c d
    j=nYieldPart+1-i_inverse; % jΪ������i_inverse��
    uy_sym{j}=(int(int(moment{j},z),z)+c*z+d)/epip(j);  % ��j��������ȴ���λ�Ʊ��ʽ�������M=EIy"
    ry_sym{j}=diff(uy_sym{j},z);                          % ��j��������ȴ���ת�Ǳ��ʽ����ת��r=dy/dz
    f1=uy_sym{j}(sum(l_uyd(1:j)))-di; %λ���������˲�ײ���λ�Ƶ���������һ�㶥����λ��
    f2=ry_sym{j}(sum(l_uyd(1:j)))-ro; %ת���������˲�ײ���ת�ǵ���������һ�㶥����ת��
    % �ɱ߽�������������c��d
    [c d]=solve(f1,f2,c,d);
    c=subs(c);
    d=subs(d);
    %% �õ�������ķֶ�λ�ƺ���uy{j}(z)��ֶ�ת�Ǻ���ry{j}(z)���Լ�Ƕ�̶˶���λ��di��ת��ro
    uy_sym{j}=subs(uy_sym{j});  % ��uy�����еķ��ű���c��d�滻Ϊ��Ӧ��ֵ����uy������ֻ���ڱ���z��
    ry_sym{j}=subs(ry_sym{j});
    toprelative=sum(l_uyd(1:j))-sum(l_uyd(j));
    di=uy_sym{j}(toprelative); % �˲㶥����λ��ֵ��ͬʱ��Ϊ��������һ���λ��ʱ��λ�Ʊ߽硣
    ro=ry_sym{j}(toprelative); % �˲㶥����ת��ֵ��ͬʱ��Ϊ��������һ���λ��ʱ��ת�Ǳ߽硣
end
% ����di,ro�����������������������������ײ�����λ����ת��
end


function [uy,ry,moment]=GetReaction_YieldZone(z,uy_sym, ry_sym,moment_sym,l_uyd)
% �������������ָ�����λ�ô���ˮƽλ������Ӧ��ת�ǡ�
% �������
% z     UYZONE �����᷵������z��ָ����ȴ���ˮƽλ��ֵ��
%       z��ȡֵ����0��Zy֮��,z=0��ʾ׮����z=Zy��ʾ�������洦��
%       ���Ա���zΪ������ʱ�������Ϊ����������zΪ������ʱ�����Ϊ����
%       ��������Ƚ�zתΪ��������
%       ��pult������ͬ������uy,ry����zΪ�Ա����ķ��ź���������ֱ�������Ա�������ý��������������Ա���������Ϊ������ţ�����һ��Ҫ��z��
% uy_sym,ry_sym,moment
%           Ԫ�����飬���е�ÿһ��Ԫ�ض���һ�����ź���symfun���˺����������ָ����ȴ���λ�ơ�ת������ء�
%           ÿһ�����еķ����Ա����ķ�Χ��Ҫ�����ڴ˲�����ռ�ݵ�����ں����ײ��ľ�����ȣ�����������ڴ˲㶥������ȡ�
% l_uyd       Ƕ�̶���������ռ����������������µĵ�ǰnypart�㣬ÿ��ĺ����l_uyd������,Ҳ����sum(l_uyd)=Zy.
%
% �������
% uy,ry,moment   �������е�λ�ơ�ת������صķֲ�������Ϊ��ֵ�����������Ƿ���������
%               �����εĶ�����λ�ơ�ת������طֱ����������������еĵ�һ��Ԫ�ء�
%
%% ȷ��zΪ��������
if size(z,2)==1
    z=z';
end
%%
nypart=length(l_uyd); % Ƕ�̶���������ռ����������������µ�ǰnypart��
suml=0;
uy=0;
ry=0;
moment=0;
for i=1:nypart
    logic=(z>=suml & z<sum(l_uyd(1:i)));
    zlogic=logic.*z;
    %
    uy_part=uy_sym{i}(zlogic).*logic; % Ϊ����������ֱ�Ӹ��ǵĹ�ϵ��������һ��Ҫ���һ��logic��
    uy=uy_part+uy;
    %
    ry_part=ry_sym{i}(zlogic).*logic;
    ry=ry_part+ry;
    %
    moment_part=moment_sym{i}(zlogic).*logic;
    moment=moment_part+moment;
    %
    suml=sum(l_uyd(1:i));
end
if max(z)>sum(l_uyd)-eps(max(z))  % ���ǵ���ĩβ�ĵ㲻��������߼���Χ֮�ڡ�
    
    ind=find(z>sum(l_uyd)-eps(max(z)));
    uy(ind)=uy_sym{nypart}(sum(l_uyd));
    ry(ind)=ry_sym{nypart}(sum(l_uyd));
    moment(ind)=moment_sym{nypart}(sum(l_uyd));
end
%% ���������ɷ��ű���ת��Ϊdouble�͡���ȻҲ���Բ�ת����
uy=double(uy);
ry=double(ry);
moment=double(moment);
end
