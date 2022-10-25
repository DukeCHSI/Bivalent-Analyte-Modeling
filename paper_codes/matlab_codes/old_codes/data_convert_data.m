clear all; close all; clc;

% RU_table = readtable('RU.csv');
% Time_table = readtable('Time.csv');

% %% For old data
% temp = [9,10,11,12,13];
% 
% keep_cols = [];
% for i=1:6
%     keep_cols = [keep_cols, temp+(i-1)*13];
% end
% 
% RU = RU_table(:,keep_cols);
% Time = Time_table(:,keep_cols);
% 
% for i=1:6
%     name = strcat("data/dataset",num2str(i));
%     vec = (i-1)*5 + [1,2,3,4,5];
%     dataset = {Time(:,vec), RU(:,vec)};
%     %RU(1,vec)
%     save(name, 'dataset')
% end

%% For new data
RU = readtable('RU_new.csv');
Time = readtable('Time_new.csv');

for i=1:14
   name = strcat("data_new/dataset",num2str(i)); 
   vec = (i-1)*5 + [1,2,3,4,5];
   dataset = {Time(:,vec), RU(:,vec)};
   save(name, 'dataset')
end
