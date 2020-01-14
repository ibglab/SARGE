function [cleanSeg, curveSeg, stimTime, deadLength] = ArtRemPolyFitDynam(rawData, stimTime, lZero, tZero, endThresh,polyDeg,polyFrom,polyTo,samplingRate)

dTime = diff(stimTime);
[stimTime,rawSeg] = BuildRawSeg(rawData, stimTime);
nStim = length(stimTime);
dTime(nStim)=dTime(nStim-1);
deadLength = zeros(1,length(stimTime));


cleanSeg = cell(nStim,1);
curveSeg = cell(nStim,1);

h=waitbar(0,'Artifact removal...');

 if (polyTo<0)
         polyTo =samplingRate/100;
    else
        polyTo = poltTo*40; %from ms to sampling rate
 end


for i=1:nStim
     if endThresh<0%-- 18/11/10 08:00 --%
            l = find(rawSeg{i}(1:maxLength)<endThresh,1,'last');
        else
            l = find(rawSeg{i}(1:maxLength)>endThresh,1,'last');
     end
    
    if (polyFrom<0)
        polyFrom = l;
    end
    len = length(rawSeg{i}(polyFrom+1:polyTo));   
    curveSeg{i} = rawSeg{i};
    curveSeg{i}( polyFrom+1:polyTo) =  compArtifact([1:len]/samplingRate, rawSeg{i}(polyFrom+1:polyTo), [1:len],polyDeg);
    curveSeg{i}(polyTo+1:dTime(i)) = curveSeg{i}(polyTo);
    curveSeg{i}(1:polyFrom+lZero)=rawSeg{i}(1:polyFrom+lZero);
    disp (i)
    cleanSeg{i}(polyFrom+lZero+1:dTime(i)) =[(rawSeg{i}(polyFrom+lZero+1:polyTo) - curveSeg{i}(polyFrom+lZero+1:polyTo)) rawSeg{i}(polyTo+1:dTime(i))];
    
    % Trailing zeros - pad the last samples with the previuos sample value,
    % according to the number of trailing zeros
    cleanSeg{i}(end-tZero+1:end) = cleanSeg{i}(end-tZero);
    deadLength(i) = polyFrom+lZero;
    if (rem(i,10)==0)
        waitbar(i/nStim,h);
    end
end

close(h);





 function art = compArtifact(x,y, ind, deg)
%        x = 1:length(y);
x = x(:);
        y = y(:);
        p = polyfit(x,y,deg) ;
        vals = polyval(p,x);
%         figure;plot(1:length(sig), sig, 'b',1:length(sig), vals, 'r')
%         hold on ; plot(ceil(length(vals)/2), vals(ceil(length(vals)/2)), 'g.')
        art = vals(ind);
%         for the first N points, return the  
%         if type == 0
%             art = vals;
%         else
%             art = vals(ceil(length(vals)/2)) ;
%         end
%            