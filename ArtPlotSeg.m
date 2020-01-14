function ArtPlotSeg(handles)

if ~(isfield(handles.data, 'stimTime'))
    return;
end

maxSeg = str2double(get(handles.SegWinSize,'String'));

if (maxSeg == 0)
    maxSeg = 800;
    set(handles.SegWinSize,'String','800');
end

nSeg = round(get(handles.segSlider,'Value'));

if (length(handles.data.stimTime)<nSeg)
%     nSeg = 1;
%     set(handles.segSlider,'Value',1);
    return;
end

t=handles.data.stimTime(nSeg);
YLimMin = str2num(get(handles.tbrawSegMin,'String'));
YLimMax = str2num(get(handles.tbrawSegMax,'String'));

if (isfield(handles.data,'cleanSeg'))
    lSeg = min(length(handles.data.cleanSeg{nSeg}),maxSeg);
else % Only raw data: lSeg is determined according to the next stimTime.
    % For the last stim - it is determined according to maxSeg
    if (nSeg<length(handles.data.stimTime))
        lSeg = min(handles.data.stimTime(nSeg+1)-t,maxSeg);    
    else
        lSeg = maxSeg;
    end
end

sampRate = str2num(get(handles.samplingRate,'String'));
tVec = (0:lSeg-1)/sampRate*1000;

plot(handles.rawSegAxes, tVec, handles.data.rawData(t:t+lSeg-1));

set(handles.segText,'String',num2str(nSeg));
set(handles.segTime,'String',num2str(handles.data.stimTime(nSeg)/sampRate));

if (isfield(handles.data,'cleanSeg'))
    hold(handles.cleanSegAxes,'off');
    plot(handles.cleanSegAxes, tVec, handles.data.cleanSeg{nSeg}(1:lSeg));
    if (isfield(handles.data,'meanSeg'))
        hold(handles.rawSegAxes,'on');
        if (size(handles.data.meanSeg,1)==1)
            plot(handles.rawSegAxes, tVec, handles.data.meanSeg(1:lSeg),'r');
        else
            plot(handles.rawSegAxes, tVec, handles.data.meanSeg{nSeg}(1:lSeg),'r');
        end
        hold(handles.rawSegAxes,'off');
    end
end

% Set x axis
currAxis = axis(handles.rawSegAxes);
axis(handles.rawSegAxes, [0 lSeg/sampRate*1000 YLimMin YLimMax]);

currAxis = axis(handles.cleanSegAxes);
axis(handles.cleanSegAxes, [0 lSeg/sampRate*1000 currAxis(3) currAxis(4)]);
