function [matrix, mn, st] = safe_normalize(matrix)

matrix = matrix';
mn = mean(matrix);
st = std(matrix);

matrix = (matrix - repmat(mn, size(matrix, 1), 1)) ./repmat(st, size(matrix, 1), 1);

end