Da%% trying to find a way to truncate kinect data by comparing to BalanSens data

clear
clc

%% Load CM data

file_path = 'C:\Users\Kim Sookoo\OneDrive - Johns Hopkins\VNEL1DRV\_Chow\Kinect Project\Test Files\20181120-154922MVI006_MR_test3_body2_joints.txt';

[jointData, timeVec_all, timeInts_all] = getJointData(file_path);

% Target joints: head, neck (maybe spine shoulder), spine base, shoulders,
% elbows, wrists, hand tips, hips, knees, ankles, feet

joint_idxs = [4; 3; 1; 5; 6; 9; 10; 7; 11; 22; 24; 13;  17; 14; 18; 15; ...
    19; 16; 20; 21];

joint_info_all = {'head';'neck';'hipCenter';'shoulderLeft';'elbowLeft'; ...
    'shoulderRight';'elbowRight';'wristLeft';'wristRight'; 'handtipLeft';...
    'handtipRight';'hipLeft';'hipRight';'kneeLeft';'kneeRight'; ...
    'ankleLeft';'ankleRight';'footLeft';'footRight';'shoulderCenter'};

for i = 1:length(joint_idxs)
    joint_info_all{i,2} = jointData(:,:,joint_idxs(i));
end


%% center of mass calculations

for frame = 1:length(joint_info_all{1, 2})
    
    jointCoordinates =[];

    for i = 1:length(joint_info_all)     
         
            jointCoordinates(i,:) = joint_info_all{i,2}(:,frame);
    end

% calculate segmental CM locations

segment_cm = {'head';'trunk';'upperArmLeft';'upperArmRight'; ...
    'forearmLeft';'forearmRight';'handLeft';'handRight';'thighLeft'; ...
    'thighRight';'shankLeft';'shankRight';'footLeft';'footRight'};

cm_length_factor = [0.5894;0.4151;0.5754;0.5754;0.4559;0.4559;0.7474; ...
    0.7474;0.3612;0.3612;0.4416;0.4416;0.4014;0.4014];

proximal_pts = [jointCoordinates(2,:);jointCoordinates(3,:); ...
    jointCoordinates(4,:);jointCoordinates(6,:);jointCoordinates(5,:); ...
    jointCoordinates(7,:);jointCoordinates(8,:);jointCoordinates(9,:); ...
    jointCoordinates(12,:);jointCoordinates(13,:); ...
    jointCoordinates(14,:);jointCoordinates(15,:);...
    jointCoordinates(16,:);jointCoordinates(17,:);];

distal_pts = [jointCoordinates(1,:);jointCoordinates(2,:); ...
    jointCoordinates(5,:);jointCoordinates(7,:);jointCoordinates(8,:); ...
    jointCoordinates(9,:);jointCoordinates(10,:);jointCoordinates(11,:); ...
    jointCoordinates(14,:);jointCoordinates(15,:); ...
    jointCoordinates(16,:);jointCoordinates(17,:);...
    jointCoordinates(18,:);jointCoordinates(19,:);];

for segment_idx = 1:14

    segment_coordinates_x = proximal_pts(segment_idx,1) + ...
        (cm_length_factor(segment_idx)*(distal_pts(segment_idx,1) - ...
        proximal_pts(segment_idx,1)));

    segment_coordinates_z = proximal_pts(segment_idx,2) + ...
        (cm_length_factor(segment_idx)*(distal_pts(segment_idx,2) - ...
        proximal_pts(segment_idx,2)));

    segment_coordinates_y = proximal_pts(segment_idx,3) + ...
        (cm_length_factor(segment_idx)*(distal_pts(segment_idx,3) - ...
        proximal_pts(segment_idx,3)));

    segment_cm{segment_idx,2} = [segment_coordinates_x, ...
        segment_coordinates_y,segment_coordinates_z];

    % note: this changes the axis order from xzy to xyz

end

 % calculate full body CM

 m = 220/2.2; 

 % MVI003 = 135/2.2
 % MVI006 = 220/2.2

 segment_mass = [0.0668; 0.4257; 0.0255; 0.0255; 0.0138; 0.0138 ;0.0056;...
     0.0056; 0.1478; 0.1478; 0.0481; 0.0481; 0.0129; 0.0129];

 for segmentCM_idx = 1:14
       
     cm_x(segmentCM_idx) = ((segment_mass(segmentCM_idx)*m)*segment_cm{segmentCM_idx,2}(1))/m;

     cm_y(segmentCM_idx) = ((segment_mass(segmentCM_idx)*m)*segment_cm{segmentCM_idx,2}(2))/m;

     cm_z(segmentCM_idx) = ((segment_mass(segmentCM_idx)*m)*segment_cm{segmentCM_idx,2}(3))/m;
 end

fullbody_cm(frame,:) = [sum(cm_x),sum(cm_y),sum(cm_z)];

end

%% center data

m1 = median(fullbody_cm(:,1));
m2 = median(fullbody_cm(:,2));

ml_centered_all = fullbody_cm(:,1)-m1; 
ap_centered_all = fullbody_cm(:,2)-m2;

%% load BalanSens data

file_path_2 = 'C:\Users\Kim Sookoo\OneDrive - Johns Hopkins\VNEL1DRV\_Wyse Sookoo\BalanSens Data\20181120-mvi06_mr_foamEC_1a.csv';
data = readmatrix(file_path_2);

% columns = ankle angle ML, ankle angle AP, hip angle ML, hip angle AP, 
% COM sway ML (cm), COM sway AP (cm), sway velocity (cm/s)

ml_cm_sway = data(:,5);
ap_cm_sway = data(:,6);

%% sampling frequency matching

fs_k = length(fullbody_cm)/((timeVec_all(end) - timeVec_all(1))*0.001);

fs_b = size(data,1)/30;

%% compare un-truncated centered data to BalanSens limits

figure(1)

subplot(2,1,1)
plot(timeVec_all*0.001,ml_centered_all)
hold on
yline(max(ml_cm_sway/100))
yline(min(ml_cm_sway/100))
xlabel 'time (s)'
ylabel 'Centered CM ML position'

subplot(2,1,2)
plot(timeVec_all*0.001,ap_centered_all)
hold on
yline(max(ap_cm_sway/100))
yline(min(ap_cm_sway/100))
xlabel 'time (s)'
ylabel 'Centered CM AP position'

%% truncate to match balansens

totalTime = (timeVec_all(end) - timeVec_all(1))*0.001;
joint_info = joint_info_all(:,1);


for joint_idx = 1:length(joint_idxs)
    trunc_idx = 1;

    for time_idx = 1:length(timeVec_all)
    
        timeElapsed = (timeVec_all(time_idx) - timeVec_all(1))*0.001;
    
        % if  timeElapsed >=10 && timeElapsed <= totalTime-2
            joint_info{joint_idx,2}(:,trunc_idx) = joint_info_all{joint_idx,2}(:,time_idx);
            ml_centered(trunc_idx) = ml_centered_all(time_idx); 
            ap_centered(trunc_idx) = ap_centered_all(time_idx);
            timeInts(trunc_idx) = timeInts_all(time_idx);
            timeVec(trunc_idx) = timeVec_all(time_idx);
            trunc_idx = trunc_idx+1;
        % end
    end
end

figure(2)
plot(ml_cm_sway,ap_cm_sway)
hold on
plot(ml_centered.*100,ap_centered.*100)
axis([-2 2 -2 2])