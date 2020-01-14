function [cleanSeg, meanSeg, stimTime, deadLength] = ArtRemMoveMeanVar(rawData, stimTime, kMean, lZero, tZero, endThresh,maxLength)

[stimTime,rawSeg,lSegs,dTimeRevised] = BuildRawSegVar(rawData, stimTime);

nStim = length(stimTime);
dTime = diff(stimTime);

deadLength = zeros(1,length(stimTime));

cleanSeg = cell(nStim,1);
meanSeg = cell(nStim,1);

h = waitbar(0,'Artifact removal...');

for j = 1 : length(lSegs)
    inds = find(dTimeRevised == lSegs(j));
    rs = cell2mat(rawSeg(inds));
    nStimTemp =length(inds);
    
    for i = 1 :nStimTemp
        pre = min(i-1,kMean);
        post = min(nStimTemp-i,kMean);
        if (nStimTemp==1)
            meanSeg{inds(i)}=rs;
        else
            meanSeg{inds(i)} = mean(rs(i-pre:i+post,:));
        end
		if (endThresh>0)
			l = find(rawSeg{inds(i)}(1:maxLength)>endThresh,1,'last');
		else
			l = find(rawSeg{inds(i)}(1:maxLength)<endThresh,1,'last');
        end
        if (isempty(l))
            l=0;
        end
        cleanSeg{inds(i)}(l+lZero+1:lSegs(j)) = double(rawSeg{inds(i)}(l+lZero+1:end)) - meanSeg{inds(i)}(l+lZero+1:end);
        cleanSeg{inds(i)}(1:l+lZero) = cleanSeg{inds(i)}(l+lZero+1);
        % Trailing zeros - pad the last samples with the previuos sample value,
        % according to the number of trailing zeros
        cleanSeg{inds(i)}(end-tZero+1:end) = cleanSeg{inds(i)}(end-tZero);
        deadLength(i) = l+lZero;
    end

    waitbar(j/length(lSegs),h);
    
end

close(h);

