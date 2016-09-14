function [displacement,FDMres,curve,Zy,yieldzone]=overall(handles,OriginalParameters)
% ���������Ĵ���˼·�Ƿ�Ϊ�����޲�ּ��㡢�ó������㡢�����ضϣ����²��������޲�ּ���...
% ��δ������������1cm���Ϊ����������������ʱӦ���޸�ԭʼ������
% ���������
% handles   GUI���洰���е�handles��
% OriginalParameters    ����������Ŀ��ԭʼ�������
%
% ���������
% FDMres    һ�������飬ÿһ��Ԫ�ض���һ�� FDMResults �࣬���ж�������һ�����޲�ּ���������Ҫ������������Լ����еļ�������
% yieldzone һ���࣬�������������е��������
% curve     ���洰�������л��Ƶ�plot���ߵľ��ֵ
%
% see also:Rock_Socketed_Shafts,OriginalProjectParameters,FDMResults

% % ���Ƽ��޳���������
% figure
% save 1
% OriginalParameters.plot_pult(gca);
% grid on
% return
hold(handles.axes1,'on');
hold(handles.axes2,'on')
grid(handles.axes1,'on')
grid(handles.axes2,'on')
%% ���������趨
% assignin('base','OriginalParameters',OriginalParameters) % ���ڲ��Բ鿴
R=OriginalParameters.R;
l=OriginalParameters.l;
epip=OriginalParameters.epip;
% ip=OriginalParameters.ip;
e1=OriginalParameters.e1;
e2=OriginalParameters.e2;
v=OriginalParameters.v;
H=OriginalParameters.H;
M=OriginalParameters.M;
nlayer=OriginalParameters.nlayer;
lw=OriginalParameters.lw;
pultfun=OriginalParameters.pultfun;% �õ���ʾ���޳������ı���pultf��Ϊ�����pultz�������á�
% set(handles.figure1,'CurrentAxes',handles.axes1)
curve.pult=OriginalParameters.plot_pult(handles.axes1);
%% ���������޲�ַ����λ��u������V���뷴��p
%
physicalConditions = FDMphysicalConditions(R,l,epip,e1,e2,v,H,M,nlayer,0);
results=finitedifference(physicalConditions); %ִ�����޲�ַ�������Ҫ��13�������������load���õ�����
FDMres=results;
%[nseg r u V pz]
nseg=results.nseg;
r=results.r;
u=results.u;
pz=results.pz;
% 
% save forplot.mat
%% ��ʱ���Բ鿴��һ�����޲�ֺ�õ���λ�ƣ��ֲ����ȡ�
% ���Ƶ�һ����������
curve_pz_num=1;
% curve.pz(curve_pz_num)=results.plot_pz(handles.axes1,curve_pz_num); 
drawnow
%% �������� �ı���� ���е�����������յ��������Zy
zy=zeros(1,10); %һ�����������е�i��Ԫ�ض�������е�i�����޲�ּ����õ���������ȵ�������
zy(1)=zyield(OriginalParameters,results); %����������zy��zy(1)��ʾ��һ�����޲�ֺ�õ���������ȡ�
%%
r_logic=(r~=0);    % һ��������(r_logic-2)�Σ���һ��ֵ�Ǽ���ģ�û���ã����һ����������ѭ�������������޲�ּ��㡣
r_logic(1)=0;
r_data=num2cell(r(r_logic)); %������ʾ��r��ֵ
r_length=length(r_data);
data_for_table=get(handles.uitable1,'data');
data_for_table{2,1}=r_length-1;
data_for_table{1,1}=zy(1);
data_for_table(3:2+r_length,1)=r_data;
rowname_table1=get(handles.uitable1,'rowname');
set(handles.uitable1,'data',data_for_table,'rowname',[rowname_table1;num2cell((1:r_length)')])
%%
zynum=0;
while zy(zynum+1)>0.05  %��zyield�����У����µ���������С��5cmʱ����Ϊ�¶�û�з���������
    zynum=zynum+1; % zynum ��ֵ��������׮�Ѿ����������Ĵ���
    % �۲�һ��H�仯�����ơ�
    [H M e1 e2 v epip l nlayer,zy]=parachange(OriginalParameters,physicalConditions,pultfun,zy,zynum);
    physicalConditions = FDMphysicalConditions(R,l,epip,e1,e2,v,H,M,nlayer,sum(zy));
    results=finitedifference(physicalConditions); %ִ�����޲�ַ�
    FDMres=[FDMres;results];
    %[nseg r u V pz]
    nseg=results.nseg;
    r=results.r;
    u=results.u;
    pz=results.pz;
    %-----------
    %��ʱ���Բ鿴��(zynum+1)�����޲�ֺ�õ���λ�ƣ��ֲ����ȡ�
    %pz������Ϊ[0,l]+sum(zy)
    %����Ϊ��һ�αȶԳ�zyield�õ���������ȣ���Ϊsum(zy)+zy(zynum+1)����pz�����Ϊ��һ�������Ľضϴ�����Ϊsum(zy)
    %�ɴ˴μ���õ���pz�����µ�������
    %% ��ʱ���Բ鿴��i�����޲�ֺ�õ���λ�ƣ��ֲ����ȡ�
    curve_pz_num=curve_pz_num+1;
%      curve.pz(curve_pz_num)=results.plot_pz(handles.axes1,curve_pz_num);  
    drawnow
    zy(zynum+1)=zyield(OriginalParameters,results);  %�����(zynum+1)�ε�����������
    %%
    %������������޲�ַ��ĵ���������
    r_logic=(r~=0);    % һ��������(r_logic-2)�Σ���һ��ֵ�Ǽ���ģ�û���ã����һ����������ѭ�������������޲�ּ��㡣
    r_logic(1)=0;
    r_data=num2cell(r(r_logic)); %������ʾ��r��ֵ
    r_length=length(r_data);
    data_for_table=get(handles.uitable1,'data');
    data_for_table{2,zynum+1}=r_length-1;
    data_for_table{1,zynum+1}=zy(zynum+1);
    data_for_table(3:2+r_length,zynum+1)=r_data; % �Ը�ֵ�ķ�ʽ����cell����ϡ�
    % ����rowname
    rowname_table1=get(handles.uitable1,'rowname');
    rowmax=max(size(rowname_table1,1)-2,r_length);
    rowname_table1=rowname_table1(1:2);
    %
    set(handles.uitable1,'data',data_for_table,'rowname',[rowname_table1;num2cell((1:rowmax)')]);
    %%
    if sum(l)-zy(zynum+1)<0.1
        error('����ȫ�����������޸��������')
        % �������׮ʣ�µ�δ�����εĳ��Ȳ���10cm����Ϊ����������������׮��������ʵ�ʡ�
        % Ҳ��Ϊ�˷�ֹ��l��Сʱ�������bessel������ֵ��С�����¼������
    end
end
curve.pz(curve_pz_num)=results.plot_pz(handles.axes1,curve_pz_num);
%% �õ��˵�����������������Zy����һ���ָ�һ���䡣
Zy=sum(zy)-zy(zynum+1);
% �����ȥzy(zynum+1)��Ϊ��������while�ж��и������Ǹ�С��0.001m����
% ----------------------
displacement.u=u;
% loadings.p=pz;
% loadings.v=V;
%
%���������������ֶ������ݸ����
promptText = {['����������: ',num2str(length(find(zy)))];
    ['����������� : ',num2str(Zy), ' m'];};
set(handles.text1,'string',promptText);
%
%%
%------------------------------------------------------------------------
% �õ��˵�����������������Zy����һ���ָ�һ���䡣
% ���濪ʼ����Ƕ�̶�����������λ����ת�Ǽ��㣬�Լ�ˮ�к�ˮ�ϲ��ֵ�׮�ε�λ�ƺ�ת�Ǽ��㡣
% -----------------------------------------------------------------------
%% ���Ƕ��׮�������ε�λ�ƺ�ת��
displacement.unyieldtopdi=results.top_u;
displacement.unyieldtopro=results.top_r;
waterbottomdi=results.top_u;%���ڼ���ˮ�жεײ�λ�ơ�
waterbottomro=results.top_r;%���ڼ���ˮ�жεײ�ת�ǡ�
%

if Zy==0
    yieldzone=YieldZone();
else
    yieldzone=YieldZone(OriginalParameters,results.top_u,results.top_r,Zy);
    waterbottomdi=yieldzone.top_u;
    waterbottomro=yieldzone.top_r;
    %
    densey=40;
    depthYieldZone=linspace(0,Zy,densey)';
    [uYield,rYield,moment_Yield]=uyzone(OriginalParameters,results,depthYieldZone); % �Ա�����ȡֵ��Χֻ���Ǵ�0��Zy

    displacement.depth_Yield=depthYieldZone;    % ��������ÿһ���ڵ����ڵ���ȣ������Ƕ�̶˶�������
    displacement.u_yield=uYield';
    displacement.r_yield=rYield';
    displacement.moment_Yield=moment_Yield';
    %�����εĶ�����λ�ƺ�ת�Ƿֱ��������������ĵ�һ��Ԫ�ء�
    %�õ�Ƕ��׮�������ζ��˵�λ�ƺ�ת�ǣ��Թ��������ˮ�е�׮��λ�ƺ�ת��֮�á�
    waterbottomdi=uYield(1) ;% Ҳ������ uYield(1);%����������Σ���ˮ�жεײ�λ�ƾ��������ζ���λ�ƣ�������������δ�����ζ���λ�ơ�
    waterbottomro=rYield(1) ;% Ҳ������ rYield(1);
    %}
end
%% ���ˮ��׮�ε�λ�ƺ�ת��
if lw~=0
    densew=40;
    depthInWater=linspace(0,lw,densew)';
    % ȷ�������ײ���ˮƽλ����ת�Ǳ߽�����
    if Zy==0
        waterbottomdi=u{1}(3);
        waterbottomro=(u{1}(4)-u{1}(3))/(l(1)/nseg(1));
    end
%
    [uw rw]=uwater(OriginalParameters,depthInWater,waterbottomdi,waterbottomro);
    displacement.u_water=uw;
    displacement.r_water=rw;
    displacement.depth_Water=depthInWater;
end
%% ��������׮��λ��ȫ��������ɡ�
% ------------------------------------------------------------------------
% ��������׮��λ��ȫ��������ɡ�
% δ��������λ�������޲�ַ��ó���
% ��������λ����uyzone()�����õ�������Ϊ�������ļ��޳���������pultfun���ű����õ�����
% ˮ��׮�ε�λ����uwater()�����õ���������ˮ�ķ�����
%
% δ��������λ���ɱ���u��ʾ��ÿ����Ϊu{i}(3,nseg(i)+3);
% ��������λ����ת���ɱ��� uyield �� ryield ��ʾ��Ƕ�̶˶���λ����ת�Ƿֱ��Ǳ��� usoketed_top=subs(di) �� rsoketed_top ;
% ˮ�жε�λ����ת�Ƿֱ��Ǳ��� uw �� rw ������׮����λ����ת�Ƿֱ��Ǳ��� utop �� rtop ��
% -----------------------------------------------------------------------
%% �������׮��λ�����ߡ�
% set(handles.figure1,'CurrentAxes',handles.axes2)
% ����δ����׮�ε�λ������
curve.u(1)=results.plot_Displacement(handles.axes2);
% ������������λ�����ߣ�ע��׮���ֵ�ķ�Χ����0��Zy������Ϊ����ȫ�ֶ��ԣ����׼�������㶥����������ˮ���׮����
if Zy~=0
    curve.u(2)=yieldzone.plot_u(handles.axes2); % plot(handles.axes2,yield.u,yieldzone.NodeDepth,'r');
end

% ����ˮ��׮��λ�����ߣ�ע��׮���ֵ�ķ�Χ����-lw��0������Ϊ����ȫ�ֶ��ԣ����׼�������㶥����������ˮ���׮����
if lw~=0
    i=linspace(-lw,0,densew)';
    curve.u(3)=plot(handles.axes2,uw,i,'b');
    set(curve.u(3),'linewidth',2)
end
%% THE END
end