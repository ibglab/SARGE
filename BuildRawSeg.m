function [stimTime,rawSeg] = BuildRawSeg(rawData, stimTime,maxSegLeng)

nStim = length(stimTime);
dTime = diff(stimTime);

if ~isempty(maxSegLeng)%18.3.14 michal
    mTime = min(median(dTime),maxSegLeng);
else
    mTime = median(dTime);
end

rawSeg = cell(nStim,1);

for i=1:nStim-1
    if (dTime(i)<mTime)
        rawSeg{i}(1:dTime(i))=rawData(stimTime(i):stimTime(i)+dTime(i)-1);
        rawSeg{i}(dTime(i)+1:mTime) = rawData(stimTime(i)+dTime(i)-1);
    else
        rawSeg{i}=rawData(stimTime(i):stimTime(i)+mTime-1);
    end
    rawSeg{i}(end) = 0;
end

% Last stim - set to be the same length as the previous segment
if (stimTime(nStim)+mTime-1>length(rawData))
    nStim = nStim - 1;
    stimTime = stimTime(1:nStim);
    rawSeg  = rawSeg (1:nStim);
else
    rawSeg{nStim}=rawData(stimTime(nStim):stimTime(nStim)+mTime-1);
end