function [stimTime,rawSeg,lSegs,dTimeRevised] = BuildRawSegVar(rawData, stimTime)
% The function is used to build rawSeg specifically for the protocol HF-V
% (HF frequency with variable intervals - Yaara)

nStim = length(stimTime);
dTime = diff(stimTime);
% Barbaric
lSegs = [216 256 296 336 376];
dTimeRevised = zeros(1,length(dTime)+1);
for i = 1 : length(dTime)
    [temp tempInd] = min(abs(dTime(i)-lSegs));
    dTimeRevised(i) = lSegs(tempInd);
end
dTimeRevised(nStim) = median(dTimeRevised(1:nStim-1));

rawSeg = cell(nStim,1);

for i=1:nStim-1
    if (dTime(i)<dTimeRevised(i))
        rawSeg{i}(1:dTime(i))=rawData(stimTime(i):stimTime(i)+dTime(i)-1);
        rawSeg{i}(dTime(i)+1:dTimeRevised(i)) = rawData(stimTime(i)+dTime(i)-1);
    else
        rawSeg{i}=rawData(stimTime(i):stimTime(i)+dTimeRevised(i)-1);
    end
    rawSeg{i}(end) = 0;
end

% Last stim
if (stimTime(nStim)+dTimeRevised(nStim)-1>length(rawData))
    nStim = nStim - 1;
    stimTime = stimTime(1:nStim);
    rawSeg  = rawSeg (1:nStim);
    dTimeRevised = dTimeRevised(1:nStim);
else
     rawSeg{nStim}=rawData(stimTime(nStim):stimTime(nStim)+dTimeRevised(nStim)-1);
end
    