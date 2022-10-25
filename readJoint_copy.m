%function joints = readJoints(directory, filename)

clear
clc

exp_table = readtable("MVI009_pre-act_kinect.xlsx");

% filter table
exp_table = exp_table(exp_table.BodyClass == "subject", :);

%%
for file_idx = 1

    file_dir = 'C:\Users\Kim Sookoo\OneDrive - Johns Hopkins\VNEL1DRV\_Wyse Sookoo\Kinect\MVI009\MVI009_pre-act\';
    file_name = exp_table.FileName(file_idx)
    file_path = char(strcat(file_dir,file_name));
    
    f=fopen(file_path, 'r');
    if f == -1
        joints = [];
    else
        joints=fscanf(f, '%f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f %s %f %f %f %f %f', [354 Inf]);
        % each line gets stored as a column, integers represent joint name
        % string letters
        fclose(f);
        
        jointData = zeros(3,25); % 3 positional (X, Y, Z) 25 joints
        jointLoc = [11:13; 24:26; 33:35; 42:44; 59:61; 73:75; 87:89; 100:102;
            118:120; 133:135; 148:150; 162:164; 174:176; 187:189; 201:203;
            214:216; 227:229; 241:243; 256:258; 270:272; 288:290; 304:306;
            318:320; 335:337; 350:352];
        time = diff(joints(1,:));
        time = [time 33];
        for i = 1:length(joints(1,:)) % for each column of joints
            for m=1:25
                jointData(:,m) = joints(jointLoc(m,:),i);
            end
    
            figure(file_idx)
            if i == 1
                h = plot3(jointData(1,:),jointData(3,:), jointData(2,:),'o');
                axis([-3 3 0 4.5 -2 2])
                xlabel('X');
                ylabel('Y');
                zlabel('Z');
                grid on;
                % view([161.1 5.4])
            else
                h.XData = jointData(1,:);
                h.YData = jointData(3,:);
                h.ZData = jointData(2,:);
            end
            pause(time(i)*0.001);
        end
        
    end
end