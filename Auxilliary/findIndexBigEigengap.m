function [K, releigengaps, eigengaps] = findIndexBigEigengap(lambdas)
%FINDINDEXBIGEIGENGAP Find the number fo natural clusters based on the
%eigenvalues of the graph Laplacian

% Initialize
releigengaps = zeros(length(lambdas) - 2, 1);
eigengaps    = zeros(length(lambdas) - 2, 1);
max = 0;
K   = 2;

% Estimate rel eigengap
for i = 2: length(lambdas) - 1
    releigengaps(i) = (lambdas(i+1) - lambdas(i)) / lambdas(i);
    eigengaps(i) = (lambdas(i+1) - lambdas(i));
    if eigengaps(i) > max
        max = eigengaps(i);
        K = i;
    end
end


end

