function [G] = kNNConGraph(Pts,kNN)    
% Construct a k-nearest neighbors connectivity graph
% Input
% k      : # of neighbors
% Pts    : coordinate list of the sample 
% 
% Output
% G      : the kNN similarity matrix


f = waitbar(0,'1','Name','kNN graph - maxima enim, patientia virtus',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

n  = length(Pts(:,1));

fprintf('kNN similarity graph\n');
    for i = 1:n
        s = repmat(Pts(i,:),n,1);
        d = Pts - s;
%         e = diag(d*d');
        e = sum(d.^2,2);
        [val,ind] = sort(e);
        [index_remove] = find(ind == i);
        ind(index_remove) = [];
        nbrs = ind(1:kNN);
        G(i,nbrs) = 1;
        G(nbrs,i) = 1;
        waitbar(i/n,f,sprintf('%5.2f',100*i/n))
    end
    
    delete(f)
end