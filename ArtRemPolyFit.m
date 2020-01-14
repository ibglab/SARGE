function [cleanSeg, meanSeg, stimTime, deadLength] = ArtRemPolyFit(rawData, stimTime,lZero,tZero,endThresh,maxLength,rate,sessionKind,polydeg,S,E,SL,N)

[stimTime,rawSeg] = BuildRawSeg(rawData, stimTime);

nStim = length(stimTime);
dTime = diff(stimTime);
dTime(nStim) = dTime(nStim-1);
meanSeg2 = mean(cell2mat(rawSeg));
leangthMean=length(meanSeg2);
deadLength = zeros(1,length(stimTime));


cleanSeg = cell(nStim,1);
meanSeg = cell(nStim,1);
h=waitbar(0,'Artifact removal...');
for i=1:nStim
    if endThresh<0
        l = find(rawSeg{i}(1:maxLength)<endThresh,1,'last');
    else
        l = find(rawSeg{i}(1:maxLength)>endThresh,1,'last');
    end
    if isempty(l)
        l=0;
    end
    segLength = length(rawSeg{i});
    %segLength=dTime(i);
    if segLength>(rate/1000)*100
        segLength=(rate/1000)*100;
    end
    baseind = l+lZero;
    w=zeros(length(rawSeg{i})-2*N-baseind,3);
    t0=0;
    t2=0;
    for j=-N:N
        w(1,1)=w(1,1)+rawSeg{i}(baseind+N+1+j);
        w(1,2)=w(1,2)+rawSeg{i}(baseind+N+1+j)*j;
        w(1,3)=w(1,3)+rawSeg{i}(baseind+N+1+j)*j*j;
        t0=t0+1;
        t2=t2+j*j;
    end
    for n=2:length(rawSeg{i})-(2*N+1)-baseind
        w(n,1)=w(n-1,1)+rawSeg{i}(n+2*N+baseind)-rawSeg{i}(n-1+baseind);
        w(n,2)=w(n-1,2)-w(n-1,1)+N*rawSeg{i}(n+2*N+baseind)-(-N-1)*rawSeg{i}(n-1+baseind);
        w(n,3)=w(n-1,1)-2*w(n-1,2)+w(n-1,3)+N*N*rawSeg{i}(n+2*N+baseind)-(-N-1)*(-N-1)*rawSeg{i}(n-1+baseind);
    end
    meanSeg{i}=zeros(1,dTime(i));
    
    for n=N+1+baseind:length(rawSeg{i})-N-1
        meanSeg{i}(n)=w(n-N-baseind,1)/t0+w(n-N-baseind,3)/t2;
    end
    meanSeg{i}(1:baseind) =rawSeg{i}(1:baseind);
    %rawLength=length(rawSeg{i});
    rawLength=segLength;

    if sessionKind==2
        if segLength==(rate/1000)*100
            meanSeg{i}(baseind:baseind+N+SL) = compArtifact([1:2*N+SL+1]/rate, rawSeg{i}(baseind:baseind+2*N+SL), 1:N+SL+1, polydeg);
            meanSeg{i}(segLength+1:min(dTime(i),leangthMean))= meanSeg2(segLength+1:min(dTime(i),leangthMean));
            cleanSeg{i}(baseind+1:min(dTime(i),leangthMean)) = [(rawSeg{i}(baseind+1:min(dTime(i),leangthMean)) - meanSeg{i}(baseind+1:min(dTime(i),leangthMean)))];
        else
            meanSeg{i}(baseind:baseind+N+S) = compArtifact([1:2*N+S+1]/rate, rawSeg{i}(baseind:baseind+2*N+S), 1:N+S+1,polydeg);
            meanSeg{i}(rawLength-N-E:rawLength) = meanSeg2(rawLength-N-E:rawLength);
            cleanSeg{i}(baseind+1:rawLength) = rawSeg{i}(baseind+1:rawLength) - meanSeg{i}(baseind+1:rawLength);
        end
    end
    if sessionKind==1
        if segLength==(rate/1000)*100
            meanSeg{i}(baseind:baseind+N+150) = compArtifact([1:2*N+151]/rate, rawSeg{i}(baseind:baseind+2*N+150), 1:N+151, polydeg);
            meanSeg{i}(segLength+1:dTime(i))= meanSeg{i}(segLength);
            cleanSeg{i}(baseind+1:rawLength) = [(rawSeg{i}(baseind+1:segLength) - meanSeg{i}(baseind+1:segLength))  rawSeg{i}(segLength+1:rawLength)];
        else
            meanSeg{i}(baseind:baseind+N+100) = compArtifact([1:2*N+101]/rate, rawSeg{i}(baseind:baseind+2*N+100), 1:N+101, polydeg);
            meanSeg{i}(rawLength-N-50:rawLength) = compArtifact(1/rate:1/rate:(60+2*N+1)/rate, rawSeg{i}(rawLength-2*N-60:rawLength),N:2*N+50 , polydeg);
            cleanSeg{i}(baseind+1:rawLength) = rawSeg{i}(baseind+1:rawLength) - meanSeg{i}(baseind+1:rawLength);
        end
    end
    % Trailing zeros - pad the last samples with the previuos sample value,
    % according to the number of trailing zeros
    cleanSeg{i}(end-tZero+1:end) = cleanSeg{i}(end-tZero);
    deadLength(i) = l+lZero;
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
