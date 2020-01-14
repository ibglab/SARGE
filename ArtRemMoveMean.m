function [cleanSeg, meanSeg, stimTime, deadLength] = ...
    ArtRemMoveMean(rawData, stimTime, kMean, lZero, tZero, endThresh, artMaxLength,maxSegLeng)

% kMean - Value 0 is global removal of average

dTime = diff(stimTime);

if ~isempty(maxSegLeng)%18.3.14 michal
    mTime = min(median(dTime),maxSegLeng);
else
    mTime = median(dTime);
end

if (artMaxLength==0)
    artMaxLength = mTime;
end

[stimTime,rawSeg] = BuildRawSeg(rawData, stimTime,maxSegLeng);

nStim = length(stimTime);
deadLength = zeros(1,length(stimTime));

cleanSeg = cell(nStim,1);

if (kMean==0)
    meanSeg = mean(cell2mat(rawSeg));
else
    meanSeg = cell(nStim,1);
end

h=waitbar(0,'Artifact removal...');

rs = cell2mat(rawSeg);

for i=1:nStim
    if (endThresh>0)
        l = find(rawSeg{i}(1:artMaxLength)>endThresh,1,'last');
    else
        l = find(rawSeg{i}(1:artMaxLength)<endThresh,1,'last');
    end
    if (length(l)>0)
        if (kMean == 0)
            cleanSeg{i}(l+lZero+1:mTime) = double(rawSeg{i}(l+lZero+1:end)) - meanSeg(l+lZero+1:end);
        else
            pre = min(i-1,kMean);
            post = min(nStim-i,kMean);
            meanSeg{i} = mean(rs(i-pre:i+post,:));
            cleanSeg{i}(l+lZero+1:mTime) = double(rawSeg{i}(l+lZero+1:end)) - meanSeg{i}(l+lZero+1:end);
        end
        cleanSeg{i}(1:l+lZero) = cleanSeg{i}(l+lZero+1);
        % Trailing zeros - pad the last samples with the previuos sample value,
        % according to the number of trailing zeros
        cleanSeg{i}(end-tZero+1:end) = cleanSeg{i}(end-tZero);
       deadLength(i) = l+lZero;
    else
        cleanSeg{i} = rawSeg{i};
        if (kMean==0)
            meanSeg = zeros(1,length(rawSeg{i}));
        else
            meanSeg{i} = zeros(1,length(rawSeg{i}));
        end
        deadLengt{i} = length(rawSeg{i});
        disp(['Error: Segment ' mat2str(i) ' no end found !']);
    end
    if (rem(i,10)==0)
        waitbar(i/nStim,h);
    end
end

close(h);