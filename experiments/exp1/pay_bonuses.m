cd('~/Dropbox/PhD/Metacognitive RL/mcrl-experiment')
clear

experiment_version = '2B';

import_data

addpath('../')

% cd ~/Dropbox/'Accelerating Learning with PRs'/

addpath('~/Dropbox/PhD/MatlabTools/')
addpath('~/Dropbox/PhD/MatlabTools/parse_json/')

bonus_file='';
for s=1:length(data)
    bonus = max([data(s).bonus,0.01]);
    bonus_commands{s}=['./grantBonus.sh -workerid ',data(s).workerID,...
        ' -assignment ', data(s).assignmentID, ' -amount ', sprintf('%0.2f',bonus),...
        ' -reason "Bonus in Planning Experiment."'];
    bonus_file=[bonus_file, bonus_commands{s},';'];
end

filename=['payBonuses_MCRL_',experiment_version,'.sh'];
unix(['rm ',filename])
fid = fopen(filename, 'w');
% print a title, followed by a blank line
fprintf(fid, bonus_file);
fclose(fid)
unix(['chmod u+x ',filename])
unix(['mv ',filename,' /Applications/aws-mturk-clt-1.3.1/bin/'])
