function ArtCalcProbRmvDist(rawData, meanSeg, stimTime,remArtName)

    [stimTime,rawSeg] = BuildRawSeg(rawData, stimTime);
    [meanMat] = BuildMeanMat(meanSeg, stimTime);
        
         dTime = diff(stimTime);
         mTime = median(dTime);
         nStim = length(stimTime);

        
        %totDis = sqrt(sum((cell2mat(meanSeg)-cell2mat(rawSeg)).^2,2));
        %totDis = sqrt(sum((cell2mat(meanSeg)-x).^2,2));

       % totDis = sum(abs(cell2mat(meanSeg)-x),2)/mTime;
        totDis = sum(abs(meanMat-cell2mat(rawSeg)),2)/mTime;
        
        nBars = length(meanSeg)/100;
        probDis = histc(totDis,min(totDis):(max(totDis)-min(totDis))/nBars:max(totDis))/nStim;
        figure
        bar(min(totDis):(max(totDis)-min(totDis))/nBars:max(totDis),probDis)
        title ([remArtName, ' ----  ', 'Median = ', num2str(median(totDis)), ',   Mean = ', num2str(mean(totDis))])
        xlabel('Distance from Raw Data')
        ylabel('Probability')