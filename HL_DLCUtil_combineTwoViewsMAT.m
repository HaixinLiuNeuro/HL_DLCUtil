function [data]=HL_DLCUtil_combineTwoViewsMAT(FrontMAT, AngleMAT, save_fd)

%{
FrontMAT = 'D:\DA_acute_movies\HL110_200114_CStim_FPstr_resnet50_ReachPlusOneViewFront1.0Apr11shuffle1_850000.mat';
AngleMAT = 'D:\DA_acute_movies\HL110_200114_CStim_FPstr_resnet50_ReachPlusOneViewAngle1.0Apr11shuffle1_850000.mat';
field names
    {'Corrected_frame_ind'}
    {'Ori_frame_ind'      }
    {'Corrected'          }
    {'Ori'                }
    {'idx_bad_trial'      }
    {'fr_idx_add2deeplab' }
    {'offset_x'           }
    {'offset_y'           }
    {'csv_fn'             }
    {'movie_fn'           }
    {'curr_trial'         }
%}
%% get file name to save to
[MAT_fd, MAT_file]=fileparts(FrontMAT);
temp_idx = strfind(MAT_file, 'Front');
if isempty(temp_idx)
    error('Front MAT file does not have Front in the name, not compatiable now');
end
save_fn = [MAT_file(1:temp_idx-1) 'Separate' MAT_file(temp_idx+4:end) '_cmb.mat'];
if nargin < 3
    save_fd = MAT_fd; % save to the folder of data
end
%% load data
data_Front = load(FrontMAT);
data_Angle = load(AngleMAT);

%%
% check if both having same structures fields
if ~isequal(fieldnames(data_Front), fieldnames(data_Angle))
   error('two MAT files have non-matching fields') 
end

if isequal( data_Front.Corrected_frame_ind, data_Angle.Corrected_frame_ind)
    data.Corrected_frame_ind = data_Front.Corrected_frame_ind;
else
    error('Frame index NOT matching') ;
end

if isequal( data_Front.Ori_frame_ind, data_Angle.Ori_frame_ind)
    data.Ori_frame_ind = data_Front.Ori_frame_ind;
else
    error('Frame index NOT matching') ;
end

%     {'Corrected'          }, correct for offset and Ori
%     {'Ori'                }
% data_Front.Corrected.LeIdx.x, y Likelihood , 
bodypartlist = fieldnames(data_Front.Corrected);
for i_b = 1:length(bodypartlist)
    data.Corrected.(['Frt' bodypartlist{i_b}]).x = ...
        data_Front.Corrected.(bodypartlist{i_b}).x + data_Front.offset_x;
    data.Corrected.(['Frt' bodypartlist{i_b}]).y = ...
        data_Front.Corrected.(bodypartlist{i_b}).y + data_Front.offset_y;
    data.Corrected.(['Frt' bodypartlist{i_b}]).Likelihood = ...
        data_Front.Corrected.(bodypartlist{i_b}).Likelihood;

    data.Corrected.(['Agl' bodypartlist{i_b}]).x = ...
        data_Angle.Corrected.(bodypartlist{i_b}).x + data_Angle.offset_x;
    data.Corrected.(['Agl' bodypartlist{i_b}]).y = ...
        data_Angle.Corrected.(bodypartlist{i_b}).y + data_Angle.offset_y;
    data.Corrected.(['Agl' bodypartlist{i_b}]).Likelihood = ...
        data_Angle.Corrected.(bodypartlist{i_b}).Likelihood;

    data.Ori.(['Frt' bodypartlist{i_b}]).x = ...
        data_Front.Ori.(bodypartlist{i_b}).x + data_Front.offset_x;
    data.Ori.(['Frt' bodypartlist{i_b}]).y = ...
        data_Front.Ori.(bodypartlist{i_b}).y + data_Front.offset_y;
    data.Ori.(['Frt' bodypartlist{i_b}]).Likelihood = ...
        data_Front.Ori.(bodypartlist{i_b}).Likelihood;

    data.Ori.(['Agl' bodypartlist{i_b}]).x = ...
        data_Angle.Ori.(bodypartlist{i_b}).x + data_Angle.offset_x;
    data.Ori.(['Agl' bodypartlist{i_b}]).y = ...
        data_Angle.Ori.(bodypartlist{i_b}).y + data_Angle.offset_y;
    data.Ori.(['Agl' bodypartlist{i_b}]).Likelihood = ...
        data_Angle.Ori.(bodypartlist{i_b}).Likelihood;
    
end


%     {'idx_bad_trial'      }
data.idx_bad_trial = union(data_Front.idx_bad_trial, data_Angle.idx_bad_trial);

%     {'fr_idx_add2deeplab' }
data.fr_idx_add2deeplab = union(data_Front.fr_idx_add2deeplab, data_Angle.fr_idx_add2deeplab);

%     {'offset_x'           }%     {'offset_y'           }
data.offset_x = 0; 
data.offset_y = 0;

%     {'csv_fn'             }
data.csv_fn = cat(1,{data_Front.csv_fn}, {data_Angle.csv_fn});

%     {'movie_fn'           }
if isequal( data_Front.movie_fn, data_Angle.movie_fn)
    data.movie_fn = data_Front.movie_fn;
else
    error('movie file names NOT matching') ;
end

%     {'curr_trial'         }
data.curr_trial = 1; % reset

%% save data using front file name

save(fullfile(save_fd,save_fn), '-struct','data');
fprintf('saved to:\n%s\n', fullfile(save_fd,save_fn));
