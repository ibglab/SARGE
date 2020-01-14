function ArtPlotData(handles)

sValue = round(get(handles.dataSlider,'Value'));

lWindow = str2num(get(handles.windowLength,'String'));
sampRate = str2num(get(handles.samplingRate,'String'));
minY = str2num(get(handles.minY,'String'));
maxY = str2num(get(handles.maxY,'String'));


hold(handles.dataAxes,'off');
plotEnd=sValue+lWindow*sampRate;
if(plotEnd>length(handles.data.rawOrgData))
    plotEnd=length(handles.data.rawOrgData);
end
if (get(handles.rawBox,'Value'))
    plot(handles.dataAxes,(sValue:plotEnd)/sampRate, ...
        handles.data.rawOrgData(sValue:plotEnd));
    axis(handles.dataAxes, [sValue/sampRate (plotEnd)/sampRate ...
                        minY maxY]);
else
    cla(handles.dataAxes);
    axis(handles.dataAxes, [sValue/sampRate (plotEnd)/sampRate ...
                        minY maxY]);
end
hold(handles.dataAxes,'on');

if (get(handles.rawFiltBox,'Value'))
    plot(handles.dataAxes,(sValue:plotEnd)/sampRate, ...
        handles.data.rawData(sValue:plotEnd),'m');
    axis(handles.dataAxes, [sValue/sampRate (plotEnd)/sampRate ...
                        minY maxY]);
else
    axis(handles.dataAxes, [sValue/sampRate (plotEnd)/sampRate ...
                        minY maxY]);
end
hold(handles.dataAxes,'on');

if (get(handles.detectBox,'Value') && isfield(handles.data,'stimTime'))
    f = find(handles.data.stimTime>sValue & ...
             handles.data.stimTime<(sValue+lWindow*sampRate+1));
    for i=1:length(f)
        plot(handles.dataAxes,[1 1]*handles.data.stimTime(f(i))/sampRate, ...
            [minY maxY], 'r:');
    end 
end

if (get(handles.cleanBox,'Value') && isfield(handles.data,'cleanData'))
   plot(handles.dataAxes,(sValue:sValue+lWindow*sampRate-1)/sampRate, ...
        handles.data.cleanData(sValue:sValue+lWindow*sampRate-1),'g');
end

drawnow;