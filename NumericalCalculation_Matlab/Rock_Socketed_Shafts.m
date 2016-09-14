function varargout = Rock_Socketed_Shafts(varargin)
% E:\2013水下桩基分析\matlab计算\matlab\Rock_Socketed_Shafts
% 整个程序的GUI界面
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
% --- 在窗口打开前进行初始参数的设置等操作
function Rock_Socketed_Shafts_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)
% Choose default command line output for Rock_Socketed_Shafts
handles.output = hObject;
%% 将当前文件夹设置为此.m文件所在的文件夹

% 程序集的基本文件夹的路径
global Dir_global;
global Dir_Results;
Dir_global = fileparts( which('Rock_Socketed_Shafts'));
Dir_Results =fullfile(Dir_global,'Results');

cd(Dir_global)
% addnewpath
currentfolder=pwd;
% newpath=fullfile(currentfolder,'subFunctions');
addpath(genpath(currentfolder)); % 添加指定的文件夹及其子文件夹到搜索路径中。
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
% winopen('参数列表.xlsx');

% 弹出对话框以选择 .sss 参数文件
[fileName,pathName,FilterIndex] = uigetfile({'*.sss','嵌岩桩 (*.sss)'},'Select the sss parameter file');
if FilterIndex ~= 0
    % 读取参数 xml 文件
    filePath =fullfile(pathName,fileName);
    handles.OriginalParameters = ParaSet_xml(filePath);
    
    %
    set(handles.textShaftName,'string',handles.OriginalParameters.ShaftName);
    guidata(hObject, handles);
end


% --- Executes on button press in generate.
%% 开始计算 ------------  开始计算 ------------  开始计算 ------------  开始计算 ------------
function calculate_Callback(hObject, eventdata, handles)
% hObject    handle to generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 获取水平荷载集合
H= get(handles.uitableHorizontalLoad,'Data');
H = cell2mat(H);
H(H==0) = [];
if isempty(H)
    msgbox('水平荷载未设置','提示','warn','modal');
    return;
end
set(handles.uitableHorizontalLoad,'Data',num2cell(H));
H = H .* 1000; % 将界面中的 KN 转换为 N

%
if ~isfield(handles,'OriginalParameters') || isempty(handles.OriginalParameters)
    msgbox('模型参数未指定','提示','warn','modal');
    return;
end

% 执行主计算程序，计算完成后的结果会保存在 结构体 handles 的相应字段中
% -------------------------------------------------------------
[depth_disp,depth_Moment,displacement,FDMres,curve,Zy,yieldzone] = MainCalculation(handles,handles.OriginalParameters,H);
% -------------------------------------------------------------

%
%% 将最后一个荷载的最后一次计算结果保存下来以供查看
handles.depth_disp=depth_disp;
handles.depth_Moment=depth_Moment;
%
handles.displacement=displacement;
handles.yieldzone=yieldzone;
handles.FDMres=FDMres;
handles.curve=curve;
handles.Zy=Zy;

% 将handles的数据更新到guidata系统
guidata(hObject,handles)
% 启用相应的控件
set([handles.menu_Pz_Pult,handles.menu_tfd,...
    handles.generate,handles.menu_gama,handles.menu_V,handles.menu_OverView],'enable','on')
%% 计算结果的后处理
set(handles.checkbox1,'value',1)
% 在表中显示出屈服截面、土层顶端与桩顶的位移与转角。
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
msgbox('全部计算完成。最后的计算结果可以查看 Results 文件夹中对应的 .mat 文件','成功','warn','modal');
%
%%

% --- Executes on button press in generate.
function generate_Callback(hObject, eventdata, handles)
% hObject    handle to generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 查看三个复选框是否选中
a1=get([handles.checkbox1,handles.checkbox2,handles.checkbox3],'value');
a=cell2mat(a1);
b=zeros(1,3);   % 用来存储三条曲线的句柄值
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
    %绘制指定的曲线
    figure
    axes3=axes;
    grid on
    copyobj(curve,axes3)
    set(gca,'YDir','reverse')  % 将y轴数值区间的起始点和终止点调换
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
set(gca,'YDir','reverse')  % 将y轴数值区间的起始点和终止点调换
title('Pz & Pult (N/m)')
ylabel('z(m)')
grid on

%%
% --------------------------------------------------------------------
% ------ 在表格中显示位移和弯矩值 
function menu_tfd_Callback(hObject, eventdata, handles)
% hObject    handle to menu_tfd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%

%
header_uz=cell(1,4); % 四列数据分别代表：整根桩的深度，对应的位移，嵌固端的深度，对应的弯矩
data=cell(1,4);
%
depth_disp=handles.depth_disp(end);
depth_Moment=handles.depth_Moment(end);
header={'depth(m)','displacement(mm)','depth(m)','moment(KN*m)'};
data{1} = depth_disp.Depth;
data{2} = depth_disp.Disp * 1000;
data{3} = depth_Moment.Depth;
data{4} = depth_Moment.Moment / 1000;

% 调整data 的格式，以适应表格的输入要求
m=max(cellfun(@length,data));
n=length(data);
for i=1:n
    data{i}=num2cell(data{i});
    
    % 将不够的单元格补为空矩阵
    if length(data{i})<m
        data{i}(length(data{i})+1:m)={[]};
    end
    
    % 如果是行向量，则转换为列向量
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
figure( 'name','整个桩段的位移与弯矩',...
    'MenuBar','none','numbertitle','off')
% 创建一个表格
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
% 显示最终结果中的剪力分布图
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
set(gca,'YDir','reverse')  % 将y轴数值区间的起始点和终止点调换
title('shear Force(KN)')
ylabel('z(m)')
grid on

%% --------------------------------------------------------------
% 将所有计算过程中的结果全部显示出来
function menu_OverView_Callback(hObject, eventdata, handles)
% hObject    handle to menu_OverView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FDMRes=handles.FDMres;
% 查看一共进行了n次有限差分计算，则要在窗口中绘制出 n-by-4个subplot；
Count=length(FDMRes);
% 设置每一类图形的x轴的范围相同
limMin=zeros(3,1);
limMax=zeros(3,1);
res=FDMRes(1);
% 定义最大值与最小值的初值
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
% 将对应的极限值调整为整数
expo10=fix(log10(abs(lim)))          %用科学计数法表示时，e后面的项，如1.2e5，则返回的值为5
exmaxU=max(expo10([1 2]));
exmaxM=max(expo10([3 4]));
exmaxV=max(expo10([5 6]));
mi=lim./10.^([exmaxU exmaxU exmaxM exmaxM exmaxV exmaxV]')
limMin=floor(mi([1 3 5])).*10.^[exmaxU,exmaxM,exmaxV]'  % 向量中有三个值，分别代表最终的 minU,minM,minV
limMax=ceil(mi([2 4 6])).*10.^[exmaxU,exmaxM,exmaxV]'   % 向量中有三个值，分别代表最终的 maxU,maxM,maxV
%}

% 打开绘图面板
[~,h_panel]=PanelForOverView;
% 优化面板的高度
rec=get(h_panel,'position');
set(h_panel,'position',[rec(1),rec(2),rec(3),rec(3)/4*Count])
% 按从左至右的顺序依次绘制：反力与极限承载力分布、剪力分布、弯矩分布、位移分布。
for i=1:Count
    res=FDMRes(i);
    % 反力分布图
    ax=subplot(Count,4,4*(i-1)+1);
    rec=get(ax,'position');
    res.plot_pz(gca);
    hold on
    % 下面这句绘制极限承载力曲线的函数，如果用符号表达式的话，结果会很耗时。所以最后采用了利用向量进行线性插件的方法。
    handles.OriginalParameters.plot_pult(ax); % 这句绘制极限承载力曲线的函数可能很耗时
    set(ax,'parent',h_panel,...
        'PlotBoxAspectRatio',[1,1,1],...
        'ylim',[0,ceil(sum(handles.OriginalParameters.l))])
    %绘制一个文本，以显示第i次计算
    uicontrol(...
        'style','text',...
        'parent',h_panel,...
        'unit','normalized',...
        'string',['（',num2str(i),'）'],...
        'position',[0.02,rec(2)+rec(4)/2.3,0.05,0.03],...
        'FontSize',15,...
        'BackgroundColor',[0.784,0.901,0.784]);
    
    %剪力分布图
    ax=subplot(Count,4,4*(i-1)+2);
    res.plot_ShearForce(gca);
    set(ax,'parent',h_panel,...
        'PlotBoxAspectRatio',[1,1,1],...
        'xlim',[limMin(3),limMax(3)],...
        'ylim',[0,ceil(sum(handles.OriginalParameters.l))])
    
    % 弯矩分布图
    ax=subplot(Count,4,4*(i-1)+3);
    res.plot_BendingMoment(gca);
    set(ax,'parent',h_panel,...
        'PlotBoxAspectRatio',[1,1,1],...
        'xlim',[limMin(2),limMax(2)],...
        'ylim',[0,ceil(sum(handles.OriginalParameters.l))])
    
    % 位移分布图
    ax=subplot(Count,4,4*(i-1)+4);
    res.plot_Displacement(gca);
    set(ax,'parent',h_panel,...
        'PlotBoxAspectRatio',[1,1,1],...
        'xlim',[limMin(1),limMax(1)],...
        'ylim',[0,ceil(sum(handles.OriginalParameters.l))])
end


% ------- 不能删 ----------------------------------------------------------
function menu_Tables_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Tables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% ------------ 不能删 -----------------------------------------------------
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
% 先检查输入值是否合格
if  isnan(eventdata.NewData)
    H{eventdata.Indices(1),eventdata.Indices(2)} = 0;
end
% 如果是最后一行，则添加一行
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
