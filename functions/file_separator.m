function file_separator(masterFolderPath, folderName1, folderName2, folderName3)
    % FILE_SEPARATOR separa i file in sottocartelle di 'testing' e 'training'
    % dati i nomi di 3 sottocartelle, separa i file .ogg in queste cartelle
    % per il 70% in training e 30% in testing

    folderNames = {folderName1, folderName2, folderName3};
    
    for i = 1:3
        folderPath = fullfile(masterFolderPath, folderNames{i}); %returna il path completo della cartella
        
        % se la cartella esiste
        if isfolder(folderPath)
            % crea le sottocartelle 'training' e 'testing'
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
            
            % crea una lista di tutti i file .ogg presenti nella classe indicata
            oggFiles = dir(fullfile(folderPath, '*.ogg'));
            numFiles = length(oggFiles);
            
            % numero per dividere i file (70% training, 30% testing)
            numTraining = round(0.7 * numFiles);
            
            % genera degli indici random, che vanno da 0 a numFiles
            randIndices = randperm(numFiles);
            
            % sposta i file della classe nella rispettiva sottocartella 'training'
            for j = 1:numTraining
                movefile(fullfile(folderPath, oggFiles(randIndices(j)).name), trainingFolder);
            end
            
            % sposta i file della classe nella rispettiva sottocartella 'testing'
            for j = numTraining+1:numFiles
                movefile(fullfile(folderPath, oggFiles(randIndices(j)).name), testingFolder);
            end
        end
    end
end