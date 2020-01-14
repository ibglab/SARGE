function [meanMat] = BuildMeanMat(meanSeg, stimTime)

    nStim = length(stimTime);
    dTime = diff(stimTime);
    mTime = median(dTime);

    meanMat = zeros(nStim,mTime);

    for i=1:nStim
        x = cell2Mat(meanSeg(i));
        if (size(x,2)<mTime)
            meanMat(i,1:size(x,2))=x;
            meanMat(i,size(x,2)+1:mTime) = x(1,end);
        else
            meanMat(i,1:end)=x;
        end
    end

    