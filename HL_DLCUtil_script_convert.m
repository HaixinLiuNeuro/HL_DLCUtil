%% script to read all labelled data csv file in a specified folder and convert to commom format in a new folder

%% define some parameters
clear

root_fd = 'C:\Data\DLC_datasets';

labeled_data_fd = 'C:\Data\DLC_datasets\ReachPlus';

new_labeled_data_fd = 'C:\Data\DLC_datasets\ReachPlus_NEW';

scorer = 'AS'; % to keep consistent with the model


%%

% make the new folder
if ~exist(new_labeled_data_fd,'dir')
    mkdir(new_labeled_data_fd)
end

% get all labelled file folder names
fds = dir(labeled_data_fd);
idx_keep = arrayfun(@(x) ~(strcmp(x.name,'.')||strcmp(x.name,'..'))&&x.isdir, fds);
fds = fds(idx_keep);

csv_fn = cell(length(fds),1);
file_names = cell(length(fds),1);
colnames = cell(length(fds),1);
line_3 = cell(length(fds),1);
line_1 = cell(length(fds),1);

for i_f = 1:length(fds)
    csv_fn{i_f} = dir(fullfile(labeled_data_fd,fds(i_f).name,'*.csv'));
    [Data{i_f}, file_names{i_f}, colnames{i_f}, line_3{i_f}, line_1{i_f}]=HL_DLCUtil_ReadLabeledCSV(fullfile(csv_fn{i_f}.folder, csv_fn{i_f}.name));
end

% check if the fieldnames are the same
for i_f = 1:length(Data)
    for i_j = i_f:length(Data)
        BodyPart_cmp (i_f,i_j)= isequal(fieldnames( Data{i_f}), fieldnames( Data{i_j}) );
        BodyPartSorted_cmp (i_f,i_j)= isequal(sort(fieldnames( Data{i_f})), sort(fieldnames( Data{i_j}) ));
    end    
end

%% compare the body part list
%{
figure; imagesc(BodyPart_cmp)
figure; imagesc(BodyPartSorted_cmp)
%}
% OK  ==> arrange as the first file (original format)

%% rearrange bodypart label
% use the first file as the order (initial ReachPlus body list)
BodyPart_New = fieldnames( Data{1});
Data_New = [];
for i_f = 1:length(Data)
    temp_BodyPart = fieldnames( Data{i_f});
    if isequal(temp_BodyPart, BodyPart_New)
        Data_New{i_f} = Data{i_f};
    else
        % rearrange
        for i_part = 1:length(BodyPart_New)
            Data_New{i_f}.(BodyPart_New{i_part})= Data{i_f}.(BodyPart_New{i_part});
        end
    end
end

%% writing into new csv file, using writatable 
% use AS as scorer
disp(line_1{30});
% construct colnames
colnames_New = colnames{1}(1);
for i_part = 1:length(BodyPart_New)
    colnames_New = cat(2, colnames_New, BodyPart_New(i_part), BodyPart_New(i_part));
end

for i_f = 1:length(Data)
    fprintf('Processing: %s...\n',  fds(i_f).name);
    HL_DLCUtil_WriteLabeledCSV(fullfile(new_labeled_data_fd, fds(i_f).name), 'CollectedData_AS.csv', ...
        Data_New{i_f}, file_names{i_f}, colnames_New, line_3{30}, line_1{30});

    % copy the png files to new folder as well
    [status,message,messageId] = copyfile(...
        fullfile(labeled_data_fd, fds(i_f).name,'*.png'),...
        fullfile(new_labeled_data_fd, fds(i_f).name), 'f');

    disp(status);
end

%%