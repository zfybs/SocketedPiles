function varargout = Rock_Socketed_Shafts(varargin)
% E:\2013ˮ��׮������\matlab����\matlab\Rock_Socketed_Shafts
% ���������GUI����
% See also:FDMphysicalConditions , FDMResults , OriginalProjectParameters

% Edit the above text to modify the response to help Rock_Socketed_Shafts

% Last Modified by GUIDE v2.5 01-Sep-2016 17:03:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Rock_Socketed_Shafts_OpeningFcn, ...
    'gui_OutputFcn',  @Rock_Socketed_Shafts_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before Rock_Socketed_Shafts is made visible.
% --- �ڴ��ڴ�ǰ���г�ʼ���������õȲ���
function Rock_Socketed_Shafts_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)
% Choose default command line output for Rock_Socketed_Shafts
handles.output = hObject;
%% ����ǰ�ļ�������Ϊ��.m�ļ����ڵ��ļ���

% ���򼯵Ļ����ļ��е�·��
global Dir_global;
global Dir_Results;
Dir_global = fileparts( which('Rock_Socketed_Shafts'));
Dir_Results =fullfile(Dir_global,'Results');

cd(Dir_global)
% addnewpath
currentfolder=pwd;
% newpath=fullfile(currentfolder,'subFunctions');
addpath(genpath(currentfolder)); % ���ָ�����ļ��м������ļ��е�����·���С�
addpath('..')

%%
axes(handles.axes1)
title('Pz & Pult(N/m)')
axes(handles.axes2)
title('uz,uy and uw(m)')
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = Rock_Socketed_Shafts_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string',pwd);
guidata(hObject, handles);

% --- Executes on button press in parameters_setting.
function parameters_setting_Callback(hObject, eventdata, handles)
% hObject    handle to parameters_setting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% winopen('�����б�.xlsx');

% �����Ի�����ѡ�� .sss �����ļ�
[fileName,pathName,FilterIndex] = uigetfile({'*.sss','Ƕ��׮ (*.sss)'},'Select the sss parameter file');
if FilterIndex ~= 0
    % ��ȡ���� xml �ļ�
    filePath =fullfile(pathName,fileName);
    handles.OriginalParameters = ParaSet_xml(filePath);
    
    %
    set(handles.textShaftName,'string',handles.OriginalParameters.ShaftName);
    guidata(hObject, handles);
end


% --- Executes on button press in generate.
%% ��ʼ���� ------------  ��ʼ���� ------------  ��ʼ���� ------------  ��ʼ���� ------------
function calculate_Callback(hObject, eventdata, handles)
% hObject    handle to generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ��ȡˮƽ���ؼ���
H= get(handles.uitableHorizontalLoad,'Data');
H = cell2mat(H);
H(H==0) = [];
if isempty(H)
    msgbox('ˮƽ����δ����','��ʾ','warn','modal');
    return;
end
set(handles.uitableHorizontalLoad,'Data',num2cell(H));
H = H .* 1000; % �������е� KN ת��Ϊ N

%
if ~isfield(handles,'OriginalParameters') || isempty(handles.OriginalParameters)
    msgbox('ģ�Ͳ���δָ��','��ʾ','warn','modal');
    return;
end

% ִ����������򣬼�����ɺ�Ľ���ᱣ���� �ṹ�� handles ����Ӧ�ֶ���
% -------------------------------------------------------------
[depth_disp,depth_Moment,displacement,FDMres,curve,Zy,yieldzone] = MainCalculation(handles,handles.OriginalParameters,H);
% -------------------------------------------------------------

%
%% �����һ�����ص����һ�μ��������������Թ��鿴
handles.depth_disp=depth_disp;
handles.depth_Moment=depth_Moment;
%
handles.displacement=displacement;
handles.yieldzone=yieldzone;
handles.FDMres=FDMres;
handles.curve=curve;
handles.Zy=Zy;

% ��handles�����ݸ��µ�guidataϵͳ
guidata(hObject,handles)
% ������Ӧ�Ŀؼ�
set([handles.menu_Pz_Pult,handles.menu_tfd,...
    handles.generate,handles.menu_gama,handles.menu_V,handles.menu_OverView],'enable','on')
%% �������ĺ���
set(handles.checkbox1,'value',1)
% �ڱ�����ʾ���������桢���㶥����׮����λ����ת�ǡ�
Data=get(handles.uitable2,'data');
Data{4,2}=handles.displacement.unyieldtopdi*1000;
Data{4,3}=handles.displacement.unyieldtopro;
if Zy==0
    set(handles.checkbox2,'value',0,'enable','off')
else
    %     Data{3,2}=handles.displacement.u_yield(1)*1000;
    %     Data{3,3}=handles.displacement.r_yield(1);
    Data{3,2}=handles.yieldzone.top_u*1000;
    Data{3,3}=handles.yieldzone.top_r;
end
if handles.OriginalParameters.lw==0
    set(handles.checkbox3,'value',0,'enable','off')
else
    Data{2,2}=handles.displacement.u_water(1)*1000;
    Data{2,3}=handles.displacement.r_water(1);
end
set(handles.uitable2,'data',Data)
guidata(hObject, handles);
%
msgbox('ȫ��������ɡ����ļ��������Բ鿴 Results �ļ����ж�Ӧ�� .mat �ļ�','�ɹ�','warn','modal');
%
%%

% --- Executes on button press in generate.
function generate_Callback(hObject, eventdata, handles)
% hObject    handle to generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% �鿴������ѡ���Ƿ�ѡ��
a1=get([handles.checkbox1,handles.checkbox2,handles.checkbox3],'value');
a=cell2mat(a1);
b=zeros(1,3);   % �����洢�������ߵľ��ֵ
b(1)=handles.curve.u(1);
if handles.Zy ~=0
    b(2)=handles.curve.u(2);
end
if handles.OriginalParameters.lw ~= 0
    b(3)=handles.curve.u(3);
end

c=logical(a);
curve=b(c);
if ~isempty(curve)
    %����ָ��������
    figure
    axes3=axes;
    grid on
    copyobj(curve,axes3)
    set(gca,'YDir','reverse')  % ��y����ֵ�������ʼ�����ֹ�����
    title('uz,uy and uw(m)')
    ylabel('z(m)')
end
%%
% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c2=get(handles.checkbox2,'value');
if c2==1
    set(handles.checkbox1,'value',1)
end
% Hint: get(hObject,'Value') returns toggle state of checkbox2
% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c3=get(handles.checkbox3,'value');
if c3==1
    set(handles.checkbox1,'value',1)
    if handles.Zy~=0
        set(handles.checkbox2,'value',1)
    end
end
% Hint: get(hObject,'Value') returns toggle state of checkbox3

% --------------------------------------------------------------------
function menu_Pz_Pult_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Pz_Pult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=figure;
a=axes;
copyobj(get(handles.axes1,'children'),a);
set(gca,'YDir','reverse')  % ��y����ֵ�������ʼ�����ֹ�����
title('Pz & Pult (N/m)')
ylabel('z(m)')
grid on

%%
% --------------------------------------------------------------------
% ------ �ڱ������ʾλ�ƺ����ֵ 
function menu_tfd_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tfd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%

%
header_uz=cell(1,4); % �������ݷֱ��������׮����ȣ���Ӧ��λ�ƣ�Ƕ�̶˵���ȣ���Ӧ�����
data=cell(1,4);
%
depth_disp=handles.depth_disp(end);
depth_Moment=handles.depth_Moment(end);
header={'depth(m)','displacement(mm)','depth(m)','moment(KN*m)'};
data{1} = depth_disp.Depth;
data{2} = depth_disp.Disp * 1000;
data{3} = depth_Moment.Depth;
data{4} = depth_Moment.Moment / 1000;

% ����data �ĸ�ʽ������Ӧ��������Ҫ��
m=max(cellfun(@length,data));
n=length(data);
for i=1:n
    data{i}=num2cell(data{i});
    
    % �������ĵ�Ԫ��Ϊ�վ���
    if length(data{i})<m
        data{i}(length(data{i})+1:m)={[]};
    end
    
    % ���������������ת��Ϊ������
    if size(data{i},2)>1
        data{i} = data{i}';
    end
    
end
Data=cat(2,data{:});
%
%-----export to excel file.
% handles.Data=Data;
% guidata(hObject,handles);
% xlswrite('displacement.xlsx',Data);
% winopen('displacement.xlsx')
%
figure( 'name','����׮�ε�λ�������',...
    'MenuBar','none','numbertitle','off')
% ����һ�����
tfd=uitable('units','normalized','position',[0 0 1 1],...
    'columnname',header);
set(tfd,'data',Data)

% --------------------------------------------------------------------
function menu_gama_Callback(hObject, eventdata, handles)
% hObject    handle to menu_gama (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure
t=copyobj(handles.uitable1,gcf);
set(t,'position',[0 0 1 1])

%% --------------------------------------------------------------------
% ��ʾ���ս���еļ����ֲ�ͼ
function menu_V_Callback(hObject, eventdata, handles)
% hObject    handle to menu_V (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Zy=handles.Zy;
figure;
axes;
for i=1:length(handles.FDMres)
    handles.FDMres(i).plot_ShearForce(gca)
    hold on
end
set(gca,'YDir','reverse')  % ��y����ֵ�������ʼ�����ֹ�����
title('shear Force(KN)')
ylabel('z(m)')
grid on

%% --------------------------------------------------------------
% �����м�������еĽ��ȫ����ʾ����
function menu_OverView_Callback(hObject, eventdata, handles)
% hObject    handle to menu_OverView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FDMRes=handles.FDMres;
% �鿴һ��������n�����޲�ּ��㣬��Ҫ�ڴ����л��Ƴ� n-by-4��subplot��
Count=length(FDMRes);
% ����ÿһ��ͼ�ε�x��ķ�Χ��ͬ
limMin=zeros(3,1);
limMax=zeros(3,1);
res=FDMRes(1);
% �������ֵ����Сֵ�ĳ�ֵ
limMin(1)= res.u{1}(1);                % minU
limMax(1)= limMin(1);                     % maxU
limMin(2)= res.BendingMoment{1}(1);	% minM
limMax(2)= limMin(2);                     % maxM
limMin(3)= res.ShearForce{1}(1);	% minV
limMax(3)= limMin(3);                 % maxV
%     limMin(4)= res.pz{1}(1);           % minP
%     limMax(4)= lim(7);                 % maxP
for i=1:Count
    res=FDMRes(i);
    limMin(1)=min(limMin(1),min(cellfun(@min,res.u)));	% minU
    limMax(1)=max(limMax(1),max(cellfun(@max,res.u)));	% maxU
    limMin(2)=min(limMin(2),min(cellfun(@min,res.BendingMoment)));	% minM
    limMax(2)=max(limMax(2),max(cellfun(@max,res.BendingMoment)));	% maxM
    limMin(3)=min(limMin(3),min(cellfun(@min,res.ShearForce)));	% minV
    limMax(3)=max(limMax(3),max(cellfun(@max,res.ShearForce)));	% maxV
    %         limMin(4)=min([limMin(4);res.pz{j}]);	% minP
    %         limMax(4)=max([limMin(4);res.pz{j}]);	% maxP
end
limMax=limMax+0.03*(limMax-limMin);
limMin=limMin-0.03*(limMax-limMin);
%{
% ����Ӧ�ļ���ֵ����Ϊ����
expo10=fix(log10(abs(lim)))          %�ÿ�ѧ��������ʾʱ��e��������1.2e5���򷵻ص�ֵΪ5
exmaxU=max(expo10([1 2]));
exmaxM=max(expo10([3 4]));
exmaxV=max(expo10([5 6]));
mi=lim./10.^([exmaxU exmaxU exmaxM exmaxM exmaxV exmaxV]')
limMin=floor(mi([1 3 5])).*10.^[exmaxU,exmaxM,exmaxV]'  % ������������ֵ���ֱ�������յ� minU,minM,minV
limMax=ceil(mi([2 4 6])).*10.^[exmaxU,exmaxM,exmaxV]'   % ������������ֵ���ֱ�������յ� maxU,maxM,maxV
%}

% �򿪻�ͼ���
[~,h_panel]=PanelForOverView;
% �Ż����ĸ߶�
rec=get(h_panel,'position');
set(h_panel,'position',[rec(1),rec(2),rec(3),rec(3)/4*Count])
% ���������ҵ�˳�����λ��ƣ������뼫�޳������ֲ��������ֲ�����طֲ���λ�Ʒֲ���
for i=1:Count
    res=FDMRes(i);
    % �����ֲ�ͼ
    ax=subplot(Count,4,4*(i-1)+1);
    rec=get(ax,'position');
    res.plot_pz(gca);
    hold on
    % ���������Ƽ��޳��������ߵĺ���������÷��ű��ʽ�Ļ��������ܺ�ʱ�����������������������������Բ���ķ�����
    handles.OriginalParameters.plot_pult(ax); % �����Ƽ��޳��������ߵĺ������ܺܺ�ʱ
    set(ax,'parent',h_panel,...
        'PlotBoxAspectRatio',[1,1,1],...
        'ylim',[0,ceil(sum(handles.OriginalParameters.l))])
    %����һ���ı�������ʾ��i�μ���
    uicontrol(...
        'style','text',...
        'parent',h_panel,...
        'unit','normalized',...
        'string',['��',num2str(i),'��'],...
        'position',[0.02,rec(2)+rec(4)/2.3,0.05,0.03],...
        'FontSize',15,...
        'BackgroundColor',[0.784,0.901,0.784]);
    
    %�����ֲ�ͼ
    ax=subplot(Count,4,4*(i-1)+2);
    res.plot_ShearForce(gca);
    set(ax,'parent',h_panel,...
        'PlotBoxAspectRatio',[1,1,1],...
        'xlim',[limMin(3),limMax(3)],...
        'ylim',[0,ceil(sum(handles.OriginalParameters.l))])
    
    % ��طֲ�ͼ
    ax=subplot(Count,4,4*(i-1)+3);
    res.plot_BendingMoment(gca);
    set(ax,'parent',h_panel,...
        'PlotBoxAspectRatio',[1,1,1],...
        'xlim',[limMin(2),limMax(2)],...
        'ylim',[0,ceil(sum(handles.OriginalParameters.l))])
    
    % λ�Ʒֲ�ͼ
    ax=subplot(Count,4,4*(i-1)+4);
    res.plot_Displacement(gca);
    set(ax,'parent',h_panel,...
        'PlotBoxAspectRatio',[1,1,1],...
        'xlim',[limMin(1),limMax(1)],...
        'ylim',[0,ceil(sum(handles.OriginalParameters.l))])
end


% ------- ����ɾ ----------------------------------------------------------
function menu_Tables_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Tables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% ------------ ����ɾ -----------------------------------------------------
function menu_Plots_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in uitableHorizontalLoad.
function uitableHorizontalLoad_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitableHorizontalLoad (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

H = get(handles.uitableHorizontalLoad,'Data');
H = H(:,1);
n = size(H,1);
% �ȼ������ֵ�Ƿ�ϸ�
if  isnan(eventdata.NewData)
    H{eventdata.Indices(1),eventdata.Indices(2)} = 0;
end
% ��������һ�У������һ��
if eventdata.Indices(1) == n
    H = [H;0];
end
set(handles.uitableHorizontalLoad,'Data',H(:,1))


% --- Executes during object creation, after setting all properties.
function uitableHorizontalLoad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitableHorizontalLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'data',{0});
