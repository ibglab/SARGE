function [cleanSeg, meanSeg, stimTime, deadLength] = ArtRemBurstMean(rawData, stimTime, lBurst,lZero, tZero, endThresh,artMaxLength)

[stimTime,rawSeg] = BuildRawSeg(rawData, stimTime);

nStim = length(stimTime);
dTime = diff(stimTime);
mTime = median(dTime);
deadLength = zeros(1,length(stimTime));

cleanSeg = cell(nStim,1);
meanSeg = cell(nStim,1);
burstMean = cell(lBurst,1);

rs = cell2mat(rawSeg);
%burstMean-matrix contain the mean values of the segments which have the same index in all bursts
for i=1:lBurst
    burstMean{i} = mean(rs(i:lBurst:end,:));
end

for i=1:nStim
    r = rem(i,lBurst);
    if (r==0)
        r = lBurst;
    end
   
    meanSeg{i} = burstMean{r};
    if (endThresh>0)
        l = find(rawSeg{i}(1:artMaxLength)<endThresh,1,'last');
    else
         l = find(rawSeg{i}(1:artMaxLength)>endThresh,1,'last');
    end
    minLZero = min(lZero, (mTime-l-lZero>1)*1000);
    cleanSeg{i}(l+minLZero+1:mTime) = double(rawSeg{i}(l+minLZero+1:end)) - ...
    meanSeg{i}(l+minLZero+1:end);
    cleanSeg{i}(1:l+minLZero) = cleanSeg{i}(l+minLZero+1);
    % Trailing zeros - pad the last samples with the previuos sample value,
    % according to the number of trailing zeros
    cleanSeg{i}(end-tZero+1:end) = cleanSeg{i}(end-tZero);
    deadLength(i) = l+lZero;
end

