function [cleanSeg, meanSeg, stimTime, deadLength] = ...
ArtRemSimple(rawData, stimTime, lZero, tZero, endThresh, artMaxLength)

dTime = diff([stimTime;length(rawData)-1]);
mTime = min(dTime)-1;
if (artMaxLength==0)
    artMaxLength = mTime;
end

[stimTime,rawSeg] = BuildRawSimple(rawData, stimTime);

nStim = length(stimTime);
deadLength = zeros(1,length(stimTime));

cleanSeg = cell(nStim,1);

meanSeg = zeros(1,mTime);

h=waitbar(0,'Artifact removal...');

rs = cell2mat(rawSeg);


for i=1:nStim
    if (endThresh>0)
        l = find(rawSeg{i}(1:artMaxLength)>endThresh,1,'last');
    else
        l = find(rawSeg{i}(1:artMaxLength)<endThresh,1,'last');
    end
    if (length(l)>0)
        cleanSeg{i}(l+lZero+1:mTime) = double(rawSeg{i}(l+lZero+1:end)) ;
        cleanSeg{i}(1:l+lZero) = cleanSeg{i}(l+lZero+1);
        cleanSeg{i}(end-tZero+1:end) = cleanSeg{i}(end-tZero);
        deadLength(i) = l+lZero;
    else
        cleanSeg{i} = rawSeg{i};
        deadLengt{i} = length(rawSeg{i});
        disp(['Error: Segment ' mat2str(i) ' no end found !']);
    end
    if (rem(i,10)==0)
        waitbar(i/nStim,h);
    end
end

close(h);