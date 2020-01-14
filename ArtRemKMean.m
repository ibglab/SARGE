function [cleanSeg, meanSeg, stimTime] = ArtRemKMean(rawData, stimTime, kMean, lZero, endThresh)

[stimTime,rawSeg] = BuildRawSeg(rawData, stimTime);

nStim = length(stimTime);
dTime = diff(stimTime);
mTime = median(dTime);

cleanSeg = cell(nStim,1);
meanSeg = cell(nStim,1);

h=waitbar(0,'Artifact removal...');

rs = cell2mat(rawSeg);

for i=1:nStim
    pre = min(i-1,kMean);
    post = min(nStim-i,kMean);
    meanSeg{i} = mean(rs(i-pre:i+post,:));
    l = find(rawSeg{i}>endThresh,1,'last');
    cleanSeg{i}(l+lZero+1:mTime) = double(rawSeg{i}(l+lZero+1:end)) - meanSeg{i}(l+lZero+1:end);
    cleanSeg{i}(1:l+lZero) = cleanSeg{i}(l+lZero+1);
    if (rem(i,100)==0)
        waitbar(i/nStim,h);
    end
end

close(h);