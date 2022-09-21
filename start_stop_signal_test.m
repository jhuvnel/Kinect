% script for testing methods of indicating the start and stop of trials

%% load data

clear
clc

% replace with test files
file_path = 'C:\Users\Kim Sookoo\OneDrive - Johns Hopkins\VNEL1DRV\_Chow\Kinect Project\Test Files\20181120-154922MVI006_MR_test3_body2_joints.txt';

[jointData, timeVec_all, timeInts_all] = getJointData(file_path);

% Target joints: hand tips++

joint_idxs = [22; 24];

joint_info_all = {'handtipLeft';'handtipRight'};

for i = 1:length(joint_idxs)
    joint_info_all{i,2} = jointData(:,:,joint_idxs(i));
end

%% vizualize joint path(s)

plot(timeVec_all*0.001, joint_info_all{1,2}(2,:)); % should show up and down movement of the left hand
hold on
plot(timeVec_all*0.001, joint_info_all{2,2}(2,:));
xlabel('Time (s)')
ylabel('Vertical position')
legend 'Left Hand' 'Right Hand'