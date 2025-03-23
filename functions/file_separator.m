function file_separator(masterFolderPath, folderNames)
    
for i = 1:3
    folderPath = fullfile(masterFolderPath, folderNames{i});
    
    if isfolder(folderPath)
            
        testingFolder = fullfile(folderPath, 'testing');
        trainingFolder = fullfile(folderPath, 'training');
        if ~isfolder(testingFolder)
            mkdir(testingFolder);
        end
        if ~isfolder(trainingFolder)
            mkdir(trainingFolder);
        end
        addpath(testingFolder);
        addpath(trainingFolder);


        oggFiles = dir(fullfile(folderPath, '*.ogg'));
        numFiles = length(oggFiles);


        numTraining = round(0.7 * numFiles);


        randIndices = randperm(numFiles);


        for j = 1:numTraining
            movefile(fullfile(folderPath, oggFiles(randIndices(j)).name), trainingFolder);
        end


        for j = numTraining+1:numFiles
            movefile(fullfile(folderPath, oggFiles(randIndices(j)).name), testingFolder);
        end
    end
end

end