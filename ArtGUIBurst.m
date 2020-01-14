function varargout = ArtGUIBurst(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ArtGUIBurst_OpeningFcn, ...
                   'gui_OutputFcn',  @ArtGUIBurst_OutputFcn, ...
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


% --- Executes just before ArtGUIBurst is made visible.
function ArtGUIBurst_OpeningFcn(hObject, eventdata, handles, varargin)

handles.data.rawData = varargin{1};
handles.data.stimTime = varargin{2};
handles.data.cleanData = varargin{3};

set(gcf,'Toolbar','figure');
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = ArtGUIBurst_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function fromBurst_Callback(hObject, eventdata, handles)

function fromBurst_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function toBurst_Callback(hObject, eventdata, handles)

function toBurst_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function plotBurst_Callback(hObject, eventdata, handles)
fromBurst = str2num(get(handles.fromBurst,'String'));
toBurst = str2num(get(handles.toBurst,'String'));

preValue = str2num(get(handles.preValue,'String'));
postValue = str2num(get(handles.postValue,'String'));

cleanData = get(handles.cleanData,'Value');

hold off;
for i=fromBurst:toBurst
    % Ugly ...
    t = handles.data.stimTime(i*40);
    if (cleanData)
        s = handles.data.cleanData(t+preValue:t+postValue);
    else
        s = handles.data.rawData(t+preValue:t+postValue);
    end
    plot(handles.burstAxes,[preValue:postValue]/40000,s);
    hold on;
end
axis([[preValue postValue]/40000 -32768 32768]);

% --- Executes on button press in exitBurst.
function exitBurst_Callback(hObject, eventdata, handles)
close(handles.output);

function preValue_Callback(hObject, eventdata, handles)

function preValue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function postValue_Callback(hObject, eventdata, handles)

function postValue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cleanData.
function cleanData_Callback(hObject, eventdata, handles)
% hObject    handle to cleanData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cleanData


