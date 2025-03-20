function [E, EE, Z] = timedomainFeats(filename, windowLength, stepLength)
[y,fs]=audioread(filename);
% check if mono
if size(y,2)==2, y=sum(y,2)/2; end
[M,nf]=windowize(y,windowLength*fs,stepLength*fs);
Ham = window(@hamming, windowLength*fs);
E = zeros(1,nf);
EE = zeros(1,nf);
Z = zeros(1,nf);
for i=1:nf
    frame = M(:,i);
    frame = frame.* Ham;
    E(i) = feature_energy(frame);
    EE(i) = feature_energy_entropy(frame,10);
    Z(i) = feature_zcr(frame);
end
