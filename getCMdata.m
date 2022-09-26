function fullbody_cm = getCMdata(jointData, mass, center_opt)

% Target joints: head, neck (maybe spine shoulder), spine base, shoulders,
% elbows, wrists, hand tips, hips, knees, ankles, feet

joint_idxs = [4; 3; 1; 5; 6; 9; 10; 7; 11; 22; 24; 13;  17; 14; 18; 15; ...
    19; 16; 20; 21];

for i = 1:length(joint_idxs)
    joint_info{i,1} = jointData(:,:,joint_idxs(i));
end

for frame = 1:length(joint_info{1, 1})
    
    jointCoordinates =[];

    for i = 1:length(joint_info)     
         
            jointCoordinates(i,:) = joint_info{i,1}(:,frame);
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

 % MVI003: m = 61.37 kg
 % MVI006: m = 100 kg

 segment_mass = [0.0668; 0.4257; 0.0255; 0.0255; 0.0138; 0.0138 ;0.0056;...
     0.0056; 0.1478; 0.1478; 0.0481; 0.0481; 0.0129; 0.0129];

 for segmentCM_idx = 1:14
       
     cm_x(segmentCM_idx) = ((segment_mass(segmentCM_idx)*mass)*segment_cm{segmentCM_idx,2}(1))/mass;

     cm_y(segmentCM_idx) = ((segment_mass(segmentCM_idx)*mass)*segment_cm{segmentCM_idx,2}(2))/mass;

     cm_z(segmentCM_idx) = ((segment_mass(segmentCM_idx)*mass)*segment_cm{segmentCM_idx,2}(3))/mass;
 end

fullbody_cm_uncentered(frame,:) = [sum(cm_x),sum(cm_y),sum(cm_z)];

end

switch nargin

    case 2
        fullbody_cm = fullbody_cm_uncentered;

    case 3

        center_opt = lower(center_opt); % make case insensitive

        if center_opt == "median"
            m1 = median(fullbody_cm_uncentered(:,1));
            m2 = median(fullbody_cm_uncentered(:,2));
            m3 = median(fullbody_cm_uncentered(:,3));
            
            ml_centered_all = fullbody_cm_uncentered(:,1)-m1; 
            ap_centered_all = fullbody_cm_uncentered(:,2)-m2;
            vert_centered_all = fullbody_cm_uncentered(:,3)-m3;
    
            fullbody_cm = [ml_centered_all, ap_centered_all, ... 
                vert_centered_all];

        elseif center_opt == "mean"
            m1 = mean(fullbody_cm_uncentered(:,1));
            m2 = mean(fullbody_cm_uncentered(:,2));
            m3 = mean(fullbody_cm_uncentered(:,3));
            
            ml_centered_all = fullbody_cm_uncentered(:,1)-m1; 
            ap_centered_all = fullbody_cm_uncentered(:,2)-m2;
            vert_centered_all = fullbody_cm_uncentered(:,3)-m3;
    
            fullbody_cm = [ml_centered_all, ap_centered_all, ... 
                vert_centered_all];

        else
           fullbody_cm = 'not a valid centering option, please enter mean or median'

        end
end

end