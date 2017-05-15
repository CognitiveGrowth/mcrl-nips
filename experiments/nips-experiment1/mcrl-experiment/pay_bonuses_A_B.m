% manualy create worker_id and assingment_id cell arrays
experiment_version = 'B';


if strcmp(getenv('USER'),'paulkrueger')
    rootpath = '~/Desktop/Tom_Griffiths/';  
else
    rootpath = '~/Dropbox/PhD/Metacognitive RL/';
end
path=[rootpath,'mcrl-experiment/data/1/human/',experiment_version];
rawpath=[rootpath,'mcrl-experiment/data/1/human_raw/',experiment_version];
filename = [path,'/graph.csv'];
delimiter = ',';
startRow = 2;


formatSpec = '%q%q%q%[^\n\r]';
fileID = fopen([rawpath,'/questiondata.csv'],'r');
delimiter = ',';
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,1, 'ReturnOnError', false);
fclose(fileID);
bonuses = [];
dataArray = dataArray{3};
for i = 1:length(dataArray)
    bonuses = [bonuses; str2num(dataArray{i})];
end
s = 0;
for i = 1:length(bonuses)
    s = s + 1;
    data(s).bonus = bonuses(s);
end


bonus_file='';
for s=1:length(data)
    bonus = max([data(s).bonus,0.01]);
    bonus_commands{s}=['./grantBonus.sh -workerid ',worker_id{s},...
        ' -assignment ', assignment_id{s}, ' -amount ', sprintf('%0.2f',bonus),...
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