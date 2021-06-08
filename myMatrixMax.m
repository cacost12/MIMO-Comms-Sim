function [maxVal,index] = myMatrixMax(A)
% myMatrixMax: Find the maximum entry in a matrix and returns the value
% with indices
% Inputs: 
%        A - Matrix of interest
% Outputs: 
%        maxVal - Largest entry in the matrix
%        index - indices of the largest matrix entry
[maxVals, maxRows] = max(A);
[maxVal, maxCol] = max(maxVals);
maxRow = maxRows(maxCol);

index = [maxRow maxCol];
end

