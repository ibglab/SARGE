function varargout = ArtGUISeg(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ArtGUISeg_OpeningFcn, ...
                   'gui_OutputFcn',  @ArtGUISeg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before ArtGUISeg is made visible.
function ArtGUISeg_OpeningFcn(hObject, eventdata, handles, varargin)

handles.data.cleanSeg = varargin{1};
set(handles.segWinSize,'String',num2str(varargin{2}));
handles.sampRate = varargin{3};
set(gcf,'Toolbar','figure');
set(gcf,'Name',varargin{4});

% Call personal parameter file
ArtSegParm();

handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = ArtGUISeg_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function fromSeg_Callback(hObject, eventdata, handles)

function fromSeg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function toSeg_Callback(hObject, eventdata, handles)

function toSeg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in plotButton.
function plotButton_Callback(hObject, eventdata, handles)

fromSeg = str2num(get(handles.fromSeg,'String'));
toSeg = str2num(get(handles.toSeg,'String'));
toSeg = min(toSeg,length(handles.data.cleanSeg));
thr = str2num(get(handles.tbSpikeThr,'String'));

% Look for the maximal segment length (supports variable segments lengths)
lSegTemp = 0;
for i = fromSeg:toSeg
    lSegCurr = length(handles.data.cleanSeg{i});
    lSegTemp = max(lSegTemp, lSegCurr);
end

maxSeg = str2num(get(handles.segWinSize,'String'));
lSeg = min(lSegTemp,maxSeg);    
tVec = (0:lSeg-1)/handles.sampRate*1000;

cla(handles.segAxes)

if (lSeg>0)
    set(handles.segAxes,'xlim',[0 lSeg/handles.sampRate*1000]);
end
%plot(handles.segAxes, tVec,0)
hold on
for i=fromSeg:toSeg
    s = handles.data.cleanSeg{i};
    plotLen = min(length(s),lSeg);
    bS = 50; eS = min(200,length(s));
    s = s - mean(s(bS:eS));
%     plot(handles.segAxes, tVec, s(1:lSeg));
    plot(handles.segAxes, tVec(1:plotLen), s(1:plotLen));
    if (get(handles.chPlotSpikes, 'Value')==1)
        sloc = (s<thr);
        sloclowzero = [false (diff(s)<0)];
        slochizero = [(diff(s)>0) false];
        sploc = find(sloc & slochizero & sloclowzero );
        plot(handles.segAxes, tVec(1:plotLen), s(1:plotLen));
        plot(tVec(sploc), s(sploc),'r.')
    end
end
hold off;
title(get(handles.ArtGUISeg,'Name'));

% --- Executes on button press in exitButton.
function exitButton_Callback(hObject, eventdata, handles)
close(handles.output);

function segWinSize_Callback(hObject, eventdata, handles)

plotButton_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function segWinSize_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tbNumSegments_Callback(hObject, eventdata, handles)

function tbNumSegments_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbPlotNext.
function pbPlotNext_Callback(hObject, eventdata, handles)

fromSeg = str2num(get(handles.fromSeg,'String'));
step = str2num(get(handles.tbNumSegments,'String'));
toSeg = str2num(get(handles.toSeg,'String'));

set(handles.fromSeg,'String', num2str(fromSeg+step))
set(handles.toSeg,'String', num2str(fromSeg+2*step-1))
guidata(hObject, handles);
plotButton_Callback(hObject, eventdata, handles)

% --- Executes on button press in pbPlotPrev.
function pbPlotPrev_Callback(hObject, eventdata, handles)
% hObject    handle to pbPlotPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fromSeg = str2num(get(handles.fromSeg,'String'));
step = str2num(get(handles.tbNumSegments,'String'));
toSeg = str2num(get(handles.toSeg,'String'));

if fromSeg - step < 1
    fromSeg = 1;
    toSeg = step ;
else
    toSeg = fromSeg-1;
    fromSeg = fromSeg-step ;
    
end


set(handles.fromSeg,'String', num2str(fromSeg))
set(handles.toSeg,'String', num2str(toSeg))
guidata(hObject, handles);
plotButton_Callback(hObject, eventdata, handles)

function tbSpikeThr_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function tbSpikeThr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbHist.
function pbHist_Callback(hObject, eventdata, handles)

    fromSeg = 1; % str2num(get(handles.fromSeg,'String'));
    toSeg = length(handles.data.cleanSeg);
    thr = str2num(get(handles.tbSpikeThr,'String'));

    % Look for the maximal segment length (supports variable segments lengths)
    lSegTemp = 0;
    for i = fromSeg:toSeg
        lSegCurr = length(handles.data.cleanSeg{i});
        lSegTemp = max(lSegTemp, lSegCurr);
    end

    maxSeg = str2num(get(handles.segWinSize,'String'));
    lSeg = min(lSegTemp,maxSeg);    
    tVec = (0:lSeg-1)/handles.sampRate*1000;

%         for i=1:length(handles.data.cleanSeg)
    sploc = [];
    for i = fromSeg:toSeg
        s = handles.data.cleanSeg{i};
        plotLen = min(length(s),lSeg);
        bS = 50; eS = min(200,length(s));
        s = s - mean(s(bS:eS));
    %     plot(handles.segAxes, tVec, s(1:lSeg));
        shortS = s(1:plotLen);
        sloc = (shortS<thr);
        sloclowzero = [false (diff(shortS)<0)];
        slochizero = [(diff(shortS)>0) false];
        sploc = [sploc tVec(find(sloc & slochizero & sloclowzero ))] ;
%         plot(handles.segAxes, tVec(1:plotLen), s(1:plotLen));
%         plot(tVec(sploc), s(sploc),'r.')
    end 
    figure
%    sSploc = yySmooth(sploc,'gauss', 3);
    nElem = histc(sploc,tVec(1:plotLen));
%     sSploc = yySmoothData(nElem,'gauss', 31);
    sSploc = nElem;

    smoothEdit = str2num(get(handles.smoothEdit,'String'));
    
    if (smoothEdit>0)
        sSploc=yySmoothData(sSploc,'gauss',smoothEdit*2+1);
    end
    
    bar(tVec(1:plotLen),sSploc);
    title(get(handles.ArtGUISeg,'Name'));

% --- Executes on button press in chPlotSpikes.
function chPlotSpikes_Callback(hObject, eventdata, handles)

function smoothEdit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function smoothEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

