clear
clc

% set up spreadsheet

excel_file_path = ''; % insert what you want the spreadsheet to be called

% standard name format: MVIxxx_visit#_kinect.xlsx

kinect_files = dir('C:\Users\Kim Sookoo\OneDrive - Johns Hopkins\VNEL1DRV\_Wyse Sookoo\Kinect\MVI009\MVI009_11x\formatted\*joints.txt');
% change directory as needed

kinect_files_cell = struct2cell(kinect_files)';

writematrix('File Name',excel_file_path,'Range','A1')

writecell(kinect_files_cell(:,1),excel_file_path,'Range','A2')

% pull out info that can be found automatically from file names

% edit as needed
for file_idx = 1:length(kinect_files)

    dateTime(file_idx,:) = kinect_files_cell{file_idx,1}(1:15);
    
    test{file_idx,:} = kinect_files_cell{file_idx,1}(31:41); % mr or bot
    
    if test{file_idx,:}(1:3) == '_of'
        test{file_idx,:} = kinect_files_cell{file_idx,1}(35:45);
    end
    
    bodynum = strfind(kinect_files_cell{file_idx,1},'body')+4;
    
    bodyNum(file_idx,1) = str2num(kinect_files_cell{file_idx,1}(bodynum));

end

for row_idx = 1:length(test) % get rid of extra underscores in test names
    
    if test{row_idx,1}(1) == '_'
       test{row_idx,1}(1) = [];
    end

    if test{row_idx,1}(end) == '_'
       test{row_idx,1}(end) = [];
    end

end

headings = [{'Date/Time'},{'Body'},{'Body Class'},{'Test'} ...
    {'Total Time'},{'Notes'},{'Usable'},{'Recorded Time'} ...
    {'Lower Cutoff'}, {'Upper Cutoff'}, {'Truncated Time'} ...
    {'EC'},{'Condition'}];

writecell(headings,excel_file_path,'Range','B1')
writematrix(dateTime,excel_file_path,'Range','B2')
writematrix(bodyNum,excel_file_path,'Range','C2')
writecell(test,excel_file_path,'Range','E2')

%% record total time of each file

for file_idx = 1:length(kinect_files)

    file_dir = 'C:\Users\Kim Sookoo\OneDrive - Johns Hopkins\VNEL1DRV\_Wyse Sookoo\Kinect\MVI009\MVI009_11x\formatted\';
    % edit directory as needed
    file_name = string(kinect_files_cell(file_idx,1));
    file_path = strcat(file_dir,file_name);

    [~, timeVec_all, ~] = getJointData(file_path); 

    totalTimes(file_idx,1) = (timeVec_all(end)-timeVec_all(1))*0.001;

end

    writematrix(totalTimes,excel_file_path,'Range','F2')
