clear
clc

m = 220/2.2;

%% Load joint data

file_path = 'C:\Users\Kim Sookoo\OneDrive - Johns Hopkins\VNEL1DRV\_Chow\Kinect Project\Test Files\20181120-154922MVI006_MR_test3_body2_joints.txt';

[jointData, timeVec_all, timeInts_all] = getJointData(file_path);

% Target joints: head, neck (maybe spine shoulder), spine base, shoulders,
% elbows, wrists, hand tips, hips, knees, ankles, feet

CMdata_all = getCMdata(jointData, m, 'median');

%% truncate

totalTime = (timeVec_all(end) - timeVec_all(1))*0.001;

trunc_idx = 1;

for time_idx = 1:length(timeVec_all)

    timeElapsed = (timeVec_all(time_idx) - timeVec_all(1))*0.001;

     if  timeElapsed >=10 && timeElapsed <= totalTime-10
        CMdata(trunc_idx,:) = CMdata_all(time_idx,:);
        timeInts(trunc_idx) = timeInts_all(time_idx);
        timeVec(trunc_idx) = timeVec_all(time_idx);
        trunc_idx = trunc_idx+1;
     end
end

%% visualize centered data

figure(3)

subplot(2,1,1)
plot(timeVec*0.001,CMdata(:,1))
xlabel 'time (s)'
ylabel 'Centered CM ML position'

subplot(2,1,2)
plot(timeVec*0.001,CMdata(:,2))
xlabel 'time (s)'
ylabel 'Centered CM AP position'


%% displacement RMS

ml_rms = sqrt(mean(CMdata(:,1).^2));
ap_rms = sqrt(mean(CMdata(:,2).^2));

% figure(4)
% plot(ml_centered,ap_centered)
% hold on
% plot(ml_rms,ap_rms, '*')
% xlabel 'ML'
% ylabel 'AP'

%% Principal sway vector

% calculate distance from center of each xy pair

for point_idx = 1:length(CMdata(:,1))

    magnitude(point_idx,1) = sqrt(CMdata(point_idx,1)^2 + ... 
        CMdata(point_idx,2)^2);

    theta(point_idx,1) = atan(CMdata(point_idx,1) / ...
        CMdata(point_idx,2));

end

avg_magnitude = mean(magnitude);
avg_theta = mean(theta); %radians

% resolve average vector

avg_mag_x = avg_magnitude*sin(avg_theta);
avg_mag_y = avg_magnitude*cos(avg_theta);

figure(4)
quiver(0,0,avg_mag_x,avg_mag_y)
hold on
plot(CMdata(:,1),CMdata(:,2))

%% PSD

Fs = 30;
t = timeVec;

x = CMdata;
[Pxx,F] = periodogram(x,[],length(x),Fs);

figure(5)
plot(F,10*log10(Pxx))
legend 'ml' 'ap' 'vertical'
hold on
xline(median(F))
