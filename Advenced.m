function varargout = Advenced(varargin)
% ADVENCED M-file for Advenced.fig
%      ADVENCED, by itself, creates a new ADVENCED or raises the existing
%      singleton*.
%
%      H = ADVENCED returns the handle to a new ADVENCED or the handle to
%      the existing singleton*.
%
%      ADVENCED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADVENCED.M with the given input arguments.
%
%      ADVENCED('Property','Value',...) creates a new ADVENCED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Advenced_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Advenced_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Advenced

% Last Modified by GUIDE v2.5 05-Apr-2011 20:44:31

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Advenced_OpeningFcn, ...
                   'gui_OutputFcn',  @Advenced_OutputFcn, ...
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



% --- Executes just before Advenced is made visible.
function Advenced_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Advenced (see VARARGIN)
global N;
global startPol;
global endPol;
global startPolLow;
set(handles.N,'string',N);
set(handles.startPol,'string',startPol);
set(handles.endPol,'string',endPol);
set(handles.startPolLow,'string',startPolLow);

% Choose default command line output for Advenced
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Advenced wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = Advenced_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure



function startPol_Callback(hObject, eventdata, handles)
% hObject    handle to startPol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startPol as text
%        str2double(get(hObject,'String')) returns contents of startPol as a double


% --- Executes during object creation, after setting all properties.
function startPol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startPol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endPol_Callback(hObject, eventdata, handles)
% hObject    handle to endPol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endPol as text
%        str2double(get(hObject,'String')) returns contents of endPol as a double


% --- Executes during object creation, after setting all properties.
function endPol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endPol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function N_Callback(hObject, eventdata, handles)
% hObject    handle to N (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N as text
%        str2double(get(hObject,'String')) returns contents of N as a
%        double


% --- Executes during object creation, after setting all properties.
function N_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startPolLow_Callback(hObject, eventdata, handles)
% hObject    handle to startPolLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startPolLow as text
%        str2double(get(hObject,'String')) returns contents of startPolLow as a double


% --- Executes during object creation, after setting all properties.
function startPolLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startPolLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global N;
global startPol;
global endPol;
global startPolLow;
N=str2double(get(handles.N,'string'));
startPol=str2double(get(handles.startPol,'string'));
endPol=str2double(get(handles.endPol,'string'));
startPolLow=str2double(get(handles.startPolLow,'string'));


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global N;
global startPol;
global endPol;
global startPolLow;
N=30;
startPol=50;
endPol=50;
startPolLow=150;
set(handles.N,'string',N);
set(handles.startPol,'string',startPol);
set(handles.endPol,'string',endPol);
set(handles.startPolLow,'string',startPolLow);

