%% INITIALIZATION
clear; clc;

disp('--------------------------------');
disp('|       PROGRAM STARTED        |');
disp('--------------------------------');

subFolders = ["110 - Crow", "207 - Wind", "505 - Engine"];

datasetPath = uigetdir(pwd, 'Select the dataset dir.');
addpath(genpath(datasetPath));
disp('Adding the project folder (and all its subfolders) to the MATLAB path...');
addpath(genpath(pwd));
file_separator(datasetPath, subFolders);
tic; % timer

windowLength = 0.30; % seconds
stepLength = 0.15; % seconds

% estrae tutte le features
fprintf('Extracting [Crow] features...');
[crowTrainFeatF, crowTrainFeatT, crowTestFeatF, crowTestFeatT] = extractAllFeats(fullfile(datasetPath, subFolders(1)), windowLength, stepLength);
fprintf(' completed.\n');
fprintf('Extracting [Wind] features...');
[windTrainFeatF, windTrainFeatT, windTestFeatF, windTestFeatT] = extractAllFeats(fullfile(datasetPath, subFolders(2)), windowLength, stepLength);
fprintf(' completed.\n');
fprintf('Extracting [Engine] features...');
[engineTrainFeatF, engineTrainFeatT, engineTestFeatF, engineTestFeatT] = extractAllFeats(fullfile(datasetPath, subFolders(3)), windowLength, stepLength);
fprintf(' completed.\n\n');
fprintf('--- FEATURES EXTRACTION COMPLETED ---\n\n\n');


%% PCA ALGORITHM
disp('Applying the PCA algorithm using all the features...');

featMatrix = [[crowTrainFeatF crowTestFeatF windTrainFeatF windTestFeatF engineTrainFeatF engineTestFeatF];
    [crowTrainFeatT crowTestFeatT windTrainFeatT windTestFeatT engineTrainFeatT engineTestFeatT]];

[featMatrix, ~, ~] = safe_normalize(featMatrix); 

[~,score,~,~,explained] = pca(featMatrix);

fprintf('Number of coefficients which offer at least 80_percent of variance: %d\n\n', find(cumsum(explained) >= 80, 1));
figure;
hold on;
bar(cumsum(explained));
yline(80, '--k', '80% Variance', 'LabelHorizontalAlignment', 'left');
ylabel('Cumulative variance (%)');
xlabel('Number of coefficients');
title('Number of coefficients which offer at least 80% of variance');
grid on;
hold off;

C = [ones(size([crowTrainFeatF crowTestFeatF], 2), 1); ...  
     2 * ones(size([windTrainFeatF windTestFeatF], 2), 1); ... 
     3 * ones(size([engineTrainFeatF engineTestFeatF], 2), 1)]; 

figure;
scatter3(score(:, 1), score(:, 2), score(:, 3), 36, C);
xlabel('1st principal component');
ylabel('2nd principal component');
zlabel('3rd principal component');
title('PCA with coloured groups');
colormap([1 0 0; 0.8 0.2 1; 1 0.8 0]);


%% kNN ALGORITHM
disp('Initializing the kNN model...');
k = [1 5 10 15 30 50 100 200];

trainLabelCrow = ones(length(crowTrainFeatT), 1);
trainLabelWind = repmat(2, length(windTrainFeatT), 1);
trainLabelEngine = repmat(3, length(engineTrainFeatT), 1);

testLabelCrow = ones(length(crowTestFeatT), 1);
testLabelWind = repmat(2, length(windTestFeatT), 1);
testLabelEngine = repmat(3, length(engineTestFeatT), 1);

all_Labels = [trainLabelCrow; trainLabelWind; trainLabelEngine];
ground_truth = [testLabelCrow; testLabelWind; testLabelEngine];

% KNN [ONLY TIME FEATS]
timeTrainFeat = [crowTrainFeatT windTrainFeatT engineTrainFeatT];
timeTestFeat = [crowTestFeatT windTestFeatT engineTestFeatT];

[timeTrainFeat, mn, st] = safe_normalize(timeTrainFeat);
timeTestFeat = timeTestFeat';
timeTestFeat = (timeTestFeat - repmat(mn, size(timeTestFeat, 1), 1)) ./repmat(st, size(timeTestFeat, 1), 1);

[timeRecognRate, ~] = knnTrainer(timeTrainFeat, timeTestFeat, all_Labels', ground_truth, k);
[~, a] = max(timeRecognRate);
timeMdl = fitcknn(timeTrainFeat, all_Labels', 'NumNeighbors', k(a));

% KNN [ONLY FREQ FEATS]
freqTrainFeat = [crowTrainFeatF windTrainFeatF engineTrainFeatF];
freqTestFeat = [crowTestFeatF windTestFeatF engineTestFeatF];

[freqTrainFeat, mn, st] = safe_normalize(freqTrainFeat);
freqTestFeat = freqTestFeat';
freqTestFeat = (freqTestFeat - repmat(mn, size(freqTestFeat, 1), 1)) ./repmat(st, size(freqTestFeat, 1), 1);

[freqRecognRate, ~] = knnTrainer(freqTrainFeat, freqTestFeat, all_Labels', ground_truth, k);
[~, a] = max(freqRecognRate);
freqMdl = fitcknn(freqTrainFeat, all_Labels', 'NumNeighbors', k(a));

% KNN [ALL FEATS]
allTrainFeat = [[crowTrainFeatT windTrainFeatT engineTrainFeatT]; [crowTrainFeatF windTrainFeatF engineTrainFeatF]];
allTestFeat = [[crowTestFeatT windTestFeatT engineTestFeatT]; [crowTestFeatF windTestFeatF engineTestFeatF]];

[allTrainFeat, mn, st] = safe_normalize(allTrainFeat);
allTestFeat = allTestFeat';
allTestFeat = (allTestFeat - repmat(mn, size(allTestFeat, 1), 1)) ./repmat(st, size(allTestFeat, 1), 1);

[allRecognRate, ~] = knnTrainer(allTrainFeat, allTestFeat, all_Labels', ground_truth, k);
[~, a] = max(allRecognRate);
allMdl = fitcknn(allTrainFeat, all_Labels', 'NumNeighbors', k(a));

% kNN's recognition rate graphs
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

% best kNN model
[bestRecognRate, Mdl, bestInd] = findBestMdl(timeRecognRate, freqRecognRate, allRecognRate, timeMdl, freqMdl, allMdl);

names = ["time-feats"; "freq-feats"; "all-feats"];
disp('Finding the best model...');
[val, ind] = max(bestRecognRate);
fprintf('The best recognition rate is: %.3f, achieved with %d neighbours, using the %s trained model.\n\n', val, k(ind), names(bestInd));



fprintf('Program execution time: %.2fs.\n\n', toc);

disp('--------------------------------');
disp('|      END OF THE PROGRAM      |');
disp('--------------------------------');
