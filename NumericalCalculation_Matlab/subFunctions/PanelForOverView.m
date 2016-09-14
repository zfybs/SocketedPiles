function [fig,panel]=PanelForOverView
% ������ͼ������panel�͹�����
% panel�Ŀ�ȣ���ʼ����Ϊ��Ļ�Ŀ�ȼ�ȥ�������Ŀ��
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
% �������PreviousFigurePosition��Ϊ�������ô���fig�Ĵ�Сʱ�������ж���߶Ȼ��ȵ�������
% �Դ�������֤panel��top��λ�ò��䡣
handles.PreviousFigurePosition = get(fig,'position');
guidata(fig,handles)
%
set(fig,'ResizeFcn',{@figure1_ResizeFcn,guidata(fig)})
set(fig,'WindowScrollWheelFcn',{@figure1_WindowScrollWheelFcn,guidata(fig)})
set(sliderH,'callback',{@sliderH_scroll,guidata(fig)},'backgroundcolor','cyan')
set(sliderV,'callback',{@sliderV_scroll,guidata(fig)},'backgroundcolor','cyan')
%% ������Ӧ�س�ʼֵ
set(fig,'Color',[0.784,0.901,0.784])
set(sliderH,'value',0)
set(sliderV,'value',1)
% ����panel�Ĵ�С��λ�ã�����panel�Ķ���λ��figure�Ķ�����
scrsz = get(0,'ScreenSize');
rec_f=get(fig,'position');
panel_height=scrsz(4)*2;
set(panel,'bordertype','none',...
    'position',[0,rec_f(4)-panel_height,scrsz(3)-SCROLL_DEPTH_IN_PIXELS,panel_height],...
    'BackgroundColor',[0.784,0.901,0.784])


function figure1_ResizeFcn(hObject, eventdata, handles)
sliderH=handles.sliderH;
sliderV=handles.sliderV;
% �������PreviousFigurePosition��Ϊ�������ô���fig�Ĵ�Сʱ�������ж���߶Ȼ��ȵ�������
% �Դ�������֤panel��top��λ�ò��䡣
rec_f_previous=handles.PreviousFigurePosition;
rec_f=get(hObject,'position');
global SCROLL_DEPTH_IN_PIXELS;
set(sliderH,'position',[1,0,rec_f(3)-SCROLL_DEPTH_IN_PIXELS,SCROLL_DEPTH_IN_PIXELS])
set(sliderV,'position',[rec_f(3)-SCROLL_DEPTH_IN_PIXELS+2,SCROLL_DEPTH_IN_PIXELS+1,SCROLL_DEPTH_IN_PIXELS,rec_f(4)-SCROLL_DEPTH_IN_PIXELS])
%
scrsz = get(0,'ScreenSize');
rec_p=get(handles.panel,'position');
if rec_f(3)>rec_p(3)        % �Ƚ�panel��figure�Ŀ��
    set(handles.sliderH,'visible','off')
    set(handles.panel,'position',[0,rec_p(2),rec_f(3),rec_p(4)])
else
    set (handles.sliderH,'visible','on')
    if rec_f(3)>scrsz(3)-SCROLL_DEPTH_IN_PIXELS     %������ڵĿ�ȱ���Ļ�Ŀ�ȴ���panel�Ŀ������Ϊ���ڵĿ��
        set(handles.panel,'position',[0,rec_p(2),rec_f(3)-SCROLL_DEPTH_IN_PIXELS,rec_p(4)])
    else     %������ڵĿ�ȱ���Ļ�Ŀ��С����panel�Ŀ������Ϊ��Ļ�Ŀ��
        set(handles.panel,'position',[0,rec_p(2),scrsz(3)-SCROLL_DEPTH_IN_PIXELS,rec_p(4)])
    end
    
end
if rec_f(4)>rec_p(4)        % �Ƚ�panel��figure�ĸ߶�
    set (handles.sliderV,'visible','off')
    set(handles.panel,'position',[rec_p(1),0,rec_p(3),rec_p(4)]) 
else   %������ڵĸ߶�С��panel�ĸ߶�    
    set(handles.panel,'position',[rec_p(1),rec_p(2)+rec_f(4)-rec_f_previous(4),rec_p(3),rec_p(4)])  %����panel��top��λ�ò��䡣
    set (handles.sliderV,'visible','on')
end
handles.PreviousFigurePosition=rec_f;
guidata(hObject,handles)
set(hObject,'ResizeFcn',{@figure1_ResizeFcn,guidata(hObject)})

%%
function sliderH_scroll(hObject, eventdata,handles)
global SCROLL_DEPTH_IN_PIXELS;
%��ȡ�ù�������ֵ
panel=handles.panel;
pos = get(hObject,'value');
%
rec_p=get(panel,'position');
rec_f=get(gcf,'position');
%������panel��λ�ã����½ǵ�������ꡣ
set(panel,'position',[pos*(rec_f(3)-rec_p(3)-SCROLL_DEPTH_IN_PIXELS+3),rec_p(2),rec_p(3),rec_p(4)]);

%%
function sliderV_scroll(hObject, eventdata,handles)
global SCROLL_DEPTH_IN_PIXELS;
%��ȡ�ù�������ֵ
panel=handles.panel;
pos = get(hObject,'value');
%
rec_p=get(panel,'position');
rec_f=get(gcf,'position');
%������panel��λ�ã����½ǵ�������ꡣ
set(panel,'position',[0,pos*(rec_f(4)-rec_p(4)-SCROLL_DEPTH_IN_PIXELS)+SCROLL_DEPTH_IN_PIXELS,rec_p(3),rec_p(4)]);

%%
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% ��ȡĿǰ��������ֵ
slidervalue = get(handles.sliderV,'value');
% ��ȡ�����ֵ�ֵ����ǰ��Ϊ��������Ϊ��
scrollvalue = eventdata.VerticalScrollCount/10;
% ȷ��������
movevalue = slidervalue - scrollvalue;
% ���ƹ�����Χ����ֹ������嶼����ͼ�Σ�
if movevalue >1
    movevalue = 1;
elseif movevalue < 0
    movevalue = 0;
end
% ʹ�������ķ����λ������ֵĹ���ͬ��
set(handles.sliderV,'value',movevalue);
% ��ȡfigure��panel��λ��
figure1pos = get(handles.figure,'position');
panelpos = get(handles.panel,'position');
% ����panel��λ��
panelpos(2) = -(panelpos(4)-figure1pos(4))*movevalue;
set(handles.panel,'position',panelpos);
guidata(hObject,handles);
%%