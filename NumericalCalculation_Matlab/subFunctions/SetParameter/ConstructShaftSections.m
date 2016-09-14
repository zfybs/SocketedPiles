function SectionDefinitions = ConstructShaftSections(SectionParameters,systemProperties)
% ��׮���涨��ת��Ϊ��Ӧ�� .mat �ļ�
% ���������SectionDefinitions  һ���ṹ��������������ÿһ��Ԫ��Ϊһ��׮���涨��������Ӧ����Ϣ

% ------ ����ṹ�� -------
n =length(SectionParameters);
c = cell(n,1);
SectionDefinitions = struct( ...
'ID'            ,c, ...  & ÿһ������ı�ʶ����
'Name'            ,c, ...  & ÿһ������ı�ʶ����
'EA'              ,c, ...
'BendingMoment'   ,c, ...
'BendingStiffness',c, ...
'Mcr'             ,c, ...
'Mult'            ,c, ...
'EI1'             ,c, ...
'EI2'             ,c);

% ------ ���ϲ��� -------
fy=systemProperties.fy;
fcp=systemProperties.fcy;
Es=systemProperties.Es; % �ֲĵĵ���ģ������λΪKPa��
for i = 1:n
    section = SectionParameters(i).ATTRIBUTE;
    M_EI.ID = SectionParameters(i).ID;
    M_EI.Name = section.Name;
    [thickness_steeltube,D_tube,D_bar,n,D_SteelCage]=configureSection(section);
    
    %%
    
    %% ���β���
    % ���׹�
    R_tube=D_tube/2;
    I_tube=pi/4*(R_tube^4-(R_tube-thickness_steeltube)^4);   % ���׹ܶ��ڽ���������Ĺ��Ծ�
    
    % ������
    D_sec=D_tube-thickness_steeltube*2;  % ׮��ë����ֱ��
    R=D_sec/2;      % ׮�İ뾶
    I_sec=pi*D_sec^4/64; % ׮��ë������Ծ�
    fr=19.7*fcp^0.5;  % ����������ǿ��
    
    % �ֽ�
    coverThickness=R-D_SteelCage/2;   % ��������
    e_y=fy/200e6;   % �ֽ������Ӧ��
    R_bar=D_sec/2-coverThickness-D_bar/2;   % �ֽ�����ĵ����׮���ĵľ���
    I_steel=steelMoment(D_sec,D_bar,n,coverThickness,0,2,0);
    EI_SteelBar=Es*I_steel;           % �ֽ�Ŀ���ն�
    
    %% ����ǰ
    % �������Ĺ���
    Ec=151000*fcp^0.5;  % �������ĳ�ʼ����ģ������e=0ʱ������ģ������λΪKPa
    e_c_tensile=fr/Ec;  % ��������������ʱ��Ӧ��
    fai=e_c_tensile/R;  % ��������ʱ��ƽ����������Ƕ�
    % ����ǰ�ĸն��ɸ��׹ܡ����������ݽ��ṩ
    B_preCrack=Ec*I_sec+EI_SteelBar+Es*I_tube;    %����ĳ�ʼ�ն�
    % �������ֵ�����л��������ݽ�Ĳ����������и����Ĺ�ʽȷ�������׹ܵĲ����ɵ��Խ�ȷ��
    Mcr=fr*I_sec/R_bar+Es*I_tube*fai;   %��������ʱ�����ֵ
    
    %% ���Ѻ�Ĺ��Ծ�
    
    % Acr������Բ�ν����ָ�������ᣬλ������ѹ��Ļ������������
    % ���У�R����Բ����İ뾶��xcr����ָ���������ᣬ�����������Բ�����ˮƽ�뾶�ᣬ��xcr=0��
    % ��xcr��ֵΪ��ʱ����ʾ������������������
    Acr=@(R,Xcr) acos(Xcr/R)*R^2-Xcr*sqrt(R^2-Xcr^2);    %R^2*(pi/2-asin(Xcr/R)-Xcr/R*sqrt(1-(Xcr/R)^2))
    
    % Scr����ƽ����ٶ��£���ָ�����������ѹ������������������������أ���ÿһ΢Ԫ��������䵽������ľ���ĳ˻���
    % ���У�R����Բ����İ뾶��xcr����ָ���������ᣬ�����������Բ�����ˮƽ�뾶�ᣬ��xcr=0��
    % ��xcr��ֵΪ��ʱ����ʾ�����������������ء�
    % ����÷��ű��ʽ����ȷ�⣬��Scr�Ĺ��췽�����£����ǣ��������ַ��ű��ʽ����ֻ�ǳ���ʱ��
    % x=sym('x'); Scr=@(R,xcr)real(double(2*int((x-xcr)*sqrt(R^2-x^2),x,xcr,R)));
    % ��integral��������ֵ���ֵķ�������⡣
    Scr=@(R,xcr) 2*integral(@(x)(x-xcr).*sqrt(R^2-x.^2),xcr,R);
    
    % Icr����ƽ����ٶ��£���ָ�����������ѹ�������������������Ĺ��Ծأ���ÿһ΢Ԫ��������䵽������ľ����ƽ���ĳ˻���
    % ���У�R����Բ����İ뾶��xcr����ָ���������ᣬ�����������Բ�����ˮƽ�뾶�ᣬ��xcr=0��
    % ��xcr��ֵΪ��ʱ����ʾ������������Ĺ��Ծء�
    % ����÷��ű��ʽ����ȷ�⣬��Icr�Ĺ��췽�����£����ǣ��������ַ��ű��ʽ����ֻ�ǳ���ʱ��
    % x=sym('x'); Icr=@(R,xcr)real(double(2*int(sqrt(R^2-x^2)*(x-xcr)^2,x,xcr,R)));
    % ��integral��������ֵ���ֵķ�������⡣
    Icr=@(R,xcr) 2*integral(@(x)sqrt(R^2-x.^2).*(x-xcr).^2,xcr,R);
    
    %% �õ���������ȫ���Ѻ�������ᣬ���� ACI �淶��������������ʱ����Ϊ������������ȫ���˳�������
    oldxcr=R_tube/2-1;	% ��ʼ�ٶ���������
    ubxcr=R_tube;    % ��ʼ�ٶ�����������Ը����ķ�Χ���Ͻ�
    lbxcr=0;    % ��ʼ�ٶ�����������Ը����ķ�Χ���½�
    newxcr=oldxcr+1; % ����ѭ���ĳ�ʼֵ
    while abs(newxcr-oldxcr)>0.0005;    % �������Ϊ1mm
        oldxcr=newxcr;
        % ec=sym('ec')
        % fai=ec/(R-oldxcr);  % ����ı��νǶ�
        pt_s=steelMoment(D_sec,D_bar,n,coverThickness,oldxcr,1,1)*Es;  % *fai  % �������ֽ�ĺ������������Ļ�����ȫ���˳�����
        pp_s=steelMoment(D_sec,D_bar,n,coverThickness,oldxcr,1,-1)*Es; % *fai  % ��ѹ���ֽ�ĺ���
        pp_c=Scr(R,oldxcr)*Ec; % *fai       % ��ѹ���������ĺ���
        pp_t=(Scr(R_tube,oldxcr)-Scr(R,oldxcr))*Es;      % ��ѹ���ĸ��׹ܵĺ���
        pt_t=(Scr(R_tube,-oldxcr)-Scr(R,-oldxcr))*Es;      % �������ĸ��׹ܵĺ���
        %
        equi=pt_s+pt_t-pp_s-pp_c-pp_t;
        if equi>0   % ˵���˼ٶ���������̫�ߣ������������ĺ���������ѹ���ĺ���
            newxcr=lbxcr+(oldxcr-lbxcr)/2;
            ubxcr=oldxcr;
        else   % ˵���˼ٶ���������̫�ͣ������������ĺ���С����ѹ���ĺ���
            newxcr=oldxcr+(ubxcr-oldxcr)/2;
            lbxcr=oldxcr;
        end
    end
    xcr=newxcr;   % ���յ��������λ��
    %% ��ȫ���Ѻ�
    % ��ȫ����ʱ�Ľ���ĵ�Ч���Ծء��ο��ֽ������ԭ����11.3�ڡ����ɸ��׹ܡ����������ݽͬ��ɡ�
    B_crack=Ec*Icr(R,xcr)+Es*steelMoment(D_sec,D_bar,n,coverThickness,xcr,2,0)+Es*(Icr(R_tube,xcr)-Icr(R,xcr));
    %
    Mult=B_crack*0.015/(R_bar+xcr);    % �������ֽ�����
    %% ��Ч���Ծط�������Ч�նȷ���
    % ������Ϊ����ĸ��׹ܵ��������ڲ��ĸֽ������������ƣ�������Ȼ���޸��׹ܵ�����ʽ����˥��
    Beff=@(M) ((Mcr./M).^3*B_preCrack+(1-(Mcr./M).^3)*B_crack);  % ������ص����󣬽���ĵ�Ч�ն��ڼ�С
    %% ��������
    EA_tube=Es*pi*((D_tube)^2-(D_tube-thickness_steeltube)^2)/4;
    EA_bars=Es*pi*D_bar^2/4*n;
    EA_concrete=Ec*pi*(D_tube-thickness_steeltube)^2/4;
    EA=EA_tube+EA_bars+EA_concrete;
    %% ����ṹ��
    M=exp(linspace(log(Mcr),log(Mult),15)');   % �ο�����ص㰴ָ��������
    Stiffness=Beff(M);
    M=[0;M];
    Stiffness=[Stiffness(1);Stiffness];
    %
    M_EI.EA=EA*1000; % �����ڵ��Խ׶εĿ�ѹ�նȡ�����λ��KNת��ΪN��
    M_EI.BendingMoment=M*1000;              % ����λ��KNת��ΪN��
    M_EI.BendingStiffness=Stiffness*1000;   % ����λ��KNת��ΪN��
    M_EI.Mcr=M_EI.BendingMoment(2);
    M_EI.Mult=M_EI.BendingMoment(end);
    M_EI.EI1=M_EI.BendingStiffness(1);
    M_EI.EI2=M_EI.BendingStiffness(end);
    
    SectionDefinitions(i) = M_EI;
    %
    % filePath = fullfile(sectionDirectory,[M_EI.Name,'.mat']);
    % save(filePath, 'M_EI', 'D_tube', 'thickness_steeltube', 'D_bar','D_SteelCage', 'n','D_SteelCage','fy','fcp')
    %% ��ͼ���
%     figure;
%     hold on;
%     plot(M_EI.BendingMoment,M_EI.BendingStiffness,'r*-')
%     xlabel('Bending Moment (N*m)')
%     ylabel('EI (N*m^2)')
%     grid on
    %
end  % ��һ��׮����
end

%%
function [thickness_steeltube,D_tube,D_bar,n,D_SteelCage]=configureSection(section)
% ���첻ͬ���͵�׮����
% ���������
% sectionName: ��������
% blnModified: �Ƿ�ʹ����������������ԭʼ������������Ҫ�Խ��������������ΪTrue��
%
% ���������
% thickness_steeltube:  ���׹ܵıں񣬵�λΪm�����û�и��׹ܣ���Ϊ0��
% D_tube: ׮���⾶����λΪm������и��׹ܣ���Ϊ���׹ܵ��⾶��
% D_bar: ����ֽ�ֱ������λΪm
% n: ����ֽ�ĸ���
% D_SteelCage: �ֽ�����ֱ�����⾶������λΪm��
% fy:  �ֽ������ǿ�ȣ���λΪKPa������HPB300������ǿ��Ϊ300e3 KPa
% fcp: 28��Բ���忹ѹǿ�ȣ���λΪKPa�� C40�����忹ѹǿ�ȱ�׼ֵΪfcu=26.8MPa����ЧΪ28��Բ���忹ѹǿ��fcp=0.79*fcu=21.172Mpa


thickness_steeltube=section.ThicknessOfSteeltube;
D_tube=section.Diameter;
%
D_bar=section.DBar;
n=section.BarsCount;
D_SteelCage=section.DSteelCage;

end


%%
function steel=steelMoment(D,d,n,coverThickness,xcr,varargin)
% ��ָ������ĸֽ����ָ��������ľ��ػ��߹��Ծ�
% �˺���ֻ������Բ�εĸֽ����е��ݽ�����ݽ���Բ�ξ��ȷֲ���
% �������
% D     ����Բ�ν����ֱ��
% d     �ֽ��ֱ��
% n     �ֽ�ĸ��������еĸֽ�ʻ��ξ��ȷֲ�
% coverThickness    �ֽ�ı������ȣ�ָ��Բ�ν����Ե���ֽ��Ե�ľ��룬�����ǵ��ֽ����ĵľ���
% xcr   �����ض�����������أ�����ǹ���Բ����İ뾶�ᣬ��xcr=0
% varargin
% 1��order��    ��ʾȡ�صĽ��������Ϊ1�����ʾ��һ�׾أ������أ����Ϊ2�����ʾ����׾أ������Ծأ�Ĭ��Ϊ����Ծء�
% 2��portion��  ��ʾҪ������һ���ֵľأ����Ϊ-1�����ʾ����ѹ���ĸֽ�ľأ�
%                 ���Ϊ1�����ʾ���������ĸֽ�ľأ����Ϊ0�����ʾ���������������иֽ����ָ��������ľء�Ĭ��Ϊ0��
% �������
% steel     ָ�����������õ��ĸֽ������ػ��߹��Ծ�


% ���趨Ĭ��ֵ
order=2;    % Ĭ������Ծأ������Ǿ��أ�
portion=0;  % Ĭ��������Բ���������иֽ����ָ��������ľ�
% xcr=D/2-xcr;  % ��xcr�ĸ����������ᵽˮƽ�뾶��ľ���ת���������ᵽ�����Ե�ľ���
if length(varargin)==1
    order=varargin{1};
elseif length(varargin)==2
    order=varargin{1};
    portion=varargin{2};
end

%
r=d/2;   % �ֽ�İ뾶
R_bar=D/2-coverThickness-r;   % �ֽ�����ĵ����׮���ĵľ���

%
% �������������иֽ���Ų���ʽ������ȡ��һ���ֽ��λ��ΪԲ����ײ���������Ϊ����һ������£��������Ƚ��ֽ������������
angle=(linspace(0,360-360/n,n)'+270)/180*pi;
aa=asin(xcr/(D/2))+2*pi;    % ָ������������Ե����Բ�ĵ�ֱ��A�������Բ�����µ���ֱ�뾶�� B ��˳ʱ��н�
subAngle=angle>aa & angle<=(5*pi-aa); % ֻλ����ѹ���ĸֽ�
if portion==-1 % ˵��ֻҪ����ѹ���ĸֽ����ָ��������ľ�
    angle=angle(subAngle);   % ֻλ����ѹ���ĸֽ�
elseif portion==1 % ˵��ֻҪ���������ĸֽ����ָ��������ľ�
    angle=angle(~subAngle);   % ֻλ���������ĸֽ�
end
distance=abs(R_bar*sin(angle)-xcr);   % ÿһ���ֽ�����ĵ㵽ָ����������ľ���
if order==2   % ����Ծ�
    S1=pi/4*r^4*length(distance);   % ָ������ĸֽ������������ĵĹ��Ծ�
    steel=S1+pi*r^2*(sum(distance.^2));   % �ֽ�Ĺ��Ծ�
else    % �󾲾�
    S1=pi*r^2;  % ָ������ĸֽ�����
    steel=S1*sum(distance);
end
end