function [cluster,cluster_centers] = kmeans_orth(xx, k, num_ortho, num_random)
% V(:,1:K)', K, num_ortho, num_random, label, W


p = size(xx,1);
n = size(xx,2);
total_num = num_random+num_ortho;

norm_xx  = normalize_2nd(xx);
cluster        = zeros(n,1);
cluster_centers = [];


for i=1:total_num

    %assign the center index ortho or randomly
    if (i <= num_ortho)
        center_index = gen_orthogonal_centers(norm_xx(1:k,:));
    else
        is_ran_center      = zeros(1,n+1);
        is_ran_center(n+1) = 1;
        center_index       = zeros(1,k);
        for j=1:k
            ran_index=n+1;
            while is_ran_center(ran_index)
                ran_index=floor(1+n*rand(1));
            end
            center_index(j)=ran_index;
        end
    end
    % run the kmeans on them
    kcenter    = xx(:,center_index);
    %  unnormalized
    [cluster,cluster_centers] = kmeans(xx',k,'Start',kcenter');

end