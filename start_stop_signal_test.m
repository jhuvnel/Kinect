% script for testing methods of indicating the start and stop of trials

%% load data

clear
clc

exp_table = readtable("MVI009_11x_kinect.xlsx");
file_rows = find(exp_table.BodyClass == "researcher")+1;

% only keep files classified as researcher
exp_table = exp_table(exp_table.BodyClass == "researcher", :);

threshold = -0.7;

% for
    file_idx = 64;

    file_dir = 'C:\Users\Kim Sookoo\OneDrive - Johns Hopkins\VNEL1DRV\_Wyse Sookoo\Kinect\MVI009\MVI009_11x\';
    file_name = exp_table.FileName(file_idx)
    file_path = char(strcat(file_dir,file_name));

    [jointData, timeVec_all, timeInts_all] = getJointData(file_path);
    
    % Target joints: hand tips
    
    joint_idxs = [22; 24];
    
    joint_info_all = {'handtipLeft';'handtipRight'};
    
    for i = 1:length(joint_idxs)
        joint_info_all{i,2} = jointData(:,:,joint_idxs(i));
    end
    
   %% vizualize raw and normalized joint path(s)
       
    normData = normalize(joint_info_all{1, 2}(2,:));

    plot(timeVec_all*0.001, joint_info_all{1,2}(2,:)); % should show up and down movement of the left hand
    hold on
%     plot(timeVec_all*0.001, joint_info_all{2,2}(2,:));

    plot(timeVec_all*0.001, normData);
    yline(threshold)

    xlabel('Time (s)')
    ylabel('Vertical position')
    legend 'Left Hand' 'Normalized'

%end

%% pull out truncation thresholds

prev_val = normData(1);
start_idx = 1;
end_idx = 1;

lower_cutoff_time = [];
upper_cutoff_time = [];

for i = 1:length(normData)

    if prev_val >= threshold && normData(i) < threshold

        lower_cutoff_time(start_idx) = timeVec_all(i);
        lower_cutoff_idx(start_idx) = i;
        start_idx = start_idx+1;

    end

    if prev_val <= threshold && normData(i) > threshold

        upper_cutoff_time(end_idx) = timeVec_all(i);
        upper_cutoff_idx(end_idx) = i;
        end_idx = end_idx+1;
        
    end

    prev_val = normData(i);
end

if isempty(lower_cutoff_time) == 1
        lower_cutoff_time = timeVec_all(1);
        lower_cutoff_idx(start_idx) = 1;
 end

 if isempty(upper_cutoff_time) == 1
        upper_cutoff_time = timeVec_all(end);
        upper_cutoff_idx(end_idx) = length(normData);
 end

scatter(lower_cutoff_time(1)*0.001,normData(lower_cutoff_idx(1)))
scatter(upper_cutoff_time(end)*0.001,normData(upper_cutoff_idx(end)))

lower_cutoff = (lower_cutoff_time(1)-timeVec_all(1))*0.001;
upper_cutoff = (timeVec_all(end)-upper_cutoff_time(end))*0.001;
truncatedTime = (timeVec_all(upper_cutoff_idx(end))- ...
    timeVec_all(lower_cutoff_idx(1)))*0.001;

writematrix([lower_cutoff, upper_cutoff,truncatedTime], ...
    "MVI009_11x_kinect.xlsx", 'Range','J157')
