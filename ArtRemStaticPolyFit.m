function [cleanSeg, meanSeg, stimTime, deadLength] = ArtRemStaticPolyFit(rawData, stimTime,lZero,tZero,endThresh,polydeg, srchExt,maxLength,rate)

[stimTime,rawSeg] = BuildRawSeg(rawData, stimTime);

nStim = length(stimTime);
dTime = diff(stimTime);
mTime = median(dTime);

deadLength = zeros(1,length(stimTime));

cleanSeg = cell(nStim,1);
meanSeg = cell(nStim,1);


h=waitbar(0,'Artifact removal...');

stop = false;
bad = 0;
for i=1:nStim
    try
        %l-till this point(+leading zeros) the artifact remove.
        if endThresh<0
            l = find(rawSeg{i}(1:maxLength)<endThresh,1,'last');
        else
            l = find(rawSeg{i}(1:maxLength)>endThresh,1,'last');
        end
        if srchExt
            ll = find(diff(rawSeg{i}(l:l+7))>0, 1, 'first');
            l = l+ll-1 ;
        end
        if (i<nStim && dTime(i)<mTime)
            x = (l+lZero+1:dTime(i))';
            segLength = dTime(i);
        else
            x = (l+lZero+1:mTime)';
            segLength = mTime;
        end
        baseind = x(1);
        meanSeg{i}(1:baseind-1) = rawSeg{i}(1:baseind-1);
        len = length(rawSeg{i}(baseind:segLength));
        meanSeg{i}(baseind:segLength) = compArtifact([1:len]/rate, rawSeg{i}(baseind:segLength), 1:len, polydeg);
        
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
