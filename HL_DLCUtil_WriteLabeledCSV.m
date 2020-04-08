% HL_DLCUtil_WriteLabeledCSV(dest_fd, dest_cvs_fn, coor_data, png_fn, colnames_New, Line3, Line1)
% function to write data into labeled .csv file
% 
% INPUT:
% OUTPUT:

%{
dest_fd = fullfile(new_labeled_data_fd, fds(i_f).name);
dest_cvs_fn = 'CollectedData_AS.csv';
coor_data = Data_New{i_f};
png_fn = file_names{i_f};
Line3 = line_3{30};
Line1 = line_1{30};

% key points:
no data parts do not have space

%}
function HL_DLCUtil_WriteLabeledCSV(dest_fd, dest_cvs_fn, coor_data, png_fn, colnames_New, Line3, Line1)

if ~exist(dest_fd, 'dir')
   mkdir(dest_fd) 
end
dest_cvs_fn_full = fullfile(dest_fd,dest_cvs_fn);

%% use fprintf to write
fid = fopen( dest_cvs_fn_full, 'w' );
% first 3 lines
for i_c = 1:(length(Line1)-1)
    fprintf(fid, '%s,', Line1{i_c});
end
fprintf(fid, '%s\n', Line1{end});

for i_c = 1:(length(Line1)-1)
    fprintf(fid, '%s,', colnames_New{i_c});
end
fprintf(fid, '%s\n', colnames_New{end});

for i_c = 1:(length(Line1)-1)
    fprintf(fid, '%s,', Line3{i_c});
end

fprintf(fid, '%s', Line3{end});

% each row for each file
part_names = fieldnames(coor_data);
for i_f = 1:length(png_fn)
    % file path/name, then x y for each body part
fprintf(fid, '\r\n%s,', png_fn{i_f});
    % 
    for i_part = 1:(length(part_names)-1)
        if coor_data.(part_names{i_part}).x(i_f) == 0 % empty entry is read as 0
            fprintf(fid, ',');
        else
            fprintf(fid, '%e,', coor_data.(part_names{i_part}).x(i_f));
        end
        
        if coor_data.(part_names{i_part}).y(i_f) == 0
            fprintf(fid, ',');
        else
            fprintf(fid, '%e,', coor_data.(part_names{i_part}).y(i_f));
        end
    end
    % last entry
    if coor_data.(part_names{end}).x(i_f) == 0
        fprintf(fid, '');
    else
        fprintf(fid, '%e,', coor_data.(part_names{end}).x(i_f));
    end
    
    if coor_data.(part_names{end}).y(i_f) == 0
        fprintf(fid, '');
    else
        fprintf(fid, '%e', coor_data.(part_names{end}).y(i_f));
    end
end
fprintf(fid, '\n');

fclose( fid );
%% 
%{
% check result
[check_Data, check_file_names, check_colnames, check_line_3, check_line_1]=...
    HL_DLCUtil_ReadLabeledCSV(dest_cvs_fn_full);

isequal(check_Data , coor_data)
check_Data.LeIdxFrt.x'
coor_data.LeIdxFrt.x'
% construct the table to write into .csv -- not convinient
% T = table( Line1; colnames_New; Line3)
%}