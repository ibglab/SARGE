function [cleanSeg, meanSeg, stimTime, deadLength] = ArtRemMoveBurst(rawData, stimTime, ...
                                                    kMean, lBurst, lZero, tZero, endThresh,artMaxLength)

[stimTime,rawSeg] = BuildRawSeg(rawData, stimTime);

nStim = length(stimTime);
dTime = diff(stimTime);
mTime = median(dTime);
deadLength = zeros(1,length(stimTime));

cleanSeg = cell(nStim,1);
meanSeg = cell(nStim,1);

h=waitbar(0,'Artifact removal...');

rs = cell2mat(rawSeg);

for i=1:nStim/lBurst
    pre = min(i-1,kMean);
    post = min(nStim/lBurst-i,kMean);
    for j=1:lBurst
        k = (i-1)*lBurst+j;
        meanSeg{k} = mean(rs(k-pre*lBurst:lBurst:k+post*lBurst,:));
        if (endThresh>0)
         l = find(rawSeg{i}(1:artMaxLength)<endThresh,1,'last');
        else
           l = find(rawSeg{i}(1:artMaxLength)>endThresh,1,'last');
        end
        cleanSeg{k}(l+lZero+1:mTime) = double(rawSeg{k}(l+lZero+1:end)) - ...
            meanSeg{k}(l+lZero+1:end);
        cleanSeg{k}(1:l+lZero) = cleanSeg{k}(l+lZero+1);
        cleanSeg{k}(end-tZero+1:end) = cleanSeg{k}(end-tZero);
        deadLength(i) = l+lZero;
        if (rem(k,100)==0)
            waitbar(k/nStim,h);
        end
    end
end

close(h);