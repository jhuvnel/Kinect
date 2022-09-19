
%
% calculating the total distance traveled by a joint as recorded by the
% kinect

clear
clc

file_path = 'C:\Users\Kim Sookoo\OneDrive - Johns Hopkins\VNEL1DRV\_Chow\Kinect Project\Test Files\20181120-154922MVI006_MR_test3_body1_joints.txt';

[jointData, timeVec, timeInts] = getJointData(file_path);

% target joints: head, shoulders, hips, knees, ankles
% spineBase = hipCenter, spineShoulder = shoulderCenter

joint_idxs = [4; 5; 21; 9; 13; 1; 17; 14; 18; 15; 19];

joint_info = {'head';'shoulderLeft'; 'shoulderCenter'; 'shoulderRight';...
    'hipLeft'; 'hipCenter'; 'hipRight'; 'kneeLeft'; 'kneeRight'; ...
    'ankleLeft'; 'ankleRight'};

for i = 1:length(joint_idxs)
    joint_info{i,2} = jointData(:,:,joint_idxs(i));
end

%% visualize joint sway

% 2D view
% figure(1)
% for plot_idx = 1:11
%     subplot(3,4,plot_idx)
%     plot3(joint_info{plot_idx,2}(1,:), joint_info{plot_idx,2}(3,:), ... 
%         joint_info{plot_idx,2}(2,:))
%     xlabel 'x (ML)'
%     ylabel 'y (AP)'
%     zlabel 'z'
%     title(joint_info{plot_idx,1})
%     view(2)
% %     axis([-0.5 0 2.5 inf])
% end
% 
% % 3D view
% figure(2)
% for plot_idx = 1:11
%     subplot(3,4,plot_idx)
%     plot3(joint_info{plot_idx,2}(1,:), joint_info{plot_idx,2}(3,:), ... 
%         joint_info{plot_idx,2}(2,:))
%     xlabel 'x (ML)'
%     ylabel 'y (AP)'
%     zlabel 'z'
%     title(joint_info{plot_idx,1})
% %     axis([-0.5 0 2.5 inf])
% end

%% truncating beginning and end (need to find definite start and end times)

totalTime = (timeVec(end) - timeVec(1))*0.001;
joint_info_truncated = joint_info(:,1);


for joint_idx = 1:length(joint_idxs)
    trunc_idx = 1;

    for time_idx = 1:length(timeVec)
    
        timeElapsed = (timeVec(time_idx) - timeVec(1))*0.001;
    
        if timeElapsed >= 10 && timeElapsed <= totalTime-10
            joint_info_truncated{joint_idx,2}(:,trunc_idx) = joint_info{joint_idx,2}(:,time_idx);
            timeInts_truncated(trunc_idx) = timeInts(time_idx-1);
            trunc_idx = trunc_idx+1;
        end
    end
end

%% visualize truncated joint sway

% 2D view
figure(3)
for plot_idx = 1:11
    subplot(3,4,plot_idx)
    plot3(joint_info_truncated{plot_idx,2}(1,:), joint_info_truncated{plot_idx,2}(3,:), ... 
        joint_info_truncated{plot_idx,2}(2,:))
    xlabel 'x (ML)'
    ylabel 'y (AP)'
    zlabel 'z'
    title(joint_info_truncated{plot_idx,1})
    view(2)
%     axis([-0.5 0 2.5 inf])
end

% 3D view
figure(4)
for plot_idx = 1:11
    subplot(3,4,plot_idx)
    plot3(joint_info_truncated{plot_idx,2}(1,:), joint_info_truncated{plot_idx,2}(3,:), ... 
        joint_info_truncated{plot_idx,2}(2,:))
    xlabel 'x (ML)'
    ylabel 'y (AP)'
    zlabel 'z'
    title(joint_info_truncated{plot_idx,1})
%     axis([-0.5 0 2.5 inf])
end    

%% visualize truncated data over time

% figure(5)
% for m=1:length(joint_info_truncated{1,2})
%     for i = 1:length(joint_info_truncated)     
%          
%             jointCoordinates(i,:) = joint_info_truncated{i,2}(:,m);
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
%  pause(timeInts_truncated(m)*0.001);
% end

%% find total sway path length for each joint

for joint_idx = 1:length(joint_info_truncated)
   
    for col_idx = 2:length(joint_info_truncated{joint_idx,2})

        currentJoint = joint_info_truncated{joint_idx,2};

        segmentLength = sqrt((currentJoint(1,col_idx)-currentJoint(1,col_idx-1))^2 + ...
       (currentJoint(2,col_idx)-currentJoint(2,col_idx-1))^2 + ...
       (currentJoint(3,col_idx)-currentJoint(3,col_idx-1))^2);
        
        allSegments(col_idx - 1) = segmentLength;

    end

    joint_info_truncated{joint_idx,3} = sum(allSegments);

end