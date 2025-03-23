function [bestRecognRate, bestMdl, bestInd] = findBestMdl(timeRecognRate, freqRecognRate, allRecognRate, timeMdl, freqMdl, allMdl)

timeV = max(timeRecognRate);
fprintf('Max recognition rate with only time features: %.3f\n', timeV);

freqV = max(freqRecognRate);
fprintf('Max recognition rate with only frequency features: %.3f\n', freqV);

allV = max(allRecognRate);
fprintf('Max recognition rate with all the features: %.3f\n\n', allV);

maxV = [timeV, freqV, allV];

[~, bestInd] = max(maxV);

switch bestInd
    case 1
        bestRecognRate = timeRecognRate;
        bestMdl = timeMdl;
    case 2
        bestRecognRate = freqRecognRate;
        bestMdl = freqMdl;
    case 3
        bestRecognRate = allRecognRate;
        bestMdl = allMdl;
end

end