
% finding the center of mass from kinect points and subject's mass for a
% single frame

clear
clc

file_path = 'C:\Users\Kim Sookoo\OneDrive - Johns Hopkins\VNEL1DRV\_Chow\Kinect Project\Test Files\20170202-145901_mvi003_MR_foam_EC_body1_joints.txt';

[jointData, timeVec, timeInts] = getJointData(file_path);

% Target joints: head, neck (maybe spine shoulder), spine base, shoulders,
% elbows, wrists, hand tips, hips, knees, ankles, feet

joint_idxs = [4; 3; 1; 5; 6; 9; 10; 7; 11; 22; 24; 13;  17; 14; 18; 15; ...
    19; 16; 20; 21];

joint_info = {'head';'neck';'hipCenter';'shoulderLeft';'elbowLeft'; ...
    'shoulderRight';'elbowRight';'wristLeft';'wristRight'; 'handtipLeft';...
    'handtipRight';'hipLeft';'hipRight';'kneeLeft';'kneeRight'; ...
    'ankleLeft';'ankleRight';'footLeft';'footRight';'shoulderCenter'};

for i = 1:length(joint_idxs)
    joint_info{i,2} = jointData(:,:,joint_idxs(i));
end

%% visualize data over time

% figure(1)
% for m=1:length(joint_info{1,2})
%     for i = 1:length(joint_info)     
%          
%             jointCoordinates(i,:) = joint_info{i,2}(:,m);
%     end
% 
%      if m == 1
%         h = plot3(jointCoordinates(:,1),jointCoordinates(:,3), jointCoordinates(:,2),'o');
%         view([61.5 0])
%         axis([-1 1 0 4.5 -2 2])
%         xlabel('X');
%         ylabel('Y');
%         zlabel('Z');
%         grid on;
%     else
%         h.XData = jointCoordinates(:,1);
%         h.YData = jointCoordinates(:,3);
%         h.ZData = jointCoordinates(:,2);
%      end
%  pause(timeInts(m)*0.001);
% end

%% finding a frame where the subject is in a neutral position

% starting with this and then expanding to all data points

figure(2)

frame = 297;

jointCoordinates =[];

    for i = 1:length(joint_info)     
         
            jointCoordinates(i,:) = joint_info{i,2}(:,frame);
    end

        h = plot3(jointCoordinates(:,1),jointCoordinates(:,3), jointCoordinates(:,2),'o');
        view([61.5 0])
        axis([-1 1 0 4.5 -2 2])
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        grid on;

%% calculate segmental CM locations

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

% visualize

jointCoordinates =[];

for i = 1:length(segment_cm)     
         
            jointCoordinates(i,:) = segment_cm{i,2};
end

figure(3)
plot3(jointCoordinates(:,1),jointCoordinates(:,2), jointCoordinates(:,3),'o');
        view([61.5 0])
        axis([-1 1 0 4.5 -2 2])
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        grid on;
        hold on


 %% calculate full body CM

 m = 130/2.2; % placeholder

 segment_mass = [0.0668; 0.4257; 0.0255; 0.0255; 0.0138; 0.0138 ;0.0056;...
     0.0056; 0.1478; 0.1478; 0.0481; 0.0481; 0.0129; 0.0129];

 for segmentCM_idx = 1:14
       
     cm_x(segmentCM_idx) = ((segment_mass(segmentCM_idx)*m)*segment_cm{segmentCM_idx,2}(1))/m;

     cm_y(segmentCM_idx) = ((segment_mass(segmentCM_idx)*m)*segment_cm{segmentCM_idx,2}(2))/m;

     cm_z(segmentCM_idx) = ((segment_mass(segmentCM_idx)*m)*segment_cm{segmentCM_idx,2}(3))/m;
 end

fullbody_cm = [sum(cm_x),sum(cm_y),sum(cm_z)];

% visualize

figure(3)
plot3(fullbody_cm(1),fullbody_cm(2),fullbody_cm(3),['o','r'])
