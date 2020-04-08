%% ReachPlusOneView1.0
%{
script to read all labelled data csv file in a specified folder 

each pic will be split into two views: need coor to 
labeled data will also be converted: body parts in different views will be
treated with the same object name

%}
%% define some parameters
clear

root_fd = 'C:\Data\DLC_datasets';

labeled_data_fd = 'C:\Data\DLC_datasets\ReachPlus';

new_labeled_data_fd = 'C:\Data\DLC_datasets\ReachPlusOneView';

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
BodyPart_New1 = fieldnames( Data{1});
% no need to rearrange
%{
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
%}
%% split image pics and write new csv files
% manally define the body part list:
BodyPart_New = {'LePaw'; 'LePawMF'; 'LePawWr'; 'LePawArm';  ...
                'RiPaw'; 'RiPawMF'; 'RiPawWr'; 'RiPawArm';  ...
                'Nose'; 'LipLow'; 'Whisker'; ... 
                'LeIdx'; 'LePnk'; 'RiIdx'; 'RiPnk'};
% use AS as scorer
Line1 = line_1{30}(1:31);
disp(Line1);
Line3 = line_3{30}(1:31);
disp(Line3);

% construct colnames
colnames_New = colnames{1}(1);
for i_part = 1:length(BodyPart_New)
    colnames_New = cat(2, colnames_New, BodyPart_New(i_part), BodyPart_New(i_part));
end

%% go through each folder and each pic
% read in the pic, split and rec
Offset_Front_x = 0;
Offset_Front_y = 0;

Offset_Angle_x = 800;
Offset_Angle_y = 0;

for i_f = 1:length(Data)
    fprintf('Processing: %s...\n',  fds(i_f).name);
    %% process the pic files:  labeled-data\...
    for i_pic = 1:length(file_names{i_f})
        temp_pic_fn = fullfile(labeled_data_fd, file_names{i_f}{i_pic}(14:end));
        temp_pic_data = imread(temp_pic_fn,'png');
%         figure;
%         imshow(temp_pic_data)
        [~, temp_pic_n, ~] = fileparts(temp_pic_fn);
        if i_pic ==1
        mkdir(fullfile(new_labeled_data_fd, [fds(i_f).name '_Front']));
        mkdir(fullfile(new_labeled_data_fd, [fds(i_f).name '_Angle']));
        end
        imwrite(temp_pic_data(:,1:Offset_Angle_x,:),...
            fullfile(new_labeled_data_fd, [fds(i_f).name '_Front'], [temp_pic_n '.png']));
        imwrite(temp_pic_data(:,Offset_Angle_x+1:Offset_Angle_x*2,:), ...
            fullfile(new_labeled_data_fd, [fds(i_f).name '_Angle'], [temp_pic_n '.png']));
        
        % make the file_names for each view
        temp_ind = strfind(file_names{i_f}{i_pic}, '\');
        file_names_Front{i_f}{i_pic} = ...
            [ file_names{i_f}{i_pic}(1:temp_ind(2)-1) '_Front' file_names{i_f}{i_pic}(temp_ind(2):end)];
        file_names_Angle{i_f}{i_pic} = ...
            [ file_names{i_f}{i_pic}(1:temp_ind(2)-1) '_Angle' file_names{i_f}{i_pic}(temp_ind(2):end)];
    end
    %% process the labeled data
    % hard to do automatic naming... just do manual
%     {'bodyparts','LePaw','LePaw','LePawMF','LePawMF','LePawWr','LePawWr','LePawArm','LePawArm','RiPaw','RiPaw','RiPawMF','RiPawMF','RiPawWr','RiPawWr','RiPawArm','RiPawArm','Nose','Nose','LipLow','LipLow','Whisker','Whisker','LeIdx','LeIdx','LePnk','LePnk','RiIdx','RiIdx','RiPnk','RiPnk'}
    % Front: no need to change the value
    Data_Front{i_f}.LePaw   = Data{i_f}.LePawFrt;
    Data_Front{i_f}.LePawMF = Data{i_f}.LePawFrtMF;
    Data_Front{i_f}.LePawWr = Data{i_f}.LePawFrtWr;
    Data_Front{i_f}.LePawArm= Data{i_f}.LePawFrtArm ;
    Data_Front{i_f}.RiPaw   = Data{i_f}.RiPawFrt ;
    Data_Front{i_f}.RiPawMF = Data{i_f}.RiPawFrtMF ;
    Data_Front{i_f}.RiPawWr = Data{i_f}.RiPawFrtWr ;
    Data_Front{i_f}.RiPawArm= Data{i_f}.RiPawFrtArm ;
    Data_Front{i_f}.Nose    = Data{i_f}.NoseFrt ;
    Data_Front{i_f}.LipLow  = Data{i_f}.LipLowFrt ;
    Data_Front{i_f}.Whisker = Data{i_f}.WhiskerFrt ;
    Data_Front{i_f}.LeIdx   = Data{i_f}.LeIdxFrt ;
    Data_Front{i_f}.LePnk   = Data{i_f}.LePnkFrt ;
    Data_Front{i_f}.RiIdx   = Data{i_f}.RiIdxFrt ;
    Data_Front{i_f}.RiPnk   = Data{i_f}.RiPnkFrt ;
    % angle: need to subtract the offset
    Data_Angle{i_f}.LePaw   = Data{i_f}.LePawSid;
    Data_Angle{i_f}.LePawMF = Data{i_f}.LePawSidMF;
    Data_Angle{i_f}.LePawWr = Data{i_f}.LePawSidWr;
    Data_Angle{i_f}.LePawArm= Data{i_f}.LePawSidArm ;
    Data_Angle{i_f}.RiPaw   = Data{i_f}.RiPawSid ;
    Data_Angle{i_f}.RiPawMF = Data{i_f}.RiPawSidMF ;
    Data_Angle{i_f}.RiPawWr = Data{i_f}.RiPawSidWr ;
    Data_Angle{i_f}.RiPawArm= Data{i_f}.RiPawSidArm ;
    Data_Angle{i_f}.Nose    = Data{i_f}.NoseSid ;
    Data_Angle{i_f}.LipLow  = Data{i_f}.LipLowSid ;
    Data_Angle{i_f}.Whisker = Data{i_f}.WhiskerSid ;
    Data_Angle{i_f}.LeIdx   = Data{i_f}.LeIdxSid ;
    Data_Angle{i_f}.LePnk   = Data{i_f}.LePnkSid ;
    Data_Angle{i_f}.RiIdx   = Data{i_f}.RiIdxSid ;
    Data_Angle{i_f}.RiPnk   = Data{i_f}.RiPnkSid ;
    
    temp_fieldnames = fieldnames(Data_Angle{i_f});
    for ii = 1:length(temp_fieldnames)
        if Data_Angle{i_f}.(temp_fieldnames{ii}).x ~= 0
        Data_Angle{i_f}.(temp_fieldnames{ii}).x = Data_Angle{i_f}.(temp_fieldnames{ii}).x - Offset_Angle_x;
        end
    end
    %% write to csv: Front and Angle
    HL_DLCUtil_WriteLabeledCSV(fullfile(new_labeled_data_fd, [fds(i_f).name '_Front']), ...
        'CollectedData_AS.csv', ...
        Data_Front{i_f}, file_names_Front{i_f}, colnames_New, Line3, Line1);
    HL_DLCUtil_WriteLabeledCSV(fullfile(new_labeled_data_fd, [fds(i_f).name '_Angle']), ...
        'CollectedData_AS.csv', ...
        Data_Angle{i_f}, file_names_Angle{i_f}, colnames_New, Line3, Line1);

end

return
%% debug: DLC cann't read the csv file 
HL_DLCUtil_ReadLabeledCSV(fullfile(new_labeled_data_fd, [fds(1).name '_Angle'], 'CollectedData_AS.csv'));
% change \r\n to \n solved it
% OK