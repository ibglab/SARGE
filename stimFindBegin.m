function timeBegin = stimFindBegin(channel, beginThresh)

% Threshold for minimal distance in samples of two consecutive stimuli
minThresh = 100;

% Find location of the stimulus
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
    fprintf('stimFindBegin: Found %i crossings of threshold.\n',lstim);
end

dStim = diff(stim);
pStim = find(dStim>minThresh)';

timeBegin = stim([1;pStim+1])';

fprintf('stimFindBegin: Found %i stimulations (>%i samples apart).\n', ...
    length(timeBegin), minThresh);

timeBegin = timeBegin - 1;
