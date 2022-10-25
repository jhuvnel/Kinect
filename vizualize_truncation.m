%% visualize truncated data over time
% use to confirm truncation cutoffs for files without hand signals

clear
clc

exp_table = readtable("MVI009_pre-act_kinect.xlsx");

% filter table
exp_table = exp_table(exp_table.BodyClass == "subject", :);



for file_idx = 3

    file_dir = 'C:\Users\Kim Sookoo\OneDrive - Johns Hopkins\VNEL1DRV\_Wyse Sookoo\Kinect\MVI009\MVI009_pre-act\';
    file_name = exp_table.FileName(file_idx)
    file_path = char(strcat(file_dir,file_name));

    lower_cutoff = exp_table.LowerCutoff(file_idx);
    upper_cutoff = exp_table.UpperCutoff(file_idx);

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
    
    totalTime = (timeVec_all(end) - timeVec_all(1))*0.001;
    joint_info = joint_info_all(:,1);
    
    
    for joint_idx = 1:length(joint_idxs)
        trunc_idx = 1;
    
        for time_idx = 1:length(timeVec_all)
        
            timeElapsed = (timeVec_all(time_idx) - timeVec_all(1))*0.001;
        
            if timeElapsed >= lower_cutoff && timeElapsed <= totalTime-upper_cutoff
                joint_info{joint_idx,2}(:,trunc_idx) = joint_info_all{joint_idx,2}(:,time_idx);
                timeInts(trunc_idx) = timeInts_all(time_idx);
                timeVec(trunc_idx) = timeVec_all(time_idx);
                trunc_idx = trunc_idx+1;
            end
        end
    end

    for i = 1:length(joint_idxs)
        joint_info_all{i,2} = jointData(:,:,joint_idxs(i));
    end
    
    for m=1:length(joint_info{1,2})
        for i = 1:length(joint_info)     
             
                jointCoordinates(i,:) = joint_info{i,2}(:,m);
        end
    
         if m == 1
            h = plot3(jointCoordinates(:,1),jointCoordinates(:,3), jointCoordinates(:,2),'o');
            view([-31.8 -6])
            axis([-3 3 0 4.5 -2 2])
            xlabel('X');
            ylabel('Y');
            zlabel('Z');
            grid on;
        else
            h.XData = jointCoordinates(:,1);
            h.YData = jointCoordinates(:,3);
            h.ZData = jointCoordinates(:,2);
         end
     pause(timeInts(m)*0.001);
    end
end