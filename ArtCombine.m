function cleanData = ArtCombine(rawData, stimTime, cleanSeg)

% Combine the clean segments and parts of the raw data
% to generate the clean data

nSegs = length(stimTime);

stimLen = zeros(nSegs,1);
for i=1:nSegs
    stimLen(i) = length(cleanSeg{i});
end

cleanData = NaN(length(rawData),1);

cleanData(1:stimTime(1)-1)=rawData(1:stimTime(1)-1);

for i=1:nSegs
     t = stimTime(i);
     l = stimLen(i);
     preValue = double(cleanData(t-1));
     p = cleanSeg{i} + preValue - cleanSeg{i}(1);
     cleanData(t:t+l-1)=p;
     if (i<nSegs && stimTime(i+1) > t+l)
        cleanData(t+l:stimTime(i+1)-1)=rawData(t+l:stimTime(i+1)-1) - ...
            rawData(t+l-1) + cleanData(t+l-1);
     end
end

cleanData(t+l:end)=rawData(t+l:end)+rawData(t+l-1) + cleanData(t+l-1);

% cleanData = double(rawData);
% 
% for i=1:nSegs
%     t = stimTime(i);
%     preValue = double(cleanData(t-3));
%     p = double(cleanSeg{i}) + preValue - double(cleanSeg{i}(1));
%     cleanData(stimTime(i):stimTime(i)+length(cleanSeg{i})-1)=p;
% end    