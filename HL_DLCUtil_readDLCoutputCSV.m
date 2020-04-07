% function [Data, Frame_ind]=HL_DLCUtil_readCSV(csv_fn)
% function to read in output files from DLC analyze videos (.csv files)
%
% INPUT:
%   csv_fn: .csv file fullpath
% OUTPUT:
%   Data: -struct with subfields as the object names
%         .(part_name).x, .y, .Likelihood
%   Frame_ind: frame index of the movie/video

function [Data, Frame_ind]=HL_DLCUtil_readDLCoutputCSV(csv_fn)
Data = [];
fh = fopen(csv_fn);
fgetl(fh); % skip the first line
colnames = strsplit(fgetl(fh),','); %extract column names
fclose(fh);

M = csvread(csv_fn, 3,0); % read in all the numbers
Frame_ind = M(:,1)+1;
for i_part = 1:(length(colnames)-1)/3 % skip the first column which is frame number
    %set ori
    Data.(colnames{3*(i_part-1)+1+1}).x = M(:,1+1+3*(i_part-1));
    Data.(colnames{3*(i_part-1)+1+1}).y = M(:,1+2+3*(i_part-1));
    Data.(colnames{3*(i_part-1)+1+1}).Likelihood = M(:,1+3+3*(i_part-1));
end