function [bestRecognRate, bestMdl, bestInd] = findBestMdl(timeRecognRate, freqRecognRate, allRecognRate, timeMdl, freqMdl, allMdl)

timeV = max(timeRecognRate);
fprintf('Percentuale di riconoscimento massima sui tempi: %.3f\n', timeV);

freqV = max(freqRecognRate);
fprintf('Percentuale di riconoscimento massima sulle frequenze: %.3f\n', freqV);

allV = max(allRecognRate);
fprintf('Percentuale di riconoscimento massima sia su tempi che su frequenze: %.3f\n\n', allV);

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