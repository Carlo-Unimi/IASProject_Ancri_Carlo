function [TrFeatF, TrFeatT, TeFeatF, TeFeatT] = extractAllFeats(subFolPath, wL, sL)


classTrainFiles = dir(fullfile(subFolPath, 'training', '*.ogg'));
classTestFiles = dir(fullfile(subFolPath, 'testing', '*.ogg'));

TrFeatF = []; TrFeatT = [];
for i = 1:length(classTrainFiles)
    [C, S, E, R, F, mfccs] = freqFeatures(classTrainFiles(i).name, wL, sL);
    tmp = [C; S; E; R; F; mfccs];
    TrFeatF = [TrFeatF tmp];

    [Et, EEt, Z] = timedomainFeats(classTrainFiles(i).name, wL, sL);
    tmp = [Et; EEt; Z];
    TrFeatT = [TrFeatT tmp];
end

TeFeatF = []; TeFeatT = [];
for i = 1:length(classTestFiles)
    [C, S, E, R, F, mfccs] = freqFeatures(classTestFiles(i).name, wL, sL);
    tmp = [C; S; E; R; F; mfccs];
    TeFeatF = [TeFeatF tmp];

    [Et, EEt, Z] = timedomainFeats(classTestFiles(i).name, wL, sL);
    tmp = [Et; EEt; Z];
    TeFeatT = [TeFeatT tmp];
end

TrFeatF(isnan(TrFeatF)) = 0;
TrFeatT(isnan(TrFeatT)) = 0;
TeFeatF(isnan(TeFeatF)) = 0;
TeFeatT(isnan(TeFeatT)) = 0;

end