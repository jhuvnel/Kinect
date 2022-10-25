function [jointData, timeVec, timeInts] = getJointData(file_path)

%% Description

% loads joint coordinates from a .txt kinect file into a 3d array
% 
% outputs 
% 
%   jointData: n x m x j double
%       n = number of axes
%       m = number of data points per joint
%       j = number of joints (25)

%   timeVec: double
%       - returns a vector of timestamps

%   timeInts: double
%       - returns the elapsed time between consecutive data points
%       - appended with 33

%% open file and scan for strings and float values

% 10/24/22 - some pre-op files have infinite depth values that interrupt
% the fscanf command, these were replaced with zeroes

f=fopen(file_path, 'r');
if f == -1
    joints = [];
else
    joints=fscanf(f, '%f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f', [354 Inf]);
    fclose(f);
end

    % each line of the .txt file becomes one column of "joints"
    % integers represent letters of strings, first row is timestamps

%% organize outputs

LENGTH = length(joints(1,:));
jointData = zeros(3,LENGTH,25); %3 positional (X, Z, Y) 25 joints
jointLoc = [11:13; 24:26; 33:35; 42:44; 59:61; 73:75; 87:89; 100:102;
    118:120; 133:135; 148:150; 162:164; 174:176; 187:189; 201:203;
    214:216; 227:229; 241:243; 256:258; 270:272; 288:290; 304:306;
    318:320; 335:337; 350:352];

for j=1:LENGTH
    for m=1:25
        jointData(:,j,m) = joints(jointLoc(m,:),j);
    end
end

timeVec = joints(1,:);

timeInts = [diff(timeVec), 33];

end