% (c) All rights are reserved for Dr. Izhar Bar-Gad

function varargout = SARGE(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SARGE_OpeningFcn, ...
    'gui_OutputFcn',  @SARGE_OutputFcn, ...
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

% --- Executes just before SARGE is made visible.
function SARGE_OpeningFcn(hObject, eventdata, handles, varargin)
ver = '1.6.1';
handles.output = hObject;
set(gcf,'Toolbar','figure');
set(handles.titleText,'String',['SARGE V' ver]);
set(gcf,'Resize','on');
% Call personal parameter file
ArtParm();
funVal = get(handles.stimRemPopup,'Value');
ArtStimRemPopup(handles,funVal);
global N;
global startPol;
global endPol;
global startPolLow;
N=30;
startPol=50;
endPol=50;
startPolLow=150;

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = SARGE_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --- Executes on slider movement.
function dataSlider_Callback(hObject, eventdata, handles)
ArtPlotData(handles);

% --- Executes during object creation, after setting all properties.
function dataSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function segSlider_Callback(hObject, eventdata, handles)
ArtPlotSeg(handles)

% --- Executes during object creation, after setting all properties.
function segSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in rawBox.
function rawBox_Callback(hObject, eventdata, handles)
ArtPlotData(handles);

% --- Executes on button press in cleanBox.
function cleanBox_Callback(hObject, eventdata, handles)
ArtPlotData(handles);

% --- Executes on button press in detectBox.
function detectBox_Callback(hObject, eventdata, handles)
ArtPlotData(handles);

% --- Executes on button press in detectButton.
function detectButton_Callback(hObject, eventdata, handles)

if (~isfield(handles,'data'))
    set(handles.msgText,'String','Error: No variable loaded.');
    return;
end
xFrom = str2double(get(handles.xFrom,'String'));
xTo = str2double(get(handles.xTo,'String'));
sampRate = str2double(get(handles.samplingRate,'String'));
xF = max(1, floor(xFrom*sampRate));
xT = min(length(handles.data.rawData), ceil(xTo*sampRate));

% Threshold for detecting stimulus
beginThresh = str2double(get(handles.editStimThreshBegin,'String'));
endThresh = str2double(get(handles.editStimThreshEnd,'String'));
minThresh = str2double(get(handles.editStimMinLength,'String'));
minThresh = minThresh/1000*sampRate;
maxThresh = str2double(get(handles.editStimMaxLength,'String'));
maxThresh = maxThresh/1000*sampRate;


% Offset for stimulus beginning
stimOffset = str2double(get(handles.editStimOffset,'String'));

funVal = get(handles.stimDetPopup,'Value');

switch (funVal)
    case 1
        if isfield(handles.data,'stimTimeSync')
            tmpStim = handles.data.stimTimeSync*sampRate;
            % Handle recording error of identical 2 first stim times
            if tmpStim(1) == tmpStim(2)
                tmpStim(1)=[];
            end
            % Calculate the stim time according to the first stim and the
            % mean of all the diff times between stims
            tmpStimMean = mean(diff(tmpStim));
            tmpStimMeanVec = repmat(tmpStimMean, 1, length(tmpStim)-1);
            stimTime = round([tmpStim(1) tmpStim(1)+cumsum(tmpStimMeanVec)]);
            inds = find(stimTime >= xF & stimTime <= xT);
            handles.data.stimTime = stimTime(inds);
        else
            tmpStim = nan;
            set(handles.msgText,'String','Error: Stim sync data not available.');
            return;
        end
    case 2
        handles.data.stimTime = stimDetect(handles.data.rawData, xF, xT, ...
            beginThresh, endThresh,minThresh, maxThresh);
    case 3
        if isfield(handles.data,'stimTimeSync')
            tmpStim = handles.data.stimTimeSync*sampRate;
            % Handle recording error of identical 2 first stim times
            if tmpStim(1) == tmpStim(2)
                tmpStim(1)=[];
            end
            inds = find(tmpStim >= xF & tmpStim <= xT);
            handles.data.stimTime = round(tmpStim(inds));
        else
            tmpStim = nan;
            set(handles.msgText,'String','Error: Stim sync data not available.');
            return;
        end
    case 4  %%%%% Michal - V1.5.4 - loading file with stim time var
        [fileNameS, pathNameS] = uigetfile({'*.mat';'*.*'},'MultiSelect','off');
        if (~isequal(fileNameS,0) && ~isequal(pathNameS,0))
            load([pathNameS,fileNameS]);
        else
            set(handles.msgText,'String','Error: Empty file or directory name.');
            return;
        end
        if (exist('stimTime','var') && (~isempty(stimTime)))
            handles.data.stimTime = round(stimTime*sampRate);
            set(handles.msgText,'String','Info: Successful stim time loadung.');
        else
            set(handles.msgText,'String','Error: Stim time data not available.');
        end
end

handles.data.stimTime = handles.data.stimTime - stimOffset;

popUpStr = get(handles.stimDetPopup,'String');
set(handles.stimDetPopup,'UserData', [popUpStr{funVal}]);
guidata(hObject,handles);

set(handles.DetectInd,'BackgroundColor',[0 1 0]);

set(handles.msgText,'String','Info: Stim time identification successful.');

guidata(hObject,handles);
ArtPlotData(handles);

set(handles.segSlider,'Min',1,'Max',length(handles.data.stimTime), ...
    'SliderStep', 1/length(handles.data.stimTime)*[1 1], 'value', 1);
set(handles.detectBox,'Enable','on');

ArtPlotSeg(handles);

%checking the session type(consistent orvariable length).
diffNum=0;
prev=0;
dTime=diff(handles.data.stimTime);
lSegs=[216 256 296 336 376];
for i=1:length(dTime)
    [temp tempInd] = min(abs(dTime(i)-lSegs));
    temp=lSegs(tempInd);
    if(i~=1)
        if(prev~=temp)
            diffNum=diffNum+1;
        end
    end
    prev=temp;
end
diffPrecent=(diffNum/length(dTime))*100;
if(diffPrecent>2)
    set(handles.sessionRes,'String','variable length');
    handles.data.sessionKind=1;
else
    set(handles.sessionRes,'String','fixed length');
    handles.data.sessionKind=2;
end
guidata(hObject,handles);

%-----------------------------------------------------------------------
function RemoveButton_Callback(hObject, eventdata, handles)
warning off MATLAB:polyfit:RepeatedPointsOrRescale;
global N;
global startPol;
global endPol;
global startPolLow;
funVal = get(handles.stimRemPopup,'Value');
sampRate = str2double(get(handles.samplingRate,'String'));
endThresh = str2double(get(handles.editStimThreshEnd,'String'));
maxLength= str2double(get(handles.editStimMaxLength,'String'));
maxLength = maxLength/1000*sampRate;
set(handles.msgText,'String','');

switch (funVal)
    
    case 1 % Global average
        lZero = str2double(get(handles.parm2val,'String'));
        tZero = str2double(get(handles.parm3val,'String'));
        maxSegLen = str2double(get(handles.parm4val,'String')); % IBG 25/3/14
        if ~isempty(maxSegLen)
            maxSegLen = maxSegLen/1000*sampRate;
        end
        [handles.data.cleanSeg, handles.data.meanSeg, handles.data.stimTime, handles.data.saturLength] = ...
            ArtRemMoveMean(handles.data.rawData, handles.data.stimTime, ...
            0, lZero, tZero, endThresh, maxLength, maxSegLen);
        
    case 2 % Dynamic average
        kMean = str2double(get(handles.parm1val,'String'));
        lZero = str2double(get(handles.parm2val,'String'));
        tZero = str2double(get(handles.parm3val,'String'));
        maxSegLen = str2double(get(handles.parm4val,'String')); % Michal 18/3/14
        if ~isempty(maxSegLen)
            maxSegLen = maxSegLen/1000*sampRate;
        end
        [handles.data.cleanSeg, handles.data.meanSeg, handles.data.stimTime, handles.data.saturLength] = ...
            ArtRemMoveMean(handles.data.rawData, handles.data.stimTime, ...
            kMean, lZero, tZero, endThresh, maxLength, maxSegLen);
        
    case 3 % Average for bursts
        lBurst = str2double(get(handles.parm1val,'String'));
        lZero = str2double(get(handles.parm2val,'String'));
        tZero = str2double(get(handles.parm3val,'String'));
        [handles.data.cleanSeg, handles.data.meanSeg, handles.data.stimTime, handles.data.saturLength] = ...
            ArtRemBurstMean(handles.data.rawData, handles.data.stimTime, ...
            lBurst, lZero, tZero, endThresh,maxLength);
        
    case 4 % Dynamic average for bursts
        kMean = str2double(get(handles.parm1val,'String'));
        lBurst = str2double(get(handles.parm2val,'String'));
        lZero = str2double(get(handles.parm3val,'String'));
        tZero = str2double(get(handles.parm4val,'String'));
        [handles.data.cleanSeg, handles.data.meanSeg, handles.data.stimTime, handles.data.saturLength] = ...
            ArtRemMoveBurst(handles.data.rawData, handles.data.stimTime, ...
            kMean, lBurst, lZero, tZero, endThresh,maxLength);
        
    case 5 % Dynamic average varying length
        kMean = str2double(get(handles.parm1val,'String'));
        lZero = str2double(get(handles.parm2val,'String'));
        tZero = str2double(get(handles.parm3val,'String'));
        [handles.data.cleanSeg, handles.data.meanSeg, handles.data.stimTime, handles.data.saturLength] = ...
            ArtRemMoveMeanVar(handles.data.rawData, handles.data.stimTime, ...
            kMean, lZero, tZero, endThresh,maxLength);
        
    case 6 % Local polynom
        polydeg = str2double(get(handles.parm1val,'String'));
        lZero = str2double(get(handles.parm2val,'String'));
        tZero = str2double(get(handles.parm3val,'String'));
        [handles.data.cleanSeg, handles.data.meanSeg, handles.data.stimTime, handles.data.saturLength] = ...
            ArtRemPolyFit(handles.data.rawData, handles.data.stimTime,lZero, tZero, endThresh,maxLength,sampRate,handles.data.sessionKind,polydeg,startPol,endPol,startPolLow,N);
        
    case 7 % Static Polynom
        polydeg = str2double(get(handles.parm1val,'String'));
        lZero = str2double(get(handles.parm2val,'String'));
        tZero = str2double(get(handles.parm3val,'String'));
        [handles.data.cleanSeg, handles.data.meanSeg, handles.data.stimTime, handles.data.saturLength] = ...
            ArtRemStaticPolyFit(handles.data.rawData, handles.data.stimTime,lZero, tZero, endThresh, polydeg,0,maxLength,sampRate);
        
    case 8 % Static polynom for variable segments lengths
        polydeg = str2double(get(handles.parm1val,'String'));
        lZero = str2double(get(handles.parm2val,'String'));
        tZero = str2double(get(handles.parm3val,'String'));
        maxInterval = str2double(get(handles.parm4val,'String'));
        maxInterval = maxInterval * sampRate / 1000; % convert to sampling points
        [handles.data.cleanSeg, handles.data.meanSeg, handles.data.stimTime, handles.data.saturLength] = ...
            ArtRemStaticPolyFitVar(handles.data.rawData, handles.data.stimTime,lZero, tZero, maxInterval, endThresh, polydeg,0,maxLength,sampRate);
        
        
    case 9 % Static polynom for variable artifacts lengths
        polydeg = str2double(get(handles.parm1val,'String'));
        lZero = str2double(get(handles.parm2val,'String'));
        tZero = str2double(get(handles.parm3val,'String'));
        maxFit = str2double(get(handles.parm4val,'String'));
        maxFit = maxFit * sampRate / 1000; % convert to sampling points
        [handles.data.cleanSeg, handles.data.meanSeg, handles.data.stimTime, handles.data.saturLength] = ...
            ArtRemStaticPolyFitLength(handles.data.rawData, handles.data.stimTime,lZero, tZero, maxFit, endThresh, polydeg, maxLength,sampRate,handles.msgText);
        
    case 10 % Simple threshold
        lZero = str2double(get(handles.parm2val,'String'));
        tZero = str2double(get(handles.parm3val,'String'));
        [handles.data.cleanSeg, handles.data.meanSeg, handles.data.stimTime, handles.data.saturLength] = ...
            ArtRemSimple(handles.data.rawData, handles.data.stimTime, ...
            lZero, tZero, endThresh, maxLength);
        
end

set(handles.SuppressInd,'BackgroundColor',[0 1 0]);
popUpStr = get(handles.stimRemPopup,'String');
set(handles.stimRemPopup,'UserData', [popUpStr{funVal}]);
guidata(hObject,handles);

ArtPlotSeg(handles);

function File_Callback(hObject, eventdata, handles)

function Load_Callback(hObject, eventdata, handles)

%tempMsg = [];

if isfield(handles,'loadPathName')
    initPathName = handles.loadPathName;
else
    initPathName = [];
end

[fileName, pathName] = uigetfile([initPathName '*.mat'],'Files containing raw data','MultiSelect','off');

if (~isequal(fileName,0) && ~isequal(pathName,0))
    fullName = [pathName fileName];
    handles.fullName = fullName;
    % IBG V1.1 - Fixed reading of variables with "_" and limit to vectors
    v = whos('-file',fullName);
    j=0;
    for i=1:length(v)
        if (xor(v(i).size(1)==1,v(i).size(2)==1))
            j = j + 1;
            varNames{j} = v(i).name;
        end
    end
    handles.varNames = varNames;
    s = ArtGuiVar(varNames);
    
    varStr='Vars:';
    % IBG V1.1 - Handle variable names, longer and shorter than the title "Vars:"
    dispMat = char(zeros(size(s,1)+1,max([size(s,2) length(varStr)]))+32);
    dispMat(1,1:length(varStr))=varStr;
    dispMat(2:end,1:size(s,2))=s;
    set(handles.fileVarsPopup, 'String', dispMat, 'Value', 1);
else
    set(handles.msgText,'String','Error: Empty file or directory name.');
    return;
end
%
% Quite barbaric...
if (isfield(handles,'data'))
    handles = rmfield(handles,'data');
end
cla(handles.rawSegAxes);
cla(handles.cleanSegAxes);
cla(handles.dataAxes);
% end
% % raw data
% handles.data.rawData = tmp.(varNames{varNum});
% handles.data.rawOrgData = tmp.(varNames{varNum});
%
% if (size(handles.data.rawData,1)>1)
%     handles.data.rawData=handles.data.rawData';
% end
%
% % Stim sync
% if (exist('tmpStim') == 1) & (~isempty(tmpStim))
%     handles.data.stimTimeSync = tmpStim;
% end
%
% Path
handles.loadPathName = pathName;
%
set(gcf,'Name',['SARGE ' fullName ' -- ' ]);
%
% lData = length(handles.data.rawData);
%
% lWindow = str2double(get(handles.windowLength,'String'));
% sampRate = str2double(get(handles.samplingRate,'String'));
% ss = lWindow*sampRate/lData;
% set(handles.dataSlider,'Min',1,'Max',lData-(lWindow*sampRate)+1, ...
%     'SliderStep',[ss ss],'Value',1);
set(handles.sessionRes,'String','');
set(handles.RawInd,'BackgroundColor',[1 0 0]);
set(handles.rawFilterInd,'BackgroundColor',[1 0 0]);
set(handles.DetectInd,'BackgroundColor',[1 0 0]);
set(handles.SuppressInd,'BackgroundColor',[1 0 0]);
set(handles.CombineInd,'BackgroundColor',[1 0 0]);
set(handles.FilterInd,'BackgroundColor',[1 0 0]);

set(handles.rawFiltBox,'Value',0,'Enable','off');
set(handles.detectBox,'Value',0,'Enable','off');
set(handles.cleanBox,'Value',0,'Enable','off');
%
% set(handles.xFrom,'String',num2str(0));
% set(handles.xTo,'String',num2str(ceil((lData+1)/sampRate)));
%
set(handles.rawBox,'Enable','off');
set(handles.rawFiltBox,'Enable','off');

% set(handles.segSlider,'Value',1);

guidata(hObject,handles);

%ArtPlotData(handles);

%set(handles.msgText,'String',['Info: Stream ' fullName '-' varNames{varNum} ' loaded' tempMsg]);

% --------------------------------------------------------------------
function SaveBin_Callback(hObject, eventdata, handles)

if ~(isfield(handles.data, 'cleanData'))
    msgbox ('No clean data was found.', 'Save to *.bin');
    return;
end


if isfield(handles,'savePathName')
    initPathName = handles.savePathName;
else
    initPathName = [];
end

[fileName, pathName] = uiputfile([initPathName '*.bin'],'Output binary file');

if (~isequal(fileName,0) && ~isequal(pathName,0))
    fid = fopen([pathName fileName],'wb');
    fwrite(fid,[int16(handles.data.cleanData)],'integer*2');
    fclose(fid);
    % savebin path
    handles.savePathName = pathName;
    guidata(hObject, handles);
end

function SaveMat_Callback(hObject, eventdata, handles)

if ~(isfield(handles.data, 'cleanData'))
    msgbox ('No clean data was found.', 'Save to *.mat');
    return;
end


if isfield(handles,'savePathName')
    initPathName = handles.savePathName;
else
    initPathName = [];
end

[fileName, pathName] = uiputfile([initPathName '*.mat'],'Output mat file');

if (~isequal(fileName,0) && ~isequal(pathName,0))
    cleanData = handles.data.cleanData;
    save([pathName fileName], 'cleanData');
    % save path
    handles.savePathName = pathName;
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function Exit_Callback(hObject, eventdata, handles)

function samplingRate_Callback(hObject, eventdata, handles)
lData = length(handles.data.rawData);
lWindow = str2double(get(handles.windowLength,'String'));
sampRate = str2double(get(handles.samplingRate,'String'));

ss = lWindow*sampRate/lData;
set(handles.dataSlider,'Min',1,'Max',lData-(lWindow*sampRate)+1, ...
    'SliderStep',[ss ss]);
ArtPlotData(handles);

% --- Executes during object creation, after setting all properties.
function samplingRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function windowLength_Callback(hObject, eventdata, handles)

lData = length(handles.data.rawData);
lWindow = str2double(get(handles.windowLength,'String'));
sampRate = str2double(get(handles.samplingRate,'String'));

ss = lWindow*sampRate/lData;
set(handles.dataSlider,'Min',1,'Max',lData-(lWindow*sampRate)+1, ...
    'SliderStep',[ss ss]);
ArtPlotData(handles);

% --- Executes during object creation, after setting all properties.
function windowLength_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function minY_Callback(hObject, eventdata, handles)
ArtPlotData(handles);

% --- Executes during object creation, after setting all properties.
function minY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxY_Callback(hObject, eventdata, handles)
ArtPlotData(handles);

% --- Executes during object creation, after setting all properties.
function maxY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editStimThreshBegin_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function editStimThreshBegin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editStimThreshEnd_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function editStimThreshEnd_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%---------------------------------------

function stimTime = stimDetect(trace, xF, xT, beginThresh, endThresh, minThresh, maxThresh)

stimTime = ArtStimFind(trace(xF:xT), beginThresh, endThresh, minThresh, maxThresh) - 1 + (xF - 1);

% --- Executes on selection change in stimRemPopup.
function stimRemPopup_Callback(hObject, eventdata, handles)

funVal = get(hObject,'Value');

ArtStimRemPopup(handles, funVal);


% --- Executes during object creation, after setting all properties.
function stimRemPopup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in stimDetPopup.
function stimDetPopup_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function stimDetPopup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function parm2val_Callback(hObject, eventdata, handles)

function parm2val_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit6_Callback(hObject, eventdata, handles)

function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function parm3val_Callback(hObject, eventdata, handles)

function parm3val_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function parm1val_Callback(hObject, eventdata, handles)

function parm1val_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in CombineButton.
function CombineButton_Callback(hObject, eventdata, handles)

set(handles.CombineInd,'BackgroundColor',[1 0 0]);
handles.data.cleanData = ArtCombine(handles.data.rawData, ...
    handles.data.stimTime, handles.data.cleanSeg);
set(handles.CombineInd,'BackgroundColor',[0 1 0]);
set(handles.FilterInd,'BackgroundColor',[1 0 0]);
set(handles.cleanBox,'Enable','on');

guidata(hObject,handles);
ArtPlotData(handles);

% --- Executes on button press in FilterButton.
function FilterButton_Callback(hObject, eventdata, handles)

set(handles.FilterInd,'BackgroundColor',[1 0 0]);

sampRate = str2double(get(handles.samplingRate,'String'));

highFilt = get(handles.PostHighpass, 'Value');
if (highFilt)
    highFiltVal = str2double(get(handles.PostHighVal,'String'));
else
    highFiltVal = 0;
end
lowFilt = get(handles.PostLowpass, 'Value');
if (lowFilt)
    lowFiltVal = str2double(get(handles.PostLowVal,'String'));
else
    lowFiltVal = 0;
end
notchFilt = get(handles.PostNotch, 'Value');

handles.data.cleanData = ArtFilt(handles.data.cleanData, sampRate, ...
    highFiltVal, lowFiltVal, notchFilt, handles.zeroPhase);

set(handles.cleanBox,'Enable','on');

set(handles.FilterInd,'BackgroundColor',[0 1 0]);
guidata(hObject,handles);
ArtPlotData(handles);

%------------------------------------------------------------------------
function filtThresh_Callback(hObject, eventdata, handles)

%------------------------------------------------------------------------
function filtThresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in stimTypeMenu.
function stimTypeMenu_Callback(hObject, eventdata, handles)

function stimTypeMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function Assess_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function MultiSeg_Callback(hObject, eventdata, handles)

maxSeg = str2double(get(handles.SegWinSize,'String'));
sampRate = str2double(get(handles.samplingRate,'String'));
ArtGUISeg(handles.data.cleanSeg, maxSeg, sampRate, get(gcf,'Name'));

% ------  xFrom  ---------------------------------------------------------
function xFrom_Callback(hObject, eventdata, handles)

function xFrom_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% -----  xTo   -----------------------------------------------------------
function xTo_Callback(hObject, eventdata, handles)

function xTo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function ArtRmvDistance_Callback(hObject, eventdata, handles)
if (isfield(handles,'data'))
    if isfield(handles.data,'rawData') && isfield(handles.data,'meanSeg')
        ArtCalcProbRmvDist(handles.data.rawData,handles.data.meanSeg, handles.data.stimTime,get(handles.stimRemPopup,'UserData'))
        return
    end
end
warndlg('Operate "Remove Artifact" in order to see the removal distribution.','Removal Distribution Error')

function SegWinSize_Callback(hObject, eventdata, handles)
ArtPlotSeg(handles);

% --- Executes during object creation, after setting all properties.
function SegWinSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function BurstResp_Callback(hObject, eventdata, handles)

if (isfield(handles.data,'rawData') && isfield(handles.data,'stimTime'))
    if (~isfield(handles.data,'cleanData'))
        handles.data.cleanData = [];
    end
    ArtGUIBurst(handles.data.rawData, handles.data.stimTime, handles.data.cleanData);
end

function editStimOffset_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function editStimOffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkBandpass.
function checkBandpass_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function ExportStimTime_Callback(hObject, eventdata, handles)
if ~(isfield(handles.data, 'stimTime'))
    msgbox ('No Stimulation Times were detected', 'Export Stim Time to *.mat');
    return;
end

if isfield(handles,'saveStimTimePathName')
    initPathName = handles.saveStimTimePathName;
else
    initPathName = [];
end

[fileName, pathName] = uiputfile([initPathName '*.mat'],'Export Stimulation Times');

if (~isequal(fileName,0) && ~isequal(pathName,0))
    [stimTime saturLength] = getST(handles);
    
    save ([pathName fileName],'stimTime', 'saturLength');
    
    % savebin path
    handles.saveStimTimePathName = pathName;
    guidata(hObject, handles);
end

function [stimTime saturLength ] = getST(handles)
sampRate = str2double(get(handles.samplingRate,'String'));
stimTime = handles.data.stimTime./sampRate;
saturLength = handles.data.saturLength./sampRate;

% --- Executes on button press in rawFiltBox.
function rawFiltBox_Callback(hObject, eventdata, handles)
ArtPlotData(handles);

function RawHighVal_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function RawHighVal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in RawHighpass.
function RawHighpass_Callback(hObject, eventdata, handles)

% --- Executes on button press in RawFilterButton.
function RawFilterButton_Callback(hObject, eventdata, handles)

set(handles.rawFilterInd,'BackgroundColor',[1 0 0]);

sampRate = str2double(get(handles.samplingRate,'String'));

highFilt = get(handles.RawHighpass, 'Value');
if (highFilt)
    highFiltVal = str2double(get(handles.RawHighVal,'String'));
else
    highFiltVal = 0;
end
lowFilt = get(handles.RawLowpass, 'Value');
if (lowFilt)
    lowFiltVal = str2double(get(handles.RawLowVal,'String'));
else
    lowFiltVal = 0;
end
notchFilt = get(handles.RawNotch, 'Value');

handles.data.rawData = ArtFilt(handles.data.rawData, sampRate, ...
    highFiltVal, lowFiltVal, notchFilthandles.zeroPhase);

set(handles.rawFiltBox,'Enable','on');
set(handles.rawFilterInd,'BackgroundColor',[0 1 0]);
guidata(hObject,handles);
ArtPlotData(handles);


function tbrawSegMin_Callback(hObject, eventdata, handles)
ArtPlotSeg(handles)


% --- Executes during object creation, after setting all properties.
function tbrawSegMin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tbrawSegMax_Callback(hObject, eventdata, handles)
ArtPlotSeg(handles)

% --- Executes during object creation, after setting all properties.
function tbrawSegMax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function parm4val_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function parm4val_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function parm5val_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function parm5val_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function parm6val_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function parm6val_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editStimMinLength_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function editStimMinLength_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in fileVarsPopup.
function fileVarsPopup_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function fileVarsPopup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in openVarBtn.
function openVarBtn_Callback(hObject, eventdata, handles)
tempMsg = [];

if (isfield(handles,'data'))
    handles = rmfield(handles,'data');
end

varNum = get(handles.fileVarsPopup,'Value');
varNum = varNum-1;

if (~varNum)
    set(handles.msgText,'String','Error: No variable chosen.');
    return;
else
    tmp = load(handles.fullName,handles.varNames{varNum});
    tmpBegin =0;
    if (~isempty(who('-file',handles.fullName, [handles.varNames{varNum} '_TimeBegin'])))
        tmpBegin = load(handles.fullName, [handles.varNames{varNum} '_TimeBegin']);
        if (length(fieldnames(tmpBegin))>0)
            tmpBegin = eval(['tmpBegin.' handles.varNames{varNum} '_TimeBegin']);
        end
    end
    
    % Look for stim sync variable
    stimSyncName = handles.stimSyncName;
    stimFullSyncName = handles.stimFullSyncName;
    for i = 1 : length(handles.varNames)
        if strcmp(handles.varNames{i}, stimFullSyncName)
            % stimSyncName was found
            tmpStim = load(handles.fullName, [stimSyncName '_Up']);
            tmpStimLen = eval(['length(tmpStim.' stimSyncName '_Up);']);
            if (tmpStimLen > 1) % Handle some files that does not include stim sync
                tmpStimKhz = load(handles.fullName, [stimSyncName '_KHz']);
                tmpStimBegin = load(handles.fullName, [stimSyncName '_TimeBegin']);
                tmpStim = eval(['tmpStim.' stimSyncName '_Up']);
                tmpStimKhz = eval(['tmpStimKhz.' stimSyncName '_KHz']);
                tmpStimBegin = eval(['tmpStimBegin.' stimSyncName '_TimeBegin']);
                tmpStim = tmpStim/tmpStimKhz/1000; % in seconds from beginning of recording
                tmpStim = tmpStim + handles.StimSyncOffsetMicroS; % Add  "StimSyncOffsetMicroS" microseconds of stim sync before stimulation
                % Synchronize with time begin of raw data
                diffTime = tmpStimBegin-tmpBegin;
                tmpStim = tmpStim + diffTime;
            else
                tmpStim = [];
                tempMsg = '. Stim sync data was not found in file.';
            end
            break;
        end
    end
    
end

% raw data
handles.data.rawData = double(tmp.(handles.varNames{varNum}));
handles.data.rawOrgData = double(tmp.(handles.varNames{varNum}));

if (size(handles.data.rawData,1)>1)
    handles.data.rawData=handles.data.rawData';
end

% Stim sync
if (exist('tmpStim') == 1) & (~isempty(tmpStim))
    handles.data.stimTimeSync = tmpStim;
end


set(gcf,'Name',['SARGE ' handles.fullName ' -- ' handles.varNames{varNum}]);

lData = length(handles.data.rawData);

lWindow = str2double(get(handles.windowLength,'String'));
sampRate = str2double(get(handles.samplingRate,'String'));
ss = lWindow*sampRate/lData;
set(handles.dataSlider,'Min',1,'Max',lData-(lWindow*sampRate)+1, ...
    'SliderStep',[ss ss],'Value',1);
%set(handles.segSlider,'Value',1);

set(handles.xFrom,'String',num2str(0));
set(handles.xTo,'String',num2str(ceil((lData+1)/sampRate)));

set(handles.RawInd,'BackgroundColor',[0 1 0]);
set(handles.rawFilterInd,'BackgroundColor',[1 0 0]);
set(handles.DetectInd,'BackgroundColor',[1 0 0]);
set(handles.SuppressInd,'BackgroundColor',[1 0 0]);
set(handles.CombineInd,'BackgroundColor',[1 0 0]);
set(handles.FilterInd,'BackgroundColor',[1 0 0]);

set(handles.rawBox,'Value',1,'Enable','on');
set(handles.rawFiltBox,'Value',0,'Enable','off');
set(handles.detectBox,'Value',0,'Enable','off');
set(handles.cleanBox,'Value',0,'Enable','off');

cla(handles.rawSegAxes);
cla(handles.cleanSegAxes);
cla(handles.dataAxes);

ArtPlotData(handles);
set(handles.msgText,'String',['Info: Stream ' handles.fullName '-' handles.varNames{varNum} ' loaded' tempMsg]);
guidata(hObject, handles);

function editStimMaxLength_Callback(hObject, eventdata, handles)


function editStimMaxLength_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit25_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)

button_state = get(hObject,'Value');
if button_state == get(hObject,'Max')
    set(hObject, 'String', 'zoomout');
    set(handles.maxY, 'String', '3000');
    set(handles.minY, 'String', '-3000');
    ArtPlotData(handles);
elseif button_state == get(hObject,'Min')
    set(handles.maxY, 'String', '30000');
    set(handles.minY, 'String', '-30000');
    set(hObject, 'String', 'zoomin');
    ArtPlotData(handles);
end

% --------------------------------------------------------------------
function expPar_Callback(hObject, eventdata, handles)
% hObject    handle to expPar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hand = saveParams(handles);

[fileName, pathName] = uiputfile([hand.savePathName '*.mat'],'Output project mat file');

if (~isequal(fileName,0) && ~isequal(pathName,0))
    save([pathName fileName],'hand');
end

function [hand] = saveParams(handles)
hand.loadPathName = handles.loadPathName;  % path name here
hand.savePathName = handles.savePathName; % Insert your path name here
hand.saveStimTimePathName = handles.saveStimTimePathName; % Insert your path name here
hand.saveProjPathName = handles.saveProjPathName;

hand.samplingRate = get(handles.samplingRate,'String');

hand.maxY=get(handles.maxY, 'String');
hand.minY=get(handles.minY, 'String');
hand.rawBox=get(handles.rawBox,'Value');
hand.stimDetPopup=get(handles.stimDetPopup, 'Value');
hand.stimRemPopup=get(handles.stimRemPopup, 'Value');


hand.editStimThreshBegin=get(handles.editStimThreshBegin, 'String');
hand.editStimThreshEnd=get(handles.editStimThreshEnd, 'String');
hand.editStimMinLength=get(handles.editStimMinLength, 'String');% 2 ms
hand.editStimMaxLength=get(handles.editStimMaxLength, 'String');% 2.5 ms

hand.StimSyncOffsetMicroS =  handles.StimSyncOffsetMicroS;% 260/1000/1000; %stim-sync offset from stim time;

hand.maxY = get(handles.maxY, 'String');
hand.minY = get(handles.minY, 'String');
hand.rawBox=get(handles.rawBox,'Value');
hand.stimDetPopup=get(handles.stimDetPopup, 'Value');
hand.stimRemPopup=get(handles.stimRemPopup, 'Value');
%
%
hand.editStimThreshBegin=get(handles.editStimThreshBegin, 'String');
hand.editStimThreshEnd=get(handles.editStimThreshEnd, 'String');
hand.editStimMinLength=get(handles.editStimMinLength, 'String');% 2 ms
hand.editStimMaxLength=get(handles.editStimMaxLength, 'String');% 2.5 ms
%
% % Default popup menus options
hand.stimDetPopup=get(handles.stimDetPopup,'Value'); % 1
hand.stimRemPopup=get(handles.stimRemPopup,'Value'); % 1

hand.parm1val = get(handles.parm1val,'String');
hand.parm2val = get(handles.parm2val,'String');
hand.parm3val = get(handles.parm3val,'String');

hand.stimTime = handles.data.stimTime./str2double(hand.samplingRate);
hand.saturLength = handles.data.saturLength./str2double(hand.samplingRate);

% --------------------------------------------------------------------
function loadPar_Callback(hObject, eventdata, handles)
% hObject    handle to loadPar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fileName, pathName] = uigetfile([handles.savePathName '*.mat'],'Load project mat file');

if (~isequal(fileName,0) && ~isequal(pathName,0))
    s = load([pathName fileName],'hand');
else
    msgdlg('ERROR')
end
hand = s.hand;
handles.loadPathName = hand.loadPathName;  % path name here
handles.savePathName = hand.savePathName; % Insert your path name here
handles.saveStimTimePathName = hand.saveStimTimePathName; % Insert your path name here
handles.saveProjPathName = hand.saveProjPathName; % Insert your path name here


set(handles.maxY, 'String', hand.maxY);
set(handles.minY,'String',hand.minY);
set(handles.rawBox,'Value',hand.rawBox);
set(handles.stimDetPopup, 'Value',hand.stimDetPopup);
set(handles.stimRemPopup, 'Value',hand.stimRemPopup);


set(handles.editStimThreshBegin, 'String',hand.editStimThreshBegin);
set(handles.editStimThreshEnd, 'String',hand.editStimThreshEnd);
set(handles.editStimMinLength, 'String',hand.editStimMinLength);% 2 ms
set(handles.editStimMaxLength, 'String',hand.editStimMaxLength);% 2.5 ms

handles.StimSyncOffsetMicroS =  hand.StimSyncOffsetMicroS;% 260/1000/1000; %stim-sync offset from stim time;% 260/1000/1000; %stim-sync offset from stim time

set(handles.maxY , 'String',hand.maxY);
set(handles.minY , 'String',hand.minY);
set(handles.rawBox,'Value',hand.rawBox);
set(handles.stimDetPopup,'Value',hand.stimDetPopup);
set(handles.stimRemPopup,'Value',hand.stimRemPopup);
%
%
set(handles.editStimThreshBegin, 'String',hand.editStimThreshBegin);
set(handles.editStimThreshEnd, 'String',hand.editStimThreshEnd);
set(handles.editStimMinLength, 'String',hand.editStimMinLength);% 2 ms
set(handles.editStimMaxLength, 'String',hand.editStimMaxLength);% 2.5 ms
%

set(handles.parm1val,'String',hand.parm1val);
set(handles.parm2val,'String',hand.parm2val);
set(handles.parm3val,'String',hand.parm3val);

% % Default popup menus options
set(handles.stimDetPopup,'Value',hand.stimDetPopup); % 1
set(handles.stimRemPopup,'Value',hand.stimRemPopup); % 1

set(handles.samplingRate,'String', hand.samplingRate);
handles.data.stimTime = hand.stimTime.*str2double(hand.samplingRate);
handles.data.saturLength = hand.saturLength.*str2double(hand.samplingRate);

ArtStimRemPopup(handles, hand.stimRemPopup);
guidata(hObject, handles);

% --------------------------------------------------------------------
function SaveAll_Callback(hObject, eventdata, handles)

hand = saveParams(handles);

[fileName, pathName] = uiputfile([handles.saveProjPathName '*.mat'],'Output project mat file');

if (~isequal(fileName,0) && ~isequal(pathName,0))
    save([pathName fileName],'hand');
end

% savebin path
handles.saveProjPathName = pathName;
guidata(hObject, handles);

SaveBin_Callback(hObject, eventdata, handles);

ExportFNP_Callback(hObject, eventdata, handles);


% --------------------------------------------------------------------
function ExportFNP_Callback(hObject, eventdata, handles)

if ~(isfield(handles.data, 'saturLength'))
    msgbox ('No FNP data was found.', 'Export FNP');
    return;
end

if isfield(handles,'savePathName')
    initPathName = handles.savePathName;
else
    initPathName = [];
end

[fileName, pathName] = uiputfile([initPathName '*.mat'],'Export FNP');

if (~isequal(fileName,0) && ~isequal(pathName,0))
    dataFNP.samplingRate = get(handles.samplingRate,'String');
    % The NpAndLz includes the identification of the non-usable period (NP)
    % and the
    % LZ. It doesn't include the TZ.
    dataFNP.NpAndLz = handles.data.saturLength./str2double(dataFNP.samplingRate);
    dataFNP.LZ = str2num(get(handles.parm2val,'String'));
    dataFNP.TZ = str2num(get(handles.parm3val,'String'));
    dataFNP.TotalFNP = sum(dataFNP.NpAndLz) + dataFNP.TZ*length(dataFNP.NpAndLz); % Correction for the mean firing rate
    
    save([pathName fileName], 'dataFNP');
    % save path
    handles.savePathName = pathName;
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function FnpDist_Callback(hObject, eventdata, handles)

samplingRate = str2num(get(handles.samplingRate,'String'));
NpAndLz = handles.data.saturLength;
Tz = str2num(get(handles.parm3val,'String'));

totalFNP = (NpAndLz+Tz)./samplingRate*1000;

hFig = figure;
set(hFig,'Name','FNP','NumberTitle','off');
hist(totalFNP,20);

xlabel('FNP (ms)');
ylabel('Count');

% Add mean and median
medFnp = median(totalFNP);
meanFnp = mean(totalFNP);

yl = ylim();
hLine = line([meanFnp meanFnp], [yl(1) yl(2)]);
set(hLine,'Color','k');
hLine = line([medFnp medFnp], [yl(1) yl(2)]);
set(hLine,'Color','k','LineStyle','--');


% --------------------------------------------------------------------
function RmsDist_Callback(hObject, eventdata, handles)

% Divide the raw data into segments
[stimTime,rawSeg] = BuildRawSeg(handles.data.rawData, handles.data.stimTime);

% Get the mean segments
meanSeg = handles.data.meanSeg;

% Get the FNP of all segments
NpAndLz = handles.data.saturLength;
Tz = str2num(get(handles.parm3val,'String'));

% Calculate RMS
nSeg = length(rawSeg);
RMS = zeros(1, nSeg);
for i = 1 : nSeg
    currRaw = rawSeg{i};
    currMean = meanSeg{i};
    % Remove the FNP
    currRaw(1:NpAndLz) = [];
    currMean(1:NpAndLz) = [];
    if Tz>0
        currRaw(end-Tz+1:end) = [];
        currMean(end-Tz+1:end) = [];
    end
    RMS(i) = sqrt((sum(currRaw-currMean).^2) / length(currRaw));
end % for i

hFig = figure;
set(hFig,'Name','RMS','NumberTitle','off');
hist(RMS,20);

xlabel('RMS');
ylabel('Count');

% Add mean and median
medRms = median(RMS);
meanRms = mean(RMS);

yl = ylim();
hLine = line([meanRms meanRms], [yl(1) yl(2)]);
set(hLine,'Color','k');
hLine = line([medRms medRms], [yl(1) yl(2)]);
set(hLine,'Color','k','LineStyle','--');

% --------------------------------------------------------------------
function PttDiffDist_Callback(hObject, eventdata, handles)

ArtGUIPttDiff(handles.data.cleanSeg, handles.data.saturLength, get(gcf,'Name'));

% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function generalHelp_Callback(hObject, eventdata, handles)
open('Erez_Bar-Gad_JNSM_2010.pdf');

% --- Executes on button press in changeType.
function changeType_Callback(hObject, eventdata, handles)

if( handles.data.sessionKind==1)
    set(handles.sessionRes,'String','fixed length');
    handles.data.sessionKind=2;
else
    set(handles.sessionRes,'String','variable length');
    handles.data.sessionKind=1;
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function practicalHelp_Callback(hObject, eventdata, handles)
open('SARGE_PracticalGuidelines.pdf');

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
Advenced();

% --- Executes on button press in NotchFilterButton.
function NotchFilterButton_Callback(hObject, eventdata, handles)

function RawLowVal_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function RawLowVal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in RawLowpass.
function RawLowpass_Callback(hObject, eventdata, handles)

% --- Executes on button press in RawNotch.
function RawNotch_Callback(hObject, eventdata, handles)


% --- Executes on button press in PostHighpass.
function PostHighpass_Callback(hObject, eventdata, handles)

% --- Executes on button press in PostLowpass.
function PostLowpass_Callback(hObject, eventdata, handles)

% --- Executes on button press in PostNotch.
function PostNotch_Callback(hObject, eventdata, handles)

function PostHighVal_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function PostHighVal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PostLowVal_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function PostLowVal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
