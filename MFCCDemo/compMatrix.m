function [ normalizedOutput, fitQuality ] = compMatrix( filename1, filename2 )
%COMPMATRIX Summary of this function goes here
%   Detailed explanation goes here

 % Define variables
    Tw = 25;                % analysis frame duration (ms)
    Ts = 5;                 % analysis frame shift (ms)
    alpha = 0.97;           % preemphasis coefficient
    M = 40;                 % number of filterbank channels 
    C = 12;                 % number of cepstral coefficients
    L = 22;                 % cepstral sine lifter parameter
    LF = 300;               % lower frequency limit (Hz)
    HF = 3700;              % upper frequency limit (Hz)
    windowExtensionThreshold = 0.01;


    % Read speech samples, sampling rate and precision from file
    [ audio1, fs1, nbits1 ] = wavread( filename1 );
    [ audio2, fs2, nbits2 ] = wavread( filename2 );

    addpath('../mfcc');
    
    % get mfccs
    [ MFCC1, FBE1, frames ] = ...
                    mfcc( audio1, fs1, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, L );
   
    [ MFCC2, FBE2, frames ] = ...
                    mfcc( audio2, fs2, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, L );
                
                
                
    output = zeros(size(MFCC1,2),size(MFCC2,2));

    % set up matrix of MFCC similarity
    for i = 1:size(MFCC1,2)
       for j = 1:size(MFCC2,2)
           output(i,j) = norm(MFCC1(:,i)-MFCC2(:,j));
       end
    end
    
    keepPct = 0.3;
    % 1) keep the best keepPct% of measurements in the output
    % 2) set the matches that don't belong to the keepPct% best output to 0
    % 3) normalize the remaining matches so 1 is the best and 0 is the worst
    %
    % sort all the entries in the output matrix to identify the best ones
    sortedOutput = sort(output(1:size(output,1)*size(output,2)));
    % count the entries in the output matrix
    outputCount = size(output,1)*size(output,2);
    % we want to keep about keepPct% of the output.  The good matches are the
    % numbers near zero, which are at the beginning of the sorted output.
    % In order to keep keepPct% we set a threshold at the keepPct*outputCount entry,
    % calling it maxDifference. This is the maximum mfcc difference that we
    % consider a meaningful match.
    maxDiff = sortedOutput(round(outputCount*keepPct));
    % initialize a new matrix to store the normalized output values
    normalizedOutput = output;
    % convert from output to normalized output.
    for i = 1:size(MFCC1,2)
       for j = 1:size(MFCC2,2)
            if output(i,j) > maxDiff
                % anything that isn't in the top keepPct%, set to 0
                normalizedOutput(i,j) = 0;
            else
                % anything that is in the top keepPct%, normalize to put it
                % between 0 and 1, with 1 being perfect match and 0 being
                % no match at all.
                normalizedOutput(i,j) = (maxDiff-output(i,j))/maxDiff;
            end
       end
    end
    
    % find the contiguous region of MFCC1 that has the most matches to
    % MFCC2
    %
    %   find the total match quality for each frame of MFCC1
    matchedFrameQuality = zeros(size(MFCC1,2),1);
    for i = 1:size(MFCC1,2)
        matchedFrameQuality(i) = max(normalizedOutput(i,:));
    end
    %
    %   find the sliding window in MFCC1 of length equal to the entire MFCC2 that
    %   has the best match
    maxWindowSum = 0;
    maxWindowStart = 1;
    windowLength = size(MFCC2,2);
    for i = 1:(size(MFCC1,2)-size(MFCC2,2))
        slidingSum = 0;
        for j = i:(i + (windowLength-1))
            slidingSum = slidingSum + matchedFrameQuality(j);
        end
        if slidingSum > maxWindowSum
            maxWindowSum = slidingSum;
            maxWindowStart = i;
        end
    end
    %
    % the best MFCC2 length section of MFCC1 goes from maxWindowStart to
    % (maxWindowStart + (windowLength-1))
    %
    % now we will see if the match can be improved by lengthening the
    % window.
    %
    % scan back from the window start until we reach numZerosIgnorable consecutive frames
    % with match quality below windowExtensionThreshold
    i = maxWindowStart;
    maxWindowEnd = maxWindowStart + windowLength - 1;
    numFound = 0;
    numZerosIgnorable = 2;
    while i > 0 && numFound <= numZerosIgnorable
        if matchedFrameQuality(i) < windowExtensionThreshold
            % we found a frame below the threshold
            numFound = numFound + 1;
        else
            % if this frame isn't below the threshold, reset the count
            numFound = 0;
        end
        i = i - 1;
    end
    %
    if numFound > numZerosIgnorable % we actually found a region of low match quality
        maxWindowStart = i + 1 + numZerosIgnorable;
    else % we didn't find the low match quality region but we reached the beginning of the array
        maxWindowStart = 1; % 0 in c++
    end
    %
    % now scan forward from the end of the maxWindow
    i = maxWindowStart + windowLength;
    numFound = 0;
    numZerosIgnorable = 3;
    while i <= size(matchedFrameQuality,1) && numFound < numZerosIgnorable
        if matchedFrameQuality(i) < windowExtensionThreshold
            % we found a frame below the threshold
            numFound = numFound + 1;
        else
            % if this frame isn't below the threshold, reset the count
            numFound = 0;
        end
        i = i + 1;
    end
    %
    if numFound >= numZerosIgnorable % we actually found a region of low match quality
        maxWindowEnd = i - 1 - numZerosIgnorable;
    else % we didn't find the low match quality region but we reached the end of the array
        maxWindowEnd = size(matchedFrameQuality,1);
    end
    %
    % we now know that the region between maxWindowStart and maxWindowEnd
    % is the region for which MFCC1 has good matching with MFCC2. We can
    % trum the normalizedOutput to discard the values outside this region
    trimmedNormalisedOutput = zeros(maxWindowEnd-maxWindowStart + 1,size(MFCC2,2));
    for i = maxWindowStart:maxWindowEnd
        for j = 1:size(MFCC2,2)
            trimmedNormalisedOutput(i - maxWindowStart + 1,j) = normalizedOutput(i,j);
        end
    end
    
    % find the centroid location in each row of the matrix using a weighted
    % average
    centroids = zeros(size(trimmedNormalisedOutput,1),1);
    for i = 1:size(trimmedNormalisedOutput,1)
       centroids(i) = trimmedNormalisedOutput(i,:)*(1:size(MFCC2,2))'/sum(trimmedNormalisedOutput(i,:));
    end
    
    % fit a linear function to the list of centroids
    [xData, yData] = prepareCurveData( [], centroids );

    % Set up fittype and options.
    ft = fittype( 'poly1' ); % linear regression
    opts = fitoptions( ft );
    opts.Lower = [-Inf -Inf]; % unbounded
    opts.Upper = [Inf Inf]; % unbounded

    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );

    % mark the fit line on the output matrix
    for i = 1:size(MFCC1,2)
        % uncomment the next line to show the best fit line on the output
        % matrix.  This affects the result of the fitQuality so don't do
        % this except for debugging to check the linear regression.
        %
        %normalizedOutput(i,round(fitresult(i))) = maxError;
    end
  
    % estimate quality of match at each part of the word
    timeTolerance = 10; % check values in the region +-timeTolerance frames of deviation from the best fit line
    fitQuality = zeros(size(MFCC2,2),1);
    for j = 1:size(MFCC2,2)
        % find the location of the best fit line in the output matrix
        fitLocation = round(fitresult(j));
        
        % find out if the tolerance region around the fit line hangs over
        % the left or right edge of the matrix
        toleranceWindowExcessLeft = max(timeTolerance - fitLocation + 1,0);
        toleranceWindowExcessRight = max(timeTolerance + fitLocation - size(MFCC1,2),0);
        
        % taking the overhang at the edges into account, compute the
        % boundaries of the tolerance region
        toleranceWindowStart = fitLocation - timeTolerance + toleranceWindowExcessLeft;
        toleranceWindowEnd = fitLocation + timeTolerance - toleranceWindowExcessRight;
        
        % the fit quality for the jth window is the best match value in the
        % region fitLocation (+-) timeTolerance
        fitQuality(j) = max(normalizedOutput(toleranceWindowStart:toleranceWindowEnd,j));
    end
    
    % plot the matrix output
    %imagesc(normalizedOutput);
    
    % plot the fitQuality output
    %
    plot(fitQuality);
  
end

