function [C, S, E, R, F, mfccs] = freqFeatures(filename, windowLength, stepLength)
[y,fs] = audioread(filename);
% check if mono
if size(y,2)==2, y=sum(y,2)/2; end
[M,nf] = windowize(y,windowLength*fs,stepLength*fs);
Ham = window(@hamming, windowLength*fs);
% initialization to zero
C=zeros(1,nf);
S=zeros(1,nf);
R=zeros(1,nf);
F=zeros(1,nf);
E=zeros(1,nf);
mfccs = zeros(13,nf);
% parameterization for the MFCCs
mfccParams = feature_mfccs_init(windowLength*fs, fs);
for i=1:nf
    frame = M(:,i);
    frame = frame.*Ham;
    frameFFT = getDFT(frame, fs);
    [C(i),S(i)] = feature_spectral_centroid(frameFFT, fs);
    E(i) = feature_spectral_entropy(frameFFT, 10);
    R(i) = feature_spectral_rolloff(frameFFT, 0.9);
    if i==1
        F(i) = feature_spectral_flux(frameFFT, zeros(length(frameFFT),1));
    else
        framePrev = M(:,i-1);
        framePrev = framePrev.*Ham;
        framePrevFFT = getDFT(framePrev, fs);
        F(i) = feature_spectral_flux(frameFFT, framePrevFFT);
    end
    mfccs(1:13,i) = feature_mfccs(frameFFT, mfccParams);
end