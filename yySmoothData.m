function smthData = yySmoothData(data, smthType, winSize)
% The function smoothes data vector by convolution of the data with a window.

% Input Arguments:
% data - the raw data vector
% smthType - 'gauss' for guassian window, 'quad' for quadrangular window (simple mean)
% winSize - the size of the window (must be odd! even window size is not handled)

% Output:
% The smoothed data vector, of the same size as 'data'.

isError = 0;

% Turn sparse data into full
if issparse(data)
    data = full(data)
end

% Turn data vector into row vector if necessary
if size(data,2) == 1
    data = data';
end

% Check if the data is sparse (i.e., less than 10% of it are zeros)
if (length(find(data))) / (length(data)) < 0.1
    isSparseData = 1;
else
    isSparseData = 0;
end

% Create a window for convolution
if rem(winSize, 2) == 0
    'Error - window size must be odd!'
    isError = 1;
end % if rem...

if isError == 0 % Window size is odd as required

    % Create the window
    switch smthType
        case 'gauss' % gaussian window
            convWindow = gausswin(winSize);
        case 'quad'
            convWindow = ones(1, winSize);
        case 'hanning'
            convWindow = hanning(winSize)';
        case 'hamming'
            convWindow = hamming(winSize)';
        otherwise
            'Error - smthType options are: ''gauss'', ''quad'', ''hanning'', ''hamming''!'
            isError = 2;
    end % switch smthType...
    
    if isError == 0 % smthType is OK
        
        % Turn convWindow into row vector if necessary
        if size(convWindow,2) == 1
            convWindow = convWindow';
        end

        % Normalize the window
        convWindow = convWindow ./ sum(convWindow);

        % Smooth the data by convolution with the convWindow
        if ~isSparseData
            % Convolution
            smthData = conv(data, convWindow);
        else
            % If the data is sparse, convolve it my own way
            smthData = convSparse(data, convWindow);
        end
        
        % Extract edges - (winSize-1)/2 at each edge
        smthData(1 : (winSize-1)/2) = [];
        smthData(end-(winSize-1)/2+1 : end) = [];
        
        % Correct the remaining edges ((winSize+1)/2-1 bins at each edge),
        % because they are convolved with only a part of the window.
        tempLength = length(smthData);
        for i = 1 : 1 : (winSize+1)/2-1
            % Check the index to make sure you don't make a wrong correction
            if i < (tempLength+1)/2
                % Calculate the correction ratio
                winPart = sum(convWindow(1:i+(winSize-1)/2)) ./ sum(convWindow);
                % Correct at the beginning edge
                smthData(i) = smthData(i) / winPart;
                % Correct at the end edge
                smthData(tempLength-i+1) = smthData(tempLength-i+1) / winPart;
            end % if i...
        end % for i
        
    end % if isError == 0
    
end % if isError == 0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function smthData = convSparse(data, convWindow)
% data should be 0/1 vector

% Convolution window size
convWinSize = length(convWindow);

% Pad the data vector with zeros at the edges (use some tricks to prevent
% memory problems)
padVec = zeros(1, (convWinSize-1)/2);
data = [padVec data padVec];

% Smoothed data initialization
smthData = zeros(1, length(data));

% Find all indices of non-zero elements
inds = find(data);

% Loop on all the non-zero elements, for each of them add to its vicinity
% the convWindow
for i = 1 : length(inds)
    currInds = inds(i)-(convWinSize-1)/2 : inds(i) + (convWinSize-1)/2;
    smthData(currInds) = smthData(currInds) + convWindow;
end

