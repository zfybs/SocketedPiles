function [fig,panel]=PanelForOverView
% 创建绘图窗口与panel和滚动条
% panel的宽度：初始设置为屏幕的宽度减去滚动条的宽度
global SCROLL_DEPTH_IN_PIXELS
SCROLL_DEPTH_IN_PIXELS=18;
fig=figure('toolbar','figure');
sliderH=uicontrol('units','pixels','Style','slider');
sliderV=uicontrol('units','pixels','Style','slider');
%
panel=uipanel('unit','pixels');
%
handles.figure=fig;
handles.panel=panel;
handles.sliderH=sliderH;
handles.sliderV=sliderV;
% 下面这个PreviousFigurePosition是为了在设置窗口fig的大小时，用来判断其高度或宽度的增量，
% 以此用来保证panel的top的位置不变。
handles.PreviousFigurePosition = get(fig,'position');
guidata(fig,handles)
%
set(fig,'ResizeFcn',{@figure1_ResizeFcn,guidata(fig)})
set(fig,'WindowScrollWheelFcn',{@figure1_WindowScrollWheelFcn,guidata(fig)})
set(sliderH,'callback',{@sliderH_scroll,guidata(fig)},'backgroundcolor','cyan')
set(sliderV,'callback',{@sliderV_scroll,guidata(fig)},'backgroundcolor','cyan')
%% 设置相应地初始值
set(fig,'Color',[0.784,0.901,0.784])
set(sliderH,'value',0)
set(sliderV,'value',1)
% 设置panel的大小及位置，并让panel的顶部位于figure的顶部。
scrsz = get(0,'ScreenSize');
rec_f=get(fig,'position');
panel_height=scrsz(4)*2;
set(panel,'bordertype','none',...
    'position',[0,rec_f(4)-panel_height,scrsz(3)-SCROLL_DEPTH_IN_PIXELS,panel_height],...
    'BackgroundColor',[0.784,0.901,0.784])


function figure1_ResizeFcn(hObject, eventdata, handles)
sliderH=handles.sliderH;
sliderV=handles.sliderV;
% 下面这个PreviousFigurePosition是为了在设置窗口fig的大小时，用来判断其高度或宽度的增量，
% 以此用来保证panel的top的位置不变。
rec_f_previous=handles.PreviousFigurePosition;
rec_f=get(hObject,'position');
global SCROLL_DEPTH_IN_PIXELS;
set(sliderH,'position',[1,0,rec_f(3)-SCROLL_DEPTH_IN_PIXELS,SCROLL_DEPTH_IN_PIXELS])
set(sliderV,'position',[rec_f(3)-SCROLL_DEPTH_IN_PIXELS+2,SCROLL_DEPTH_IN_PIXELS+1,SCROLL_DEPTH_IN_PIXELS,rec_f(4)-SCROLL_DEPTH_IN_PIXELS])
%
scrsz = get(0,'ScreenSize');
rec_p=get(handles.panel,'position');
if rec_f(3)>rec_p(3)        % 比较panel与figure的宽度
    set(handles.sliderH,'visible','off')
    set(handles.panel,'position',[0,rec_p(2),rec_f(3),rec_p(4)])
else
    set (handles.sliderH,'visible','on')
    if rec_f(3)>scrsz(3)-SCROLL_DEPTH_IN_PIXELS     %如果窗口的宽度比屏幕的宽度大，则将panel的宽度设置为窗口的宽度
        set(handles.panel,'position',[0,rec_p(2),rec_f(3)-SCROLL_DEPTH_IN_PIXELS,rec_p(4)])
    else     %如果窗口的宽度比屏幕的宽度小，则将panel的宽度设置为屏幕的宽度
        set(handles.panel,'position',[0,rec_p(2),scrsz(3)-SCROLL_DEPTH_IN_PIXELS,rec_p(4)])
    end
    
end
if rec_f(4)>rec_p(4)        % 比较panel与figure的高度
    set (handles.sliderV,'visible','off')
    set(handles.panel,'position',[rec_p(1),0,rec_p(3),rec_p(4)]) 
else   %如果窗口的高度小于panel的高度    
    set(handles.panel,'position',[rec_p(1),rec_p(2)+rec_f(4)-rec_f_previous(4),rec_p(3),rec_p(4)])  %保持panel的top的位置不变。
    set (handles.sliderV,'visible','on')
end
handles.PreviousFigurePosition=rec_f;
guidata(hObject,handles)
set(hObject,'ResizeFcn',{@figure1_ResizeFcn,guidata(hObject)})

%%
function sliderH_scroll(hObject, eventdata,handles)
global SCROLL_DEPTH_IN_PIXELS;
%　取得滚动条的值
panel=handles.panel;
pos = get(hObject,'value');
%
rec_p=get(panel,'position');
rec_f=get(gcf,'position');
%　设置panel的位置（左下角点的纵坐标。
set(panel,'position',[pos*(rec_f(3)-rec_p(3)-SCROLL_DEPTH_IN_PIXELS+3),rec_p(2),rec_p(3),rec_p(4)]);

%%
function sliderV_scroll(hObject, eventdata,handles)
global SCROLL_DEPTH_IN_PIXELS;
%　取得滚动条的值
panel=handles.panel;
pos = get(hObject,'value');
%
rec_p=get(panel,'position');
rec_f=get(gcf,'position');
%　设置panel的位置（左下角点的纵坐标。
set(panel,'position',[0,pos*(rec_f(4)-rec_p(4)-SCROLL_DEPTH_IN_PIXELS)+SCROLL_DEPTH_IN_PIXELS,rec_p(3),rec_p(4)]);

%%
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% 获取目前滚动条的值
slidervalue = get(handles.sliderV,'value');
% 获取鼠标滚轮的值，向前滚为正，向后滚为负
scrollvalue = eventdata.VerticalScrollCount/10;
% 确定滚动量
movevalue = slidervalue - scrollvalue;
% 限制滚动范围（防止整个面板都滚出图形）
if movevalue >1
    movevalue = 1;
elseif movevalue < 0
    movevalue = 0;
end
% 使滚动条的方块的位置与滚轮的滚动同步
set(handles.sliderV,'value',movevalue);
% 获取figure和panel的位置
figure1pos = get(handles.figure,'position');
panelpos = get(handles.panel,'position');
% 更新panel的位置
panelpos(2) = -(panelpos(4)-figure1pos(4))*movevalue;
set(handles.panel,'position',panelpos);
guidata(hObject,handles);
%%