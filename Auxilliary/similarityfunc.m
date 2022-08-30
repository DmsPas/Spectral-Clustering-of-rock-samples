function [S] = similarityfunc(Pts,kNN)
% Create the similarity matrix S 


% Choose \sigma ~ 2*log(n)
n = length(Pts(:,1));
% sigma = 10*log(n);

% kNN = max(10,2*ceil(log(n)));
% K = .5*ceil(log(n));

% Pts = sparse(Pts);

Sigma = zeros(n,1);

fprintf('----------------------------\n');
fprintf('Gaussian similarity function\n');
fprintf('----------------------------\n');
S = squareform(pdist(Pts));

for i = 1:n
     [~,index] = sort(S(:,i));
     Sigma(i) = S(index(kNN),i);
end
Sigma_mat = repmat(Sigma,1,n);
Sigma_mat = max(Sigma_mat, Sigma_mat');
S = exp(-8*S.^2 ./ (2*Sigma_mat.^2));

end