%% only run this first section for now

clear
clc

file_path = 'C:\Users\Kim Sookoo\OneDrive - Johns Hopkins\VNEL1DRV\_Chow\Kinect Project\Test Files\20170202-145901_mvi003_MR_foam_EC_body1_joints.txt';

[jointData, timeVec_all, timeInts_all] = getJointData(file_path);

% target joints: L/R hip, L/R ankle

joint_idxs = [13; 15; 17; 19];

joint_info_all = {'hipLeft';'ankleLeft';'hipRight';'ankleRight'};

for i = 1:length(joint_idxs)
    joint_info_all{i,2} = jointData(:,:,joint_idxs(i));
end


% truncate 1st and last 10s of data

totalTime = (timeVec_all(end) - timeVec_all(1))*0.001;
joint_info = joint_info_all(:,1);


for joint_idx = 1:length(joint_idxs)
    trunc_idx = 1;

    for time_idx = 1:length(timeVec_all)
    
        timeElapsed = (timeVec_all(time_idx) - timeVec_all(1))*0.001;
    
        if timeElapsed >= 10 && timeElapsed <= totalTime-10
            joint_info{joint_idx,2}(:,trunc_idx) = joint_info_all{joint_idx,2}(:,time_idx);
            timeInts(trunc_idx) = timeInts_all(time_idx-1);
            timeVec(trunc_idx) = timeVec_all(time_idx-1);
            trunc_idx = trunc_idx+1;
        end
    end
end

% difference between ankle and hip positions

swayL(1,:) = joint_info{1,2}(1,:)-joint_info{2,2}(1,:); %ML
swayL(2,:) = joint_info{1,2}(3,:)-joint_info{2,2}(3,:); %AP

swayR(1,:) = joint_info{3,2}(1,:)-joint_info{4,2}(1,:); %ML
swayR(2,:) = joint_info{3,2}(3,:)-joint_info{4,2}(3,:); %AP

figure(1)
plot3(timeVec,swayL(1,:),swayL(2,:)); %30 fps
% plot dimensions = x,z,time
title 'Left'
xlabel('Time');
ylabel('ML');
zlabel('AP');

figure(2)
plot3(timeVec,swayR(1,:),swayR(2,:));
title 'Right'
xlabel('Time');
ylabel('ML');
zlabel('AP');

%% 
% these sections haven't been adjusted yet... will likely cause errors 
% if the full code is run

timeToFail = length(swayL(1,:));
for i = 1:timeToFail
    k = find(abs(swayL(1,:)) > 5);
    l = find(abs(swayL(2,:)) > 5);
    
    if isempty(l)
        if ~isempty(k) && k(1) < timeToFail
            timeToFail = k(1);
        end
    elseif isempty(k)
        if ~isempty(l) && l(1) < timeToFail
            timeToFail = l(1);
        end
    elseif k(1) < l(1) && k(1) < timeToFail
        timeToFail = k(1);
    elseif l(1) < timeToFail
        timeToFail = l(1);
    end
end
if timeToFail > length(swayL(1,:))
    timeToFail = length(swayL(1,:));
end
swayL(1,:) = swayL(1,1:timeToFail);
swayL(2,:) = swayL(2,1:timeToFail);

%% Calculate centered data
centeredAP = swayL(2,:) - mean(swayL(2,:));
centeredML = swayL(1,:) - mean(swayL(1,:));
centeredSway = [centeredML centeredAP];

%% Covariance Matrix
covSway = centeredSway'*centeredSway;

%% Calculate Eigenvalues and Eigenvectors
[V,D] = eig(covSway);

%% Calculate Standard Deviation and 95% CI
sigma = sqrt(D/(length(swayL(2,:))-1));
CI95 = 1.96*sigma;

vec1 = CI95(1)*V(:,1);
vec2 = CI95(4)*V(:,2);

%% Check for fit
figure; plot(centeredML, centeredAP, '*');
hold on;
plot([0 vec1(1)], [0 vec1(2)])
plot([0 vec2(1)], [0 vec2(2)])

%% Calculate Area
area = pi*CI95(1)*CI95(4);