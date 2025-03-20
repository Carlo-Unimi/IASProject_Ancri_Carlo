function [recognRate, Mdl] = knnTrainer(trainFeat, testFeat, labels, ground_truth, k)


recognRate = zeros(1, length(k));

for aux = 1:length(k)
    
    Mdl = fitcknn(trainFeat, labels, 'NumNeighbors', k(aux), 'Standardize', true);

    predictedLabel = predict(Mdl, testFeat);

    correct = 0;
    for i = 1:length(predictedLabel)
        if predictedLabel(i) == ground_truth(i)
            correct = correct + 1;
        end
    end
    
    recognRate(aux) = (correct/length(predictedLabel))*100;
end

end
