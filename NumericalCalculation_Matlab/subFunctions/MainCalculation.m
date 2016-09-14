function [depth_disp,depth_Moment,displacement,FDMres,curve,Zy,yieldzone] = MainCalculation(handles,OriPar,H)
%
% ���������
%       depth_disp ������׮������ˮ�У���λ������
%       depth_Moment ������Ƕ�̶����еĽڵ�����ֵ���Ӧ����ء�
%       ������������������һ��ˮƽ���ص����һ�� overall ��������

global Dir_Results;
global considerYieldofPileInWater  % �Ƿ���ˮ��׮����������µĿ������Ӧ�ĸնȼ�С��
global ConsiderCrackofPileInEarth  % �Ƿ�������׮����������µĿ������Ӧ�ĸնȼ�С��
considerYieldofPileInWater=true;
ConsiderCrackofPileInEarth=considerYieldofPileInWater;

%% �޸�ԭʼ����
direction = zeros(length(H),1);
H_D = [H,direction];

%% ������������
global SearchingDirection
Hs3=H_D(:,1);
Direction=H_D(:,2);   % �����������ķ���
%
M=Hs3*OriPar.lw;
% OriPar.lw=0;
%
EI=OriPar.epip;   % ��������ģ��
%%
count_Load=length(Hs3);
u_pileHead=zeros(count_Load,1); % ����׮��
topu_unYield=zeros(count_Load,1);  % δ������������λ��
topr_unYield=topu_unYield;  % δ������������λ��

% Ҫ��ȡ��������λ�ơ������Ϣ
temp_c  = cell(1,count_Load);
depth_disp=struct('Depth',temp_c,'Disp',temp_c);     % ����׮��λ������
depth_Moment=struct('Depth',temp_c,'Moment',temp_c);     % ����Ƕ�̶����еĽڵ�����ֵ���Ӧ����ء�

%
curve_u=cell(count_Load,1);   % ÿһ���������õ����յ�λ������
%%
Count=1;    % �ܹ�����Ĵ���
for i=1:count_Load
    blnYield=true;    % ׮���Ƿ�������
    norm_diff=1000000;
    j_norm=1;
    SearchingDirection=Direction(i);
    % ����׮�����Ƿ�������Ҫ��һ�ε������жϣ����ݾ��飬��׮����������������
    % �ٴ�����׮�Ŀ���ն�ֵ�������յĽ��Ӱ���Ѿ���С�ˣ���������������࿼������׮�����������
    while norm_diff>5000 && blnYield  && j_norm<=3
        fprintf(2,[' -------------------\n ��',num2str(i),'�����أ�����Ϊ',num2str(Hs3(i)/1000),'KN\n -------------------\n'])
        fprintf([' -------------------\n ׮�����',num2str(j_norm),'������������\n -------------------\n', ...
            ' ��ʼ��',num2str(Count),'�μ��㡭�� \n -------------------\n'])
        Count=Count+1;
        %
        OriPar.H=Hs3(i);
        OriPar.M=M(i);
        OriPar.epip=EI;
        % ִ�����޲�ּ���
        [displacement,FDMres,curve,Zy,yieldzone]=overall(handles,OriPar);
        res=FDMres(end);
        %
        topu_unYield(i)=res.top_u;
        topr_unYield(i)=res.top_r;
        % ��ʯ�㶥����λ��
        %     u_pileHead(i)=displacement.u_water(1);
        
        % Ƕ�̶ζ�����λ��
        if  yieldzone.exists % ˵����������
            %
            depth_Moment(i).Depth=yieldzone.NodeDepth;
            depth_Moment(i).Moment=yieldzone.BendingMoment;
        else  % ˵��û��������
            %
            depth_Moment(i).Depth=[];
            depth_Moment(i).Moment=[];
        end
        
        % ��δ�������е�λ�����Ӧ�������ӽ�ȥ
        for j=1:length(res.u)
            depth_Moment(i).Depth=[depth_Moment(i).Depth;res.NodeDepth{j}+res.physicalConditions.Zy];
            depth_Moment(i).Moment=[depth_Moment(i).Moment;res.BendingMoment{j}];
        end
        % -------------------------------------------------------------------
        
        %���������-��ء���������е���ͬ���
        temp1=depth_Moment(i).Depth(1:end-1)-depth_Moment(i).Depth(2:end)==0;
        depth_Moment(i).Depth(temp1)=[];
        depth_Moment(i).Moment(temp1)=[];
        
        % �ж�׮���Ƿ�������
        %         curve=plot(ax,depth_Moment{i}.moment,depth_Moment{i}.depth);
        % ��׮�е������ν��д���
        [blnYield, EI]=yieldInPile(OriPar,depth_Moment(i).Depth,depth_Moment(i).Moment);
        EI_now=EI;
        if j_norm==1
            norm_diff=1000000;
            % set(curve,'color','red')
        else
            norm_diff=norm(EI_now-EI_last,2);
        end
        EI_last=EI_now;
        j_norm=j_norm+1;         % ��Ϊ׮�������������Ĵ���
    end
    
    curve_u{i}=curve.u;     % ÿһ���������õ����յ�λ������
    
    % Depth_disp:����һ�����µļ������У�����׮�ε����нڵ�ı�߼���Ӧ��λ��
    Depth_disp_local=res.GetDepth_u;
    
    if isfield(displacement, 'u_water') % ˵�������ˮ��׮�γ��Ȳ�Ϊ0��
        u_pileHead(i)=displacement.u_water(1);
        
        % �ֱ���ȡ����׮��ˮ�С���������δ���������е����꣨���㶥Ϊ0�����Ӧ��λ�ơ�
        depth_disp(i).Depth=[depth_disp(i).Depth;
            displacement.depth_Water - displacement.depth_Water(end);
            yieldzone.NodeDepth;
            Depth_disp_local(:,1)];
        depth_disp(i).Disp=[depth_disp(i).Disp;
            displacement.u_water;
            yieldzone.u;
            Depth_disp_local(:,2)];
        
    else   % ˵�������ˮ��׮�γ���Ϊ0�����Բ�����ˮ�е�׮�Ρ�
        %
        if res.physicalConditions.Zy>0  % ˵����������
            u_pileHead(i)=displacement.u_yield(1);  % ׮��λ�Ƽ�ΪǶ�̶ζ���λ��
        else  % ˵������Ƕ�̶ζ�û������
            u_pileHead(i)=displacement.unyieldtopdi;  % ׮��λ�Ƽ�ΪǶ�̶ζ���λ��
        end
        
        % �ֱ���ȡ����׮Ƕ�Ҳ��֣���������δ���������е����꣨���㶥Ϊ0�����Ӧ��λ�ơ�
        depth_disp(i).Depth=[depth_disp(i).Depth;
            yieldzone.NodeDepth;
            Depth_disp_local(:,1)];
        depth_disp(i).Disp=[depth_disp(i).Disp;
            yieldzone.u;
            Depth_disp_local(:,2)];
    end
    
    %���������-λ�ơ���������е���ͬ���
    temp1=depth_disp(i).Depth(1:end-1)-depth_disp(i).Depth(2:end)==0;
    depth_disp(i).Depth(temp1)=[];
    depth_disp(i).Disp(temp1)=[];    
end

% ������Ӧ�Ŀؼ�
set([handles.menu_Pz_Pult,handles.menu_tfd,...
    handles.generate,handles.menu_gama,handles.menu_V,handles.menu_OverView],'enable','on')

% �����������б���
matFilePath = fullfile(Dir_Results,[OriPar.ShaftName,'.mat']);
save(matFilePath,'depth_disp','depth_Moment');