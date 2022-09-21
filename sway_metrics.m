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

% figure(1)
% 
% subplot(2,1,1)
% yline(m1)
% hold on
% yline(mean(fullbody_cm(:,1)), 'r')
% legend 'median' 'mean'
% 
% subplot(2,1,2)
% yline(m2)
% hold on
% yline(mean(fullbody_cm(:,2)), 'r')
% legend 'median' 'mean'

ml_centered_all = fullbody_cm(:,1)-m1; 
ap_centered_all = fullbody_cm(:,2)-m2;

% visualize CM ML and AP sway over time

% figure(1)
% 
% subplot(2,1,1)
% plot(timeVec_all*0.001,fullbody_cm(:,1))
% xlabel 'time (s)'
% ylabel 'CM ML position'
% 
% subplot(2,1,2)
% plot(timeVec_all*0.001,fullbody_cm(:,2))
% hold on
% xlabel 'time (s)'
% ylabel 'CM AP position'
% 
% figure(2)
% plot3(timeVec_all*0.001,fullbody_cm(:,1),fullbody_cm(:,2))
% xlabel 'time'
% ylabel 'ML'
% zlabel 'AP'

%% truncate

totalTime = (timeVec_all(end) - timeVec_all(1))*0.001;
joint_info = joint_info_all(:,1);


for joint_idx = 1:length(joint_idxs)
    trunc_idx = 1;

    for time_idx = 1:length(timeVec_all)
    
        timeElapsed = (timeVec_all(time_idx) - timeVec_all(1))*0.001;
    
         if  timeElapsed >=10 && timeElapsed <= totalTime-10
            joint_info{joint_idx,2}(:,trunc_idx) = joint_info_all{joint_idx,2}(:,time_idx);
            ml_centered(trunc_idx) = ml_centered_all(time_idx); 
            ap_centered(trunc_idx) = ap_centered_all(time_idx);
            timeInts(trunc_idx) = timeInts_all(time_idx);
            timeVec(trunc_idx) = timeVec_all(time_idx);
            trunc_idx = trunc_idx+1;
         end
    end
end


%% visualize centered data

figure(3)

subplot(2,1,1)
plot(timeVec*0.001,ml_centered)
xlabel 'time (s)'
ylabel 'Centered CM ML position'

subplot(2,1,2)
plot(timeVec*0.001,ap_centered)
xlabel 'time (s)'
ylabel 'Centered CM AP position'


%% RMS

ml_rms = sqrt(mean(ml_centered.^2));
ap_rms = sqrt(mean(ap_centered.^2));

% figure(4)
% plot(ml_centered,ap_centered)
% hold on
% plot(ml_rms,ap_rms, '*')
% xlabel 'ML'
% ylabel 'AP'

%% Principal sway vector

% calculate distance from center of each xy pair

for point_idx = 1:length(ml_centered)

    magnitude(point_idx,1) = sqrt(ml_centered(point_idx)^2 + ... 
        ap_centered(point_idx)^2);

    theta(point_idx,1) = atan(ml_centered(point_idx) / ...
        ap_centered(point_idx));

end

avg_magnitude = mean(magnitude);
avg_theta = mean(theta); %radians

% resolve average vector

avg_mag_x = avg_magnitude*sin(avg_theta);
avg_mag_y = avg_magnitude*cos(avg_theta);

quiver(0,0,avg_mag_x,avg_mag_y)
hold on
plot(ml_centered,ap_centered)
