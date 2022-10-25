function [truncated_signal, truncated_timeVec, truncated_timeInts] = ...
    truncateSignalandTimeData(signal,timeVec,timeInts,lower_cutoff, upper_cutoff)

% truncates signal and time vectors based on user specified cutoffs

totalTime = (timeVec(end) - timeVec(1))*0.001;

trunc_idx = 1;

for time_idx = 1:length(timeVec)

    timeElapsed = (timeVec(time_idx) - timeVec(1))*0.001;

     if  timeElapsed >= lower_cutoff && timeElapsed <= totalTime-upper_cutoff
        truncated_signal(trunc_idx,:) = signal(time_idx,:);
        truncated_timeInts(trunc_idx) = timeInts(time_idx);
        truncated_timeVec(trunc_idx) = timeVec(time_idx);
        trunc_idx = trunc_idx+1;
     end
end
end