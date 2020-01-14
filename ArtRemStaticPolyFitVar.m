function [cleanSeg, meanSeg, stimTime, deadLength] = ArtRemStaticPolyFitVar(rawData, stimTime,lZero,tZero,maxInterval,endThresh,polydeg, srchExt,maxLength,sampRate)
% The function removes the artifact using polynomial fit for each segment
% (inter-stimulus-interval).
% The function supports variable lengths of segments.
% To support a stimulation protocol of bursts of stimuli, a maximal
% segment length (maxInterval) is used. In case the segment's length is >
% maxInterval, it means that this is an interval between bursts, therefore
% the segment length that is used instead is the same length as the
% previous segment.

[stimTime,rawSeg] = BuildRawSegVar2(rawData, stimTime);

nStim = length(stimTime);
dTime = diff(stimTime);
dTime(nStim) = dTime(nStim-1);

deadLength = zeros(1,length(stimTime));

cleanSeg = cell(nStim,1);
meanSeg = cell(nStim,1);


h=waitbar(0,'Artifact removal...');

bad = 0;
for i = 1:nStim
    try
        if endThresh<0
             l = find(rawSeg{i}(1:maxLength)<endThresh,1,'last');
        else
            l = find(rawSeg{i}(1:maxLength)>endThresh,1,'last');
        end
        if srchExt
            ll = find(diff(rawSeg{i}(l:l+7))>0, 1, 'first');
            l = l+ll-1 ;
        end
        % In case of a segment longer than maxInterval, fit a polynom only  
        % to the first part of the segment (with length the same as the previous
        % segment)
        if dTime(i) < maxInterval
            % dTime is OK
            x = (l+lZero+1:dTime(i))';
            segLength = dTime(i);
        else
            % Shorten the segment to be fitted and use the length of the
            % previous segment.
            x = (l+lZero+1:dTime(i-1))';
            segLength = dTime(i-1);
        end % if dTime
      
        baseind = x(1);
        meanSeg{i}(1:baseind-1) = rawSeg{i}(1:baseind-1);
        
        len = length(rawSeg{i}(baseind:segLength));
        meanSeg{i}(baseind:segLength) = compArtifact([1:len]/sampRate, rawSeg{i}(baseind:segLength), 1:len, polydeg);
        cleanSeg{i}(l+lZero+1:segLength) = rawSeg{i}(l+lZero+1:segLength) - meanSeg{i}(l+lZero+1:segLength);

        % Trailing zeros - pad the last samples with the previuos sample value,
        % according to the number of trailing zeros
        cleanSeg{i}(end-tZero+1:end) = cleanSeg{i}(end-tZero);

        deadLength(i) = l+lZero;
    catch
        meanSeg{i} = rawSeg{i} ;
        bad = bad + 1;
        cleanSeg{i} = zeros(1,length(rawSeg{i}));
    end
    if (rem(i,500)==0)
        waitbar(i/nStim,h);
    end
end
close (h)


function art = compArtifact(x, sig, ind, deg)
x = x(:);
sig = sig(:);
p = polyfit(x,sig,deg) ;
vals = polyval(p,x);
art = vals(ind);
