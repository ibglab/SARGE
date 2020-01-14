function varargout = ArtGUIPttDiff(varargin)
% ARTGUIPTTDIFF M-file for ArtGUIPttDiff.fig
%      ARTGUIPTTDIFF, by itself, creates a new ARTGUIPTTDIFF or raises the existing
%      singleton*.
%
%      H = ARTGUIPTTDIFF returns the handle to a new ARTGUIPTTDIFF or the handle to
%      the existing singleton*.
%
%      ARTGUIPTTDIFF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARTGUIPTTDIFF.M with the given input arguments.
%
%      ARTGUIPTTDIFF('Property','Value',...) creates a new ARTGUIPTTDIFF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ArtGUIPttDiff_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ArtGUIPttDiff_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ArtGUIPttDiff

% Last Modified by GUIDE v2.5 04-Jul-2010 10:03:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ArtGUIPttDiff_OpeningFcn, ...
                   'gui_OutputFcn',  @ArtGUIPttDiff_OutputFcn, ...
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


% --- Executes just before ArtGUIPttDiff is made visible.
function ArtGUIPttDiff_OpeningFcn(hObject, eventdata, handles, varargin)

handles.data.cleanSeg = varargin{1};
handles.data.saturLength = varargin{2};
set(gcf,'Toolbar','figure');
set(gcf,'Name',varargin{3});

handles.output = hObject;
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = ArtGUIPttDiff_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;



function editNumSamples_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function editNumSamples_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushPlot.
function pushPlot_Callback(hObject, eventdata, handles)

nSamples = str2num(get(handles.editNumSamples,'String'));

nSeg = length(handles.data.cleanSeg);
pttDiff = zeros(1,nSeg);
for i = 1 : nSeg
    currSeg = handles.data.cleanSeg{i};
    currSeg(1:handles.data.saturLength(i)) = [];
    currSeg = currSeg(1:nSamples);
    
    maxVal = max(currSeg);
    minVal = min(currSeg);
    
    pttDiff(i) = abs(maxVal-minVal);
end

hist(handles.axesPlot,pttDiff,20)

xlabel('\DeltaPTT');
ylabel('Count');

% Add mean and median
medPtt = median(pttDiff);
meanPtt = mean(pttDiff);

yl = ylim();
hLine = line([meanPtt meanPtt], [yl(1) yl(2)]);
set(hLine,'Color','k');
hLine = line([medPtt medPtt], [yl(1) yl(2)]);
set(hLine,'Color','k','LineStyle','--');


% --- Executes on button press in pushExit.
function pushExit_Callback(hObject, eventdata, handles)
close(handles.output);
