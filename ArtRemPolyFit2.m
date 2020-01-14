function [cleanSeg, meanSeg, stimTime] = ArtRemPolyFit(rawData, stimTime,lZero,tZero,endThresh)

    [stimTime,rawSeg] = BuildRawSeg(rawData, stimTime);

nStim = length(stimTime);
dTime = diff(stimTime);
mTime = median(dTime);

cleanSeg = cell(nStim,1);
meanSeg = cell(nStim,1);


h=waitbar(0,'Artifact removal...');
bad = 0;
stop = false;

    for i=1:nStim
        try
        %for i=1521:1539
    %         l = find(rawSeg{i}<endThresh,1,'last');
            l = find(rawSeg{i}>endThresh,1,'last');
            if (i<nStim && dTime(i)<mTime)
                x = (l+lZero+1:dTime(i))';
                segLength = dTime(i);        
            else
                x = (l+lZero+1:mTime)';
                segLength = mTime;
            end
            N1 = 15 ;
            N = 30 ;
            halfN = floor(N/2);
            An = zeros(1,segLength);
            rate = 40000 ;
            baseind = l+lZero;
            meanSeg{i}(1:baseind) =rawSeg{i}(1:baseind);
            for j = baseind+N1:segLength-N
                if j == baseind+N1
    %                 An(1:N1) = compArtifact(1/rate:1/rate:N/rate, sig(1:N), 1:N1, 3);
                    meanSeg{i}(baseind:baseind+N1) = compArtifact([1:N1+1]/rate, rawSeg{i}(baseind:baseind+N1), 1:N1+1, 3);
    %                 An(1:N1) = compArtifactExp(1/rate:1/rate:N1/rate, sig(1:N1)', 1:N1);
    %                 An(1:N1) = compArtifactPower(1/rate:1/rate:N1/rate, sig(1:N1), 1:N1);  
                elseif j > baseind+N1 & j <= baseind+N
    %                 An(j) = compArtifact(1/rate:1/rate:(2*N1+1)/rate, sig(j-N1:j+N1), N1+1 , 5);
                    meanSeg{i}(j) = compArtifact(1/rate:1/rate:(2*N1+1)/rate, rawSeg{i}(j-N1:j+N1), N1+1 , 3);
                elseif j+N == segLength
                    meanSeg{i}(j:j+N) = compArtifact(1/rate:1/rate:(2*N+1)/rate, rawSeg{i}(j-N:segLength),N+1:2*N+1 , 3);
                else
    %                 An(j) = compArtifact(1/rate:1/rate:(2*N+1)/rate,
    %                 sig(j-N:j+N)', 1);
                    meanSeg{i}(j) = compArtifact(1/rate:1/rate:(2*N+1)/rate, rawSeg{i}(j-N:j+N), N+1, 3);
                end
            end
        catch
            meanSeg{i} = rawSeg{i} ;
            bad = bad + 1;
            cleanSeg{i}
        end
        
%         meanSeg{i}(l+lZero+1:segLength) = expRegg2(beta,x);
        
        cleanSeg{i}(l+lZero+1:segLength) = rawSeg{i}(l+lZero+1:segLength) - meanSeg{i}(l+lZero+1:segLength);
%         cleanSeg{i}(1:l+lZero) = cleanSeg{i}(l+lZero+1);
        % Trailing zeros - pad the last samples with the previuos sample value,
        % according to the number of trailing zeros
        cleanSeg{i}(end-tZero+1:end) = cleanSeg{i}(end-tZero);
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