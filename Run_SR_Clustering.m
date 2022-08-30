% Source code for the MedGU 22 submission
% 
% "A spectral approach for the clustering of source rocks."
% by V. I. Makri, D. Pasadakis
% 
% dimosthenis.pasadakis@usi.ch

%%
clear all;
close all;
warning('off')

% Create a color palette for the plots (9 colors)
C=[ 0         0              1.0000
    0         0.4980         0
    1.0000    0.6000         0
    0.6353    0.0784         0.1843
    0.1490    0.8588         0.5059
    0.0000    0.000          0  
    0.4000    0.2000         1.0000
    1.0000    0.2000         1.0000
    0.4000    1.0000         1.0000 
    1.0000    0.6000         0.6000
    ];

Names = {'nC15', 'Ph', 'nC23', 'nC28', 'nC33'};

%% Initialization

% add the necessary paths
addpaths_Petrol;

% flags and sizes for plotting
plot_map    = 1;
fontsize    = 28;
marker_size = 50;

% flags for normalizing
norm_corr     = 0; % normalize for correlation matrix instead of covariance
% Normalizations
% 1: Make euclidean row-norm = 1
% 2: Divide ewise by the sum of the row (1-norm normalization)
normalization = 2;

prompt    = 'Select name of dataset at Input_Data/:';
data_name = input(prompt,'s');

fprintf('================================== \n');
fprintf('Petroleum spectral clustering based on modularity \n');
fprintf('================================== \n');


[Data_Ion,Locations_Ion,labels_Ion,labels_Ion_str,K_Ion,Method_for_NumClust] = ...
    Load_Data(data_name);

[Y,p,n] = Normalize_Data(Data_Ion, normalization, norm_corr);


% scatter plot of these locations
if plot_map == 1
    figure('Renderer', 'painters', 'Position', [0 0 2.4 1.8]*250);
    geoscatter(Locations_Ion(:,1),Locations_Ion(:,2),marker_size,'r*');
    title('Samples'' Locations');
    geobasemap colorterrain
    set(gca,'fontsize',fontsize);
    saveas(gcf,'Results/Source_Rock_Locations','pdf');
end


%% Build the graph from the data

% k nearest neighbours for connectivity
kNN = 10;
[G] = kNNConGraph(Y,kNN);     

% Gaussian similarity for weights
[S]  = similarityfunc(Y,kNN); 

% Build the adjacency matrix (connectivity + weights)
W = G.*S;
%
if plot_map == 1
    figure;
    spy(W);
    title('Adjacency matrix of the data');
    saveas(gcf,'Results/Adjacency_Matrix','pdf');
end

% Check if the graph is connected. This is controlled
% by the kNN variable 
Conn_W = isConnected(W);
fprintf('Connected graph:%d \n',Conn_W);

%% Normalized spectral Clustering

% Create graph Laplacian
normalized   = 1; % select if the Laplacian is normalized or not
[L,Diag,vw]  = CreateLapl(W,normalized);

% Find all the eigenvalues of the graph Laplacian
[Vec,lambda] = eig(full(L));
lambdas      = diag(lambda);

if normalized == 1
    % Transform eigs of L_sym to those of L_rw:
    % Multiply the entries of the eigenvectors by sqrt(d).
    % Afterwards renorm them again to have norm 1.
    for i=1:length(lambdas)
        Vec(:,i) = Vec(:,i)./sqrt(vw);
        Vec(:,i) = Vec(:,i)/norm(Vec(:,i));
    end
end

% [K_Nat, releigengaps, eigengaps] = findIndexBigEigengap(lambdas);
% fprintf('=========================\n');
% fprintf('Natural number of clusters: %d, with kNN: %d\n',K_Nat,kNN);
% fprintf('=========================\n');

% Initialize empty vectors for the results
Mod_all_spec    = zeros(1,K_Ion);
Mod_all_spec(1) = 0;

Mod_all_kmeans    = zeros(1,K_Ion);
Mod_all_kmeans(1) = 0;

Mod_all_hier    = zeros(1,K_Ion);
Mod_all_hier(1) = 0;


% Set up the distance matrix for hierarchical clustering
Dist   = pdist(Y);
Dist_M = squareform(Dist);
Tr     = PHA_Clustering(Dist_M);

for nclust = 2:K_Ion
    % Select the number of relevant eigenvectors
    Eigevecs = Vec(:,1:nclust);
    
    % run kmeans orthogonal on the eigenvectors
    xx         = Eigevecs';
    num_ortho  = 20;
    num_random = 10;
    [~,Com_spec,~] = kmeans_spec(xx, nclust, num_ortho, num_random, W, normalized);
    
    % kmeans orthogonal clustering         
    [Com_kmeans,~] = kmeans_orth(Y', nclust, num_ortho, num_random);
    % hierarchical clustering
    Com_hier = cluster(Tr,'maxclust',nclust);

    % Metrics Evaluation
    [Metrics_Spec.RCut,Metrics_Spec.RCCut,Metrics_Spec.Modul,Metrics_Spec.Dunn,Metrics_Spec.NCut,Metrics_Spec.NCCut,Metrics_Spec.edgecut]...
        = Internal_Metrics_Evaluation(Com_spec,W);

    [Metrics_kmeans.RCut,Metrics_kmeans.RCCut,Metrics_kmeans.Modul,Metrics_kmeans.Dunn,Metrics_kmeans.NCut,Metrics_kmeans.NCCut,Metrics_kmeans.edgecut]...
        = Internal_Metrics_Evaluation(Com_kmeans,W);

    [Metrics_hier.RCut,Metrics_hier.RCCut,Metrics_hier.Modul,Metrics_hier.Dunn,Metrics_hier.NCut,Metrics_hier.NCCut,Metrics_hier.edgecut]...
        = Internal_Metrics_Evaluation(Com_hier,W);

    Mod_all_kmeans(nclust)  = Metrics_kmeans.Modul;
    Mod_all_spec(nclust) = Metrics_Spec.Modul;
    Mod_all_hier(nclust) = Metrics_hier.Modul;
end

% Final clustering at the optimal number of clusters K_final
% This is done at the maximum modularity configuration
[Max_mod,K_final] = max(Mod_all_spec);

fprintf('=========================\n');
fprintf('The max modularity achieved: %f, with kNN: %d and Clusters:%d \n',Max_mod,kNN,K_final);
fprintf('=========================\n');

if plot_map == 1
    figure('Renderer', 'painters', 'Position', [0 0 1.8 1.4]*250);
    pl_spec = plot(Mod_all_spec,'color',C(1,:),'linewidth',2); % plot all spectral modularities
    [max_y, max_x] = max(Mod_all_spec);
    hold on;
    pl_maxspec = plot(max_x,max_y,'color',C(1,:),'Marker','o','MarkerSize',8,... % plot max modularity by spectral
        'MarkerFaceColor',C(1,:));hold on;    
    pl_kmeans = plot(Mod_all_kmeans,'color',C(2,:),'linewidth',2); hold on; % plot all kmeans modularities 
    pl_hier = plot(Mod_all_hier,'color',C(3,:),'linewidth',2); % plot all hierarchical modularities
        set(gca,'fontsize',fontsize);
    set(gca,'TickLabelInterpreter','latex');
    xlabel('Number of clusters $k$',  'Interpreter', 'latex');
    ylabel('Modularity $\mathbf{Q}$', 'Interpreter', 'latex');    
    legend([pl_spec, pl_kmeans, pl_hier],{'spectral', 'kmeans','HCA'},'Box','off','interpreter','latex','location','southeast');
    tightfig;
    filename = 'Modularity_plot';
    saveas(gcf,strcat('Results/',filename),'pdf')
end

% Select the number of relevant eigenvectors
Eigevecs = Vec(:,1:K_final);

% Run kmeans orthogonal on the eigenvectors
xx         = Eigevecs';
num_ortho  = 20;
num_random = 10;
[Cut,Com_spec,cluster_centers] = kmeans_spec(xx, K_final, num_ortho, num_random, W, normalized);

% Metrics Evaluation
[Metrics_Spec.RCut,Metrics_Spec.RCCut,Metrics_Spec.Modul,Metrics_Spec.Dunn,Metrics_Spec.NCut,Metrics_Spec.NCCut]...
    = Internal_Metrics_Evaluation(Com_spec,W);

if plot_map == 1    
    for i = 1:K_final
        figure;
        [index_curr_clust,~] = find(Com_spec==i);
        Y_curr = Y(index_curr_clust,:)';
        plot(Y_curr,'LineWidth',2,'Color',C(i,:));
        xlim([0 size(Y,2)])
        set(gca,'fontsize',fontsize);
        set(gca,'xtick',[1:5:23],'xticklabel',Names);
        set(gca,'TickLabelInterpreter','latex');
%         xlabel(['Cluster id: ',num2str(i)]);
        filename = strcat('ClusterNum_',num2str(i));
        tightfig;
        saveas(gcf,strcat('Results/',filename),'pdf');
    end    
end

% Save the clustering assignments
save('Results/Clustering_assignments.txt', 'Com_spec', '-ASCII');