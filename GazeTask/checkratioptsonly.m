% check only ratio pts
subjectNum=500;
subjectDay=3;
dataDir = ['data/subject' num2str(subjectNum) '/day' num2str(subjectDay) '/'];
d = load(fullfile(dataDir,'gazedata_20180517T100409'));
%%
ratio_pts = zeros(1,20);
for trial = 1:20
remote_start = d.timing.gaze.pic(trial);
remote_stop = d.timing.gaze.off(trial);
(remote_stop-remote_start)/(1E6);
% now find the data between these time points
time_trial = d.GazeData.Timing.Remote{trial}; % 709 points
trial_rows = intersect(find(time_trial>=remote_start), find(time_trial<=remote_stop));

rightEyeAll = d.GazeData.Right{trial}(trial_rows,:);
leftEyeAll = d.GazeData.Left{trial}(trial_rows,:);
rightGazePoint2d.x = rightEyeAll(:,7);
rightGazePoint2d.y = rightEyeAll(:,8);
leftGazePoint2d.x = leftEyeAll(:,7);
leftGazePoint2d.y = leftEyeAll(:,8);
badrightX = find(rightGazePoint2d.x == -1);
badrightY = find(rightGazePoint2d.y == -1);
badleftX = find(leftGazePoint2d.x == -1);
badleftY = find(leftGazePoint2d.y == -1);
rightGazePoint2d.x(badrightX) = nan;
rightGazePoint2d.y(badrightY) = nan;
leftGazePoint2d.x(badleftX) = nan;
leftGazePoint2d.y(badrightY) = nan;
gaze.x = nanmean([rightGazePoint2d.x, leftGazePoint2d.x],2);
gaze.y = nanmean([rightGazePoint2d.y, leftGazePoint2d.y],2);
% so ignore any negatives (will do that anyway)
% find points in area one
% when you have both left and right eye (later can just use one)
n_points = length(find(gaze.x > 0 | gaze.y >0));
ratio_pts(trial) = n_points/length(gaze.x)
% n_pos1 = find((gaze.x >= pos_1(1) & gaze.x<=pos_1(3)) & (gaze.y >= pos_1(2) & gaze.y<=pos_1(4)));
% n_pos2 = find((gaze.x >= pos_2(1) & gaze.x<=pos_2(3)) & (gaze.y >= pos_2(2) & gaze.y<=pos_2(4)));
% n_pos3 = find((gaze.x >= pos_3(1) & gaze.x<=pos_3(3)) & (gaze.y >= pos_3(2) & gaze.y<=pos_3(4)));
% n_pos4 = find((gaze.x >= pos_4(1) & gaze.x<=pos_4(3)) & (gaze.y >= pos_4(2) & gaze.y<=pos_4(4)));
% 
% r_pos1 = length(n_pos1)/n_points;
% r_pos2 = length(n_pos2)/n_points;
% r_pos3 = length(n_pos3)/n_points;
% r_pos4 = length(n_pos4)/n_points;
end

figure;
plot(ratio_pts)
xlabel('Trial #')
ylabel('Proportion Data')
ylim([0 1])
title(sprintf('Mean is %.2f', mean(ratio_pts)))
