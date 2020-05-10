function HL_DLCUtil_combineTwoViewsCSV(FrontCSV, AngleCSV, Offset_Front, Offset_Angle, save_fd)


% Offset_Front: [X Y]; Offset_Front = [100 100]; Offset_Angle = [900 90];
%{
FrontCSV = 'D:\DA_acute_movies\HL110_200124_LowProb_BeforeDeepCut_resnet50_ReachPlusOneViewFront1.0Apr11shuffle1_850000.csv';
AngleCSV = 'D:\DA_acute_movies\HL110_200124_LowProb_BeforeDeepCut_resnet50_ReachPlusOneViewAngle1.0Apr11shuffle1_850000.csv';
%}
%% read in data: since header should the same, just use one, then concatenate all body parts
% do it line by line to write and remove the first column of the angle file

%% generate file name to write in
[CSV_fd, CSV_file]=fileparts(FrontCSV);
temp_idx = strfind(CSV_file, 'Front');
if isempty(temp_idx)
    error('Front CSV file does not have Front in the name, not compatiable now');
end
save_fn = [CSV_file(1:temp_idx-1) 'Separate' CSV_file(temp_idx+4:end) '_cmb.csv'];
if nargin < 5
    save_fd = CSV_fd; % save to the folder of data
end
dest_cvs_fn_full = fullfile(save_fd, save_fn);
%%
fid = fopen( dest_cvs_fn_full, 'w' );
%{
% old 
% first 3 lines
for i_c = 1:(length(Line1)-1)
    fprintf(fid, '%s,', Line1{i_c});
end
%}
fh_Front = fopen(FrontCSV);
fh_Angle = fopen(AngleCSV);
line1_Front =fgetl(fh_Front); % 1st line scorer, 
line1_Angle =fgetl(fh_Angle); % 
% if isequal(line1_Front, line1_Angle) % different model not the same
fprintf(fid, '%s\n', line1_Front);

colnames_Front = fgetl(fh_Front); %extract column names, but keep as is strsplit(fgetl(fh_Front),',');
colnames_Angle = fgetl(fh_Angle); %extract column names
if ~isequal(colnames_Front, colnames_Angle)
   error('BodyPart names are not the same of the two csv files') ;
end
temp_idx = strfind(colnames_Angle,',');
colnames_Front_edit = '';
colnames_Angle_edit = '';
for ii = 1:(length(temp_idx)-1)
    colnames_Front_edit = cat(2, colnames_Front_edit, ...
    [',Frt' colnames_Front(temp_idx(ii)+1:temp_idx(ii+1)-1)]);

colnames_Angle_edit = cat(2, colnames_Angle_edit, ...
    [',Agl' colnames_Angle(temp_idx(ii)+1:temp_idx(ii+1)-1)]);
end
%{
 fprintf('%s%s,%s\n', colnames_Front(1:temp_idx(1)-1), colnames_Front_edit,colnames_Angle_edit);
%}
fprintf(fid, '%s%s,%s\n', colnames_Front(1:temp_idx(1)-1), colnames_Front_edit,colnames_Angle_edit);

% line 3
temp_line_Front = fgetl(fh_Front);
temp_line_Angle = fgetl(fh_Angle);
temp_idx = strfind(temp_line_Angle,',');
temp_line_Angle_edit = temp_line_Angle(temp_idx(1):end);
fprintf(fid, '%s,%s\n', temp_line_Front,temp_line_Angle_edit);

%% next line on are data

M_Front = csvread(FrontCSV, 3,0); % read in all the numbers
M_Angle = csvread(AngleCSV, 3,0); % read in all the numbers
M_combine = cat(2,M_Front, M_Angle(:,2:end)); % combine Front then Angle view data
% 1 frame #, 2 - x, 3-y, 4-likelihood
idx_Front_x = 2:3:size(M_Front,2);
idx_Front_y = 3:3:size(M_Front,2);
idx_Angle_x = idx_Front_x+size(M_Front,2)-1;% 
idx_Angle_y = idx_Front_y+size(M_Front,2)-1;% 

M_combine(:,idx_Front_x) = M_combine(:,idx_Front_x) + Offset_Front(1);
M_combine(:,idx_Front_y) = M_combine(:,idx_Front_y) + Offset_Front(2);
M_combine(:,idx_Angle_x) = M_combine(:,idx_Angle_x) + Offset_Angle(1);
M_combine(:,idx_Angle_y) = M_combine(:,idx_Angle_y) + Offset_Angle(2);

% writematrix(M_combine,dest_cvs_fn_full,'WriteMode','append'); % this
% function needs 2019a and above
[Fr_n, col_n] = size(M_combine);
for i_f = 1:Fr_n
    for i_p = 1:(col_n-1)
        fprintf(fid, '%f,', M_combine(i_f,i_p));
    end
    fprintf(fid, '%f\n', M_combine(i_f,col_n));

end
fclose('all');
disp('Done!');
%%
%{
temp_line_Front = fgetl(fh_Front);
temp_line_Angle = fgetl(fh_Angle);
    
while any(temp_line_Front ~= -1) && any(temp_line_Angle ~=-1) % not the end of file
    %{
    disp(temp_line_Front);
    disp(temp_line_Angle);
    %}
    
    temp_line_Front = '';
    temp_line_Angle = '';
    for ii = 1:(length(temp_idx)-1)
        temp_line_Front = cat(2, temp_line_Front, ...
            [',Frt' colnames_Front(temp_idx(ii)+1:temp_idx(ii+1)-1)]);
        
        temp_line_Angle = cat(2, temp_line_Angle, ...
            [',Agl' colnames_Angle(temp_idx(ii)+1:temp_idx(ii+1)-1)]);
    end
    %{
 fprintf('%s%s,%s\n', colnames_Front(1:temp_idx(1)-1), temp_line_Front,temp_line_Angle);
    %}
    fprintf(fid, '%s%s,%s\n', colnames_Front(1:temp_idx(1)-1), temp_line_Front,temp_line_Angle);
    
end
% close all open files
%}
% M_Front = csvread(FrontCSV, 3,0); % read in all the numbers
% M_Angle = csvread(AngleCSV, 3,0); % read in all the numbers
% M_combine = cat(2,M_Front, M_Angle(:,2:end)); % combine Front then Angle view data





%{
% old
% Frame_ind = M(:,1)+1; % starting from 0 in python
for i_part = 1:(length(colnames)-1)/3 % skip the first column which is frame number
    %set ori
    Data.(colnames{3*(i_part-1)+1+1}).x = M(:,1+1+3*(i_part-1));
    Data.(colnames{3*(i_part-1)+1+1}).y = M(:,1+2+3*(i_part-1));
    Data.(colnames{3*(i_part-1)+1+1}).Likelihood = M(:,1+3+3*(i_part-1));
end
%}