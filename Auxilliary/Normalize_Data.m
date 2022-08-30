function [Y,p,n] = Normalize_Data(Data_Ion, normalization, norm_corr)
%% Normalizations
% 1: Make euclidean row-norm = 1
% 2: Divide ewise by the sum of the row (1-norm normalization)

% check sizes
[p,n]        = size(Data_Ion);

if normalization == 1 % max elem
    
    for i = 1:n
        Data_Ion(:,i) = Data_Ion(:,i) ./ max(1e-12,norm(Data_Ion(:,i)));
    end
        
elseif normalization == 2 % row sum
    
    Row_sum  = sum(Data_Ion,2);
    Data_Ion = Data_Ion./Row_sum;
    
else % this is no normalization
    Y = Data_Ion;
end


% Normalize for correlation matrix if norm_corr = 1
Y = Data_Ion;
if norm_corr == 1
    m  = min(Y(Y>0));
    Y  = Y + m/5;
    Y = (diag(var(Y'))^(-.5)*Y );
end
%% Covariance matrix check
C = cov(Y');
max_C = max(max(C));
fprintf('The maximum element of COV is: %f \n', max_C);

end