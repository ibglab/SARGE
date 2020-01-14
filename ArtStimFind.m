function timeBegin = ArtStimFind(channel, beginThresh, endThresh, minThresh, maxThresh)

% minThresh - Threshold for minimal distance in samples of two consecutive stimuli
% default: 80

% maxThresh - Threshold for maximal distance to end threshold
% default: 100

% Find location of the stimulus beginning
if (beginThresh<0)
    stim = find(channel<beginThresh);
else
    stim = find(channel>beginThresh);
end

lstim = length(stim);
if (lstim==0)
    fprintf('stimFindBegin: No stimulation found!\n');
    timeBegin = [];
    return;
else
    fprintf('ArtStimFind: Found %i crossings of threshold.\n',lstim);
end

dStim = diff(stim);
pStim = find(dStim>minThresh)';

timeBegin = stim([1;pStim+1])';

fprintf('ArtStimFind: Found %i stimulations (>%i samples apart).\n', ...
    length(timeBegin), minThresh);

% Find location of the stimulus ending
remList = [];
lChannel = length(channel);
if (endThresh>0)
    for i=1:length(timeBegin)
        maxTimeBegin = min(timeBegin(i)+maxThresh,lChannel);
        if (isempty(find(channel(timeBegin(i):maxTimeBegin)>endThresh)))
            remList = [remList i];
        end
    end
else
    for i=1:length(timeBegin)
        maxTimeBegin = min(timeBegin(i)+maxThresh,lChannel);
        if (isempty(find(channel(timeBegin(i):maxTimeBegin)<endThresh)))
            remList = [remList i];
        end
    end
end

if (~isempty(remList))
    timeBegin(remList)=[];
    fprintf('ArtStimFind: Found %i stimulations (<%i samples to end theshold).\n', ...
        length(timeBegin), maxThresh);
end

timeBegin = timeBegin - 1;
