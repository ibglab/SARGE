% Personalized parameters

% zeroPhase: 1 - Use "filtfilt", 0 - Use "filter"
handles.zeroPhase = 1; 

handles.loadPathName = 'C:\ibg\bar-ilan\matlab\SARGE\data\'; % Insert your path name here
handles.savePathName = 'C:\'; % Insert your path name here
handles.saveStimTimePathName = 'C:\'; % Insert your path name here
handles.saveProjPathName = 'C:\';

set(handles.maxY, 'String', '3276');
set(handles.minY, 'String', '-3276');
set(handles.rawBox, 'Value', 1);
set(handles.stimDetPopup, 'Value', 1);
set(handles.stimRemPopup, 'Value', 2);
ArtStimRemPopup(handles, 2);

set(handles.editStimThreshBegin, 'String', '-20000');
set(handles.editStimThreshEnd, 'String', '5000');
set(handles.editStimMinLength, 'String', '2');% 2 ms
set(handles.editStimMaxLength, 'String', '2.5');% 2.5 ms

handles.StimSyncOffsetMicroS =  0;% 260/1000/1000; %stim-sync offset from stim time

% Default popup menus options
set(handles.stimDetPopup,'Value',3); % 1
set(handles.stimRemPopup,'Value',2); % 1
% set(handles.segWinSize, 'String', '320');

% Default stim sync variable name
handles.stimSyncName = 'CStimSync3';
handles.stimFullSyncName = [handles.stimSyncName '_Up'];


% Charlotte - replace
%set(handles.editStimThreshBegin, 'String', '-20000');
%set(handles.editStimThreshEnd, 'String', '-100');
%set(handles.editStimMinLength, 'String', '1');
%set(handles.editStimMaxLength, 'String', '2');
handles.stimSyncName = 't';
handles.stimFullSyncName = [handles.stimSyncName '_Up'];

