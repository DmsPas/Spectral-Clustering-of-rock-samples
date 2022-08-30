%  Scrript to load the Ionian data and read labels, locations, data
function [Data,Locations,labels,labels_string,K,Method_for_NumClust] = Load_Data(data_name) 

% load the table
Table_GR  = readtable(data_name);

% read locations and data
Locations = Table_GR{1:end, 8:9};
% sub_samples = 34;
Data      = Table_GR{1:end, 12:end};

if strcmp(dataset,"Excel_Matlab") == 1
    % Select only entries with S2 > 0.1
    [a,b]        = find(Data(:,2)>0.1);
    Data    = Data(a,:);
    Locations = Locations(a,:);
    Table_GR     = Table_GR{a,:};
end

% [n,m] = size(Table_GR);
% 
% K = round(n/5/10)*10;
% labels_based_on = 2;
% labels_string = Table_GR(1:end,labels_based_on);
% labels = findgroups(labels_string);
% labels_string = table2array(unique(labels_string));    
% fprintf('@@@@@@@@@@@@ \n');
% fprintf('Searching max modularity within %d clusters \n', K);
% fprintf('@@@@@@@@@@@@ \n');


% Use inputs
prompt = 'Select method to determine # of clusters:';
fprintf('1: Selection based on columns \n');
fprintf('2: Select num of clusters manually \n');
fprintf('3: Number of clusters based on modularity of resulting clusters \n');
Method_for_NumClust = input(prompt);



if Method_for_NumClust == 1
    prompt = 'Select column that determines # of clusters:';
    fprintf('================================== \n');
    Unique_column = input(prompt);
    fprintf('================================== \n');
    % specify the number of clusters based on the unique
    % of one column
    labels_string = Table_GR(1:end,Unique_column);
    labels = findgroups(labels_string);
    labels_string = table2array(unique(labels_string));
    K     = length((unique(labels)));
    fprintf('@@@@@@@@@@@@ \n');
    fprintf('Number of clusters: %d \n', K);
    fprintf('@@@@@@@@@@@@ \n');
elseif Method_for_NumClust == 2
    prompt = 'Select number of clusters:';
    fprintf('================================== \n');
    K = input(prompt);
    fprintf('================================== \n');
    labels_based_on = 2;
    labels_string = Table_GR(1:end,labels_based_on);
    labels = findgroups(labels_string);
    labels_string = table2array(unique(labels_string));
    fprintf('@@@@@@@@@@@@ \n');
    fprintf('Number of clusters: %d \n', K);
    fprintf('@@@@@@@@@@@@ \n');
elseif Method_for_NumClust == 3
    K = 20;
    labels_based_on = 2;
    labels_string = Table_GR(1:end,labels_based_on);
    labels = findgroups(labels_string);
    labels_string = table2array(unique(labels_string));    
    fprintf('@@@@@@@@@@@@ \n');
    fprintf('Searching max modularity within %d clusters \n', K);
    fprintf('@@@@@@@@@@@@ \n');
end





end