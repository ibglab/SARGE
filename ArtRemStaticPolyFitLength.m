function [cleanSeg, meanSeg, stimTime, deadLength] = ArtRemStaticPolyFitLength(rawData, stimTime,lZero,tZero,maxFit,endThresh,polydeg, artMaxLength,samplingRate,msgText)
% The function removes the artifact using polynomial fit for each segment
% (inter-stimulus-interval).
% The function external variable for lengths of artifact.
% This methods relevant for long ISI's, where the polynomial fit should be
% shorter than the segment.

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
            l = find(rawSeg{i}(1:artMaxLength)<endThresh,1,'last');
        else
            l = find(rawSeg{i}(1:artMaxLength)>endThresh,1,'last');
        end

        x = (l+1:maxFit)';
        segLength = maxFit;

        baseind = x(1);
        
        if(segLength>length(rawSeg{i}))
            set(msgText,'String','Max fit needs to be lower.');
        end
        
        len = length(rawSeg{i}(baseind:segLength));

        meanSeg{i}(baseind:segLength) = compArtifact([1:len]/samplingRate, rawSeg{i}(baseind:segLength), 1:len, polydeg);rawSeg{i};
        meanSeg{i}(segLength+1:dTime(i))= meanSeg{i}(segLength);
        meanSeg{i}(1:l+lZero) = rawSeg{i}(1:l+lZero);
        
      cleanSeg{i}(l+lZero+1:dTime(i)) = [(rawSeg{i}(l+lZero+1:segLength) - meanSeg{i}(l+lZero+1:segLength))  rawSeg{i}(segLength+1:dTime(i))];

        % Trailing zeros - pad the last samples with the previuos sample value,
        % according to the number of trailing zeros
        cleanSeg{i}(end-tZero+1:end) = cleanSeg{i}(end-tZero);

        deadLength(i) = l+lZero;
    catch
        meanSeg{i} = rawSeg{i} ;
        bad = bad + 1;
        cleanSeg{i} = zeros(1,length(rawSeg{i}));
    end
    if (rem(i,10)==0)
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
