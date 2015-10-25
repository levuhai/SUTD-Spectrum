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
    ab = round(outputCount*keepPct);
    maxDiff = sortedOutput(ab);
    disp(sortedOutput(1));
    
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
    
    % find the centroid location in each row of the matrix using a weighted
    % average
    centroids = zeros(size(MFCC1,2),1);
    
    for i = 1:size(MFCC1,2)
       centroids(i) = normalizedOutput(i,:)*(1:size(MFCC2,2))'/sum(normalizedOutput(i,:));
       disp(normalizedOutput(i,:)');
       disp(normalizedOutput(i,:)*(1:size(MFCC2,2))');
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
        disp (normalizedOutput(toleranceWindowStart:toleranceWindowEnd,j));
    end
    
    % plot the matrix output
    %imagesc(normalizedOutput);
    
    % plot the fitQuality output
    %
    plot(fitQuality);
    %plot(centroids)
  
end

