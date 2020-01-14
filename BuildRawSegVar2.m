function [stimTime,rawSeg,dTime] = BuildRawSegVar2(rawData, stimTime)
% The function is used to build rawSeg with variable length of intervals
% between stimuli.


nStim = length(stimTime);
dTime = diff(stimTime);

rawSeg = cell(nStim,1);

for i=1:nStim-1
         rawSeg{i}=rawData(stimTime(i):stimTime(i)+dTime(i)-1);
        rawSeg{i}(end) = 0; % last sample in a segment is padded with 0
end

% Last stim - set to be the same length as the previous segment
if (stimTime(nStim)+dTime(nStim-1)-1>length(rawData))
    nStim = nStim - 1;
    stimTime = stimTime(1:nStim);
    rawSeg  = rawSeg (1:nStim);
else
rawSeg{nStim}=rawData(stimTime(nStim):stimTime(nStim)+dTime(nStim-1)-1);
end