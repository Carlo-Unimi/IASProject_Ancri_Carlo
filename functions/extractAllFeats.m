function [classTrainFeatF, classTrainFeatT, classTestFeatF, classTestFeatT] = extractAllFeats(classSubFolderPath, windowLength, stepLength)


classTrainFiles = dir(fullfile(classSubFolderPath, 'training', '*.ogg'));
classTestFiles = dir(fullfile(classSubFolderPath, 'testing', '*.ogg'));

classTrainFeatF = []; classTrainFeatT = [];
for i = 1:length(classTrainFiles)
    [C, S, E, R, F, mfccs] = freqFeatures(classTrainFiles(i).name, windowLength, stepLength);
    tmp = [C; S; E; R; F; mfccs];
    classTrainFeatF = [classTrainFeatF tmp];

    [Et, EEt, Z] = timedomainFeats(classTrainFiles(i).name, windowLength, stepLength);
    tmp = [Et; EEt; Z];
    classTrainFeatT = [classTrainFeatT tmp];
end

classTestFeatF = []; classTestFeatT = [];
for i = 1:length(classTestFiles)
    [C, S, E, R, F, mfccs] = freqFeatures(classTestFiles(i).name, windowLength, stepLength);
    tmp = [C; S; E; R; F; mfccs];
    classTestFeatF = [classTestFeatF tmp];

    [Et, EEt, Z] = timedomainFeats(classTestFiles(i).name, windowLength, stepLength);
    tmp = [Et; EEt; Z];
    classTestFeatT = [classTestFeatT tmp];
end

classTrainFeatF(isnan(classTrainFeatF)) = 0;
classTrainFeatT(isnan(classTrainFeatT)) = 0;
classTestFeatF(isnan(classTestFeatF)) = 0;
classTestFeatT(isnan(classTestFeatT)) = 0;

end