%% INIZIALIZZAZIONE
clear; clc;

disp('------------------------------');
disp('|    ESECUZIONE INIZIATA     |');
disp('------------------------------');

subFolders = ["401 - Door knock", "402 - Mouse click", "403 - Keyboard typing"];

datasetPath = uigetdir(pwd, 'Selezionare la cartella del dataset.');
addpath(genpath(datasetPath));

addpath(genpath(uigetdir(pwd, 'Selezionare la cartella [IASPROJECT] Ancri Carlo.')));

tic; % cronometro

file_separator(datasetPath, subFolders(1), subFolders(2), subFolders(3));

windowLength = 0.5;
stepLength = windowLength/2;


% estrae tutte le features
fprintf('Estraggo tutte le features di [Crow]...');
[crowTrainFeatF, crowTrainFeatT, crowTestFeatF, crowTestFeatT] = extractAllFeats(fullfile(datasetPath, subFolders(1)), windowLength, stepLength);
fprintf(' estrazione completata.\n');
fprintf('Estraggo tutte le features di [Wind]...');
[windTrainFeatF, windTrainFeatT, windTestFeatF, windTestFeatT] = extractAllFeats(fullfile(datasetPath, subFolders(2)), windowLength, stepLength);
fprintf(' estrazione completata.\n');
fprintf('Estraggo tutte le features di [Engine]...');
[engineTrainFeatF, engineTrainFeatT, engineTestFeatF, engineTestFeatT] = extractAllFeats(fullfile(datasetPath, subFolders(3)), windowLength, stepLength);
fprintf(' estrazione completata.\n\n');
fprintf('--- ESTRAZIONE DELLE FEATURES COMPLETATA ---\n\n\n');



%% algoritmo KNN
disp('Inizializzo il modello kNN...');
k = [5 10 20 50 100 200];

% kNN [SOLO TEMPI]
trainLabelCrow = ones(length(crowTrainFeatT), 1);
trainLabelWind = repmat(2, length(windTrainFeatT), 1);
trainLabelEngine = repmat(3, length(engineTrainFeatT), 1);

timeTrainFeat = [crowTrainFeatT; windTrainFeatT; engineTrainFeatT];
all_Labels = [trainLabelCrow; trainLabelWind; trainLabelEngine];

testLabelCrow = ones(length(crowTestFeatT), 1);
testLabelWind = repmat(2, length(windTestFeatT), 1);
testLabelEngine = repmat(3, length(engineTestFeatT), 1);

timeTestFeat = [crowTestFeatT; windTestFeatT; engineTestFeatT];
ground_truth = [testLabelCrow; testLabelWind; testLabelEngine];

[timeRecognRate, timeMdl] = knnTrainer(timeTrainFeat, timeTestFeat, all_Labels, ground_truth, k);


% kNN [SOLO FREQUENZE]
trainLabelCrow = ones(length(crowTrainFeatF), 1);
trainLabelWind = repmat(2, length(windTrainFeatF), 1);
trainLabelEngine = repmat(3, length(engineTrainFeatF), 1);

freqTrainFeat = [crowTrainFeatF; windTrainFeatF; engineTrainFeatF];
all_Labels = [trainLabelCrow; trainLabelWind; trainLabelEngine];

testLabelCrow = ones(length(crowTestFeatF), 1);
testLabelWind = repmat(2, length(windTestFeatF), 1);
testLabelEngine = repmat(3, length(engineTestFeatF), 1);

freqTestFeat = [crowTestFeatF; windTestFeatF; engineTestFeatF];
ground_truth = [testLabelCrow; testLabelWind; testLabelEngine];

[freqRecognRate, freqMdl] = knnTrainer(freqTrainFeat, freqTestFeat, all_Labels, ground_truth, k);


% kNN [TUTTE LE FEATURES]
trainLabelCrow = ones(length([crowTrainFeatF, crowTrainFeatT]), 1);
trainLabelWind = repmat(2, length([windTrainFeatF, windTrainFeatT]), 1);
trainLabelEngine = repmat(3, length([engineTrainFeatF, engineTrainFeatT]), 1);

allTrainFeat = [[crowTrainFeatF, crowTrainFeatT]; [windTrainFeatF, windTrainFeatT]; [engineTrainFeatF, engineTrainFeatT]];
all_Labels = [trainLabelCrow; trainLabelWind; trainLabelEngine];

testLabelCrow = ones(length([crowTestFeatF, crowTestFeatT]), 1);
testLabelWind = repmat(2, length([windTestFeatF, windTestFeatT]), 1);
testLabelEngine = repmat(3, length([engineTestFeatF, engineTestFeatT]), 1);

allTestFeat = [[crowTestFeatF, crowTestFeatT]; [windTestFeatF, windTestFeatT]; [engineTestFeatF, engineTestFeatT]];
ground_truth = [testLabelCrow; testLabelWind; testLabelEngine];

[allRecognRate, allMdl] = knnTrainer(allTrainFeat, allTestFeat, all_Labels, ground_truth, k);



recGraphs = figure;
recGraphs.Position = [100, 100, 1500, 500];
subplot(1, 3, 1); plot(k, timeRecognRate)
xlabel('k');
title('Time recognition rate (%)');
grid on

subplot(1, 3, 2); plot(k, freqRecognRate)
xlabel('k');
title('Freq recognition rate (%)');
grid on

subplot(1, 3, 3); plot(k, allRecognRate)
xlabel('k');
title('All feat recognition rate (%)');
grid on




[bestRecognRate, Mdl, bestInd] = findBestMdl(timeRecognRate, freqRecognRate, allRecognRate, timeMdl, freqMdl, allMdl);

names = ["sui tempi"; "sulle frequenze"; "sia su tempi che su frequenze"];
disp('Trovo il modello più preciso...');
[val, ind] = max(bestRecognRate);
fprintf('Il rate massimo di riconoscimento è: %.3f, è ricavato con %d vicini dal modello allenato %s.\n\n', val, k(ind), names(bestInd));




%% algoritmo di PCA
disp('Eseguo l`algoritmo di PCA su tutte le features...');

featMatrix = [[[crowTrainFeatF,crowTrainFeatT];[crowTestFeatF,crowTestFeatT]];
    [[windTrainFeatF,windTrainFeatT];[windTestFeatF,windTestFeatT]];
    [[engineTrainFeatF,engineTrainFeatT];[engineTestFeatF,engineTestFeatT]]];
featMatrix = normalize(featMatrix);


[~,score,~,~,explained] = pca(featMatrix);

fprintf('Numero di coefficienti che spiegano più del 80 della varianza: %d\n\n', find(cumsum(explained) >= 80, 1));
figure;
hold on;
bar(cumsum(explained));

yline(80, '--k', '80% Varianza', 'LabelHorizontalAlignment', 'left');

ylabel('Varianza Cumulativa (%)');
xlabel('Numero di Componenti');
title('Numero di Componenti per Superare l’80% della Varianza');
grid on;
hold off;


C = [ones(size([crowTrainFeatF;crowTestFeatF], 1), 1); ...  
     2 * ones(size([windTrainFeatF;windTestFeatF], 1), 1); ... 
     3 * ones(size([engineTrainFeatF;engineTestFeatF], 1), 1)]; 

figure;
scatter3(score(:, 1), score(:, 2), score(:, 3), 36, C);

xlabel('Prima componente principale');
ylabel('Seconda componente principale');
zlabel('Terza componente principale');
title('PCA con colorazione per gruppi');

colormap([1 0 0; 0.8 0.2 1; 1 0.8 0]);



fprintf('Tempo impiegato ad eseguire il programma: %.2fs.\n\n', toc);

disp('------------------------------');
disp('|    ESECUZIONE CONCLUSA     |');
disp('------------------------------');