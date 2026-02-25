function [fVec, magSpec] = compute_fft_spectrum(signal, fs)
% DESCRIPTION: Calculates a normalized one-sided magnitude spectrum.
% INPUTS:  signal - Input data; fs - Sampling frequency (Hz).
% OUTPUTS: fVec - Frequency vector; magSpec - Normalized magnitude.

    nSamples = length(signal);
    
    % 1. Compute complex FFT
    fftComplex = fft(signal);
    
    % 2. Normalize magnitude by signal length (N)
    fullMag = abs(fftComplex) / nSamples;
    
    % 3. Frequency vector scaling
    fullFreq = (0:nSamples-1) * (fs / nSamples);
    
    % 4. Select the positive half (Single-sided spectrum)
    halfIdx = 1:floor(nSamples/2);
    fVec = fullFreq(halfIdx);
    magSpec = fullMag(halfIdx);

end