%analyze the information gathering experiment
clear,close all,clc

% addpath(genpath('~/Documents/MATLAB/MatlabTools/'))
figDir = '~/Desktop/Tom_Griffiths/collapsingBoundsExp/figures/';
addpath('~/Dropbox/PhD/MatlabTools/')
addpath('~/Dropbox/PhD/MatlabTools/parse_json/')

%1. Load Data
% experiment_nr=2;
filename=['~/Desktop/Tom_Griffiths/collapsingBoundsExp/data/collapsingBoundsExp_data_v0.csv'];
filename_metadata=['~/Desktop/Tom_Griffiths/collapsingBoundsExp/data/collapsingBoundsExp_metadata_v0.csv'];

%0. determine the number of participants
fid=fopen(filename);
nr_subjects=linecount(fid)-1;
fclose(fid);

%1. load the meta-data
if exist('filename_metadata','var')
    fid=fopen(filename_metadata);
    header=textscan(fid,'%s%s%s%s%s%s%s%s',1,'delimiter',',');
    
    for s=1:nr_subjects
        text=textscan(fid,'%s%s%s%s%s%s%s%s',1,'delimiter',',');
        data.workerID{s,1}=text{5};        
        date_length=numel(text{end-1}{1});
        start_time=strtrim(text{end-1}{1}((date_length-17):(date_length-9)));
        submit_time=strtrim(text{end}{1}((date_length-17):(date_length-9)));
        completion_time(s)=3600*(str2num(submit_time(1:2))-str2num(start_time(1:2)))+...
            60*(str2num(submit_time(4:5))-str2num(start_time(4:5)))+...
            str2num(submit_time(7:8))-str2num(start_time(7:8));
    end
    
    data.median_completion_time=median(completion_time)/60;
    data.mean_completion_time=mean(completion_time)/60;
    data.completion_time(:,1)=completion_time';
    %determine which participants are new
    
end

%load the data
fid=fopen(filename);
header = fgetl(fid);

for sub=1:nr_subjects
    
    subject_str = fgetl(fid);
    subject_str=strrep(strrep(subject_str,'""','"'),'[]','[-999999999]');
    data_by_sub{sub}=parse_json(subject_str(2:end-1));
%     if sub <= 35
%         data_by_sub{sub}{1}.condition = 'timeouts';
%     end
    
    data.cost(sub) = data_by_sub{sub}{1}.cost;
    data.reward_correct(sub) = data_by_sub{sub}{1}.reward_correct;
    data.reward_incorrect(sub) = data_by_sub{sub}{1}.reward_incorrect;
    data.p_lefts(sub,:) = [data_by_sub{sub}{1}.p_lefts{:}];
    data.predicted_left(sub,:) = [data_by_sub{sub}{1}.predicted_left{:}];
    data.outcome_was_left(sub,:) = [data_by_sub{sub}{1}.outcome_was_left{:}];
    data.correct(sub,:) = [data_by_sub{sub}{1}.correct{:}];
    data.reward_scored(sub,:) = [data_by_sub{sub}{1}.reward_scored{:}];
    data.observed(sub,:) = [data_by_sub{sub}{1}.observed{:}];
    data.reaction_times{sub} = [data_by_sub{sub}{1}.reaction_times{:}];
    data.RT_experiment(sub) = data_by_sub{sub}{1}.RT_experiment;
    data.RT_instructions(sub) = data_by_sub{sub}{1}.RT_instructions;
    data.bonus(sub) = str2num(data_by_sub{sub}{1}.bonus);
    data.failed_quiz{sub} = [data_by_sub{sub}{1}.failed_quiz{:}];
    data.gender{sub} = data_by_sub{sub}{1}.gender;
    data.age{sub} = data_by_sub{sub}{1}.age;
    data.language{sub} = data_by_sub{sub}{1}.language;
end
fclose(fid);

% RT_threshold=percentile(median(data.RTs,2),2.5);
% too_fast=median(data.RTs,2)<RT_threshold;
% raw_data=data;
% %data=selectFromStruct(data,~too_fast)

total_payment = data.bonus+.25;
% experiment_hours = (data.RT_experiment+data.RT_instructions)/3600;
experiment_hours = completion_time/3600;
pay_rate = total_payment./experiment_hours;
figure
subplot(1,3,1)
hist(total_payment),title('payment ($)')
subplot(1,3,2)
hist(experiment_hours*60),title('experiment time (minutes)')
subplot(1,3,3)
hist(pay_rate),title('hourly pay ($/hour)')


%%

cost1=[];cost2=[];cost3=[];cost4=[];cost5=[];cost6=[];
RT1=nan(180,100);RT2=nan(180,100);RT3=nan(180,100);RT4=nan(180,100);RT5=nan(180,100);RT6=nan(180,100);
RT1pred=[];RT2pred=[];RT3pred=[];RT4pred=[];RT5pred=[];RT6pred=[];
for i = 1:length(data.cost)
%     if (length(cell2mat(data.failed_quiz(1)))>1) %cell2mat(data.failed_quiz(i))~=-999999999 || 
%         continue
%     end
    ix = data.p_lefts(i,:) == 0.5;
    first_p5_observation = sum(data.observed(i,1:find(ix)-1))+find(ix);
    p5_prediction = first_p5_observation+data.observed(i,ix);
    p5_observation_range = first_p5_observation:p5_prediction;% -1 to exclude prediction
    switch data.cost(i)
        case 0
            cost1 = [cost1,data.observed(i,ix)];
            RT1(i,1:data.observed(i,ix)+1) = data.reaction_times{i}(p5_observation_range);
            RT1pred = [RT1pred,data.reaction_times{i}(p5_observation_range(end))];
        case .001
            cost2 = [cost2,data.observed(i,ix)];
            RT2(i,1:data.observed(i,ix)+1) = data.reaction_times{i}(p5_observation_range);
            RT2pred = [RT2pred,data.reaction_times{i}(p5_observation_range(end))];
        case .0018
            cost3 = [cost3,data.observed(i,ix)];
            RT3(i,1:data.observed(i,ix)+1) = data.reaction_times{i}(p5_observation_range);
            RT3pred = [RT3pred,data.reaction_times{i}(p5_observation_range(end))];
        case .003
            cost4 = [cost4,data.observed(i,ix)];
            RT4(i,1:data.observed(i,ix)+1) = data.reaction_times{i}(p5_observation_range);
            RT4pred = [RT4pred,data.reaction_times{i}(p5_observation_range(end))];
        case .0044
            cost5 = [cost5,data.observed(i,ix)];
            RT5(i,1:data.observed(i,ix)+1) = data.reaction_times{i}(p5_observation_range);
            RT5pred = [RT5pred,data.reaction_times{i}(p5_observation_range(end))];
        case .01
            cost6 = [cost6,data.observed(i,ix)];
            RT6(i,1:data.observed(i,ix)+1) = data.reaction_times{i}(p5_observation_range);
            RT6pred = [RT6pred,data.reaction_times{i}(p5_observation_range(end))];
    end
end

figure; hold on;
bp = [1:6];
b(1) = bar(bp(1), mean(cost1), .3);
b(2) = bar(bp(2), mean(cost2), .3);
b(3) = bar(bp(3), mean(cost3), .3);
b(4) = bar(bp(4), mean(cost4), .3);
b(5) = bar(bp(5), mean(cost5), .3);
b(6) = bar(bp(6), mean(cost6), .3);

e = errorbar(bp, [mean(cost1),mean(cost2),mean(cost3),mean(cost4),mean(cost5),mean(cost6)],...
    [std(cost1)/sqrt(length(cost1)),std(cost2)/sqrt(length(cost2)),std(cost3)/sqrt(length(cost3)),std(cost4)/sqrt(length(cost4)),std(cost5)/sqrt(length(cost5)),std(cost6)/sqrt(length(cost6))]);
% set(b(1), 'facecolor', [h1gain+.25]);

% plot(2:6,fliplr([1,3,7,15,29]),'*g','markersize',16)

set(e, 'linestyle', 'none', 'color', 'k', 'linewidth', 2)
% for i = 1:length(e)
%     errorbar_tick(e(i), 40);
% end
xlabel('cost','fontsize', 20)
set(gca,'xtick',1:6,'xticklabel',unique(data.cost))
ylabel({'# observations','on p=0.5 games'},'fontsize', 20)


figure;hold on
errorbar(nanmean(RT1),nanstd(RT1)./sqrt(sum(~isnan(RT1))));
errorbar(nanmean(RT2),nanstd(RT2)./sqrt(sum(~isnan(RT2))));
errorbar(nanmean(RT3),nanstd(RT3)./sqrt(sum(~isnan(RT3))));
errorbar(nanmean(RT4),nanstd(RT4)./sqrt(sum(~isnan(RT4))));
errorbar(nanmean(RT5),nanstd(RT5)./sqrt(sum(~isnan(RT5))));
errorbar(nanmean(RT6),nanstd(RT6)./sqrt(sum(~isnan(RT6))));
xlabel('observation #','fontsize', 20)
ylabel('reaction time [sec]','fontsize', 20)
costs = unique(data.cost); coststr = [];
for c = 1:length(costs)
    coststr = [coststr,'''',num2str(costs(c)),''','];
end
eval(['legend(',coststr(1:end-1),')'])

figure,hold on;
dat_mean=[mean(RT1pred),mean(RT2pred),mean(RT3pred),mean(RT4pred),mean(RT5pred),mean(RT6pred)];
dat_sem=[std(RT1pred)/sqrt(length(RT1pred)),std(RT2pred)/sqrt(length(RT2pred)),std(RT3pred)/sqrt(length(RT3pred)),std(RT4pred)/sqrt(length(RT4pred)),std(RT5pred)/sqrt(length(RT5pred)),std(RT6pred)/sqrt(length(RT6pred))];
errorbar(dat_mean,dat_sem)
% pleft1=[];pleft2=[];pleft3=[];pleft4=[];pleft5=[];pleft6=[];pleft7=[];pleft8=[];pleft9=[];
% for i = 1:length(data.p_lefts)
%     ix = data.p_lefts(i,:) == 0.5;
%     switch data.pleft(i)
%         case .1
%             pleft1 = [pleft1,data.observed(i,ix)];
%         case .2
%             pleft2 = [pleft2,data.observed(i,ix)];
%         case .3
%             pleft3 = [pleft3,data.observed(i,ix)];
%         case .4
%             pleft4 = [pleft4,data.observed(i,ix)];
%         case .5
%             pleft5 = [pleft5,data.observed(i,ix)];
%         case .6
%             pleft6 = [pleft6,data.observed(i,ix)];
%         case .7
%             pleft4 = [pleft7,data.observed(i,ix)];
%         case .8
%             pleft5 = [pleft8,data.observed(i,ix)];
%         case .9
%             pleft6 = [pleft9,data.observed(i,ix)];
%     end
% end


%% simulate optimal games

simData = [data.outcome_was_left(strcmp(data.condition,conditions{3}) & p3p7_idx,:);...
    data.outcome_was_left(strcmp(data.condition,conditions{4}),:)];
[sim_reward, sim_nObservations, sim_observed] = get_optimal_behavior(simData);


%% did they make the bet bets based on what they observed?

made_best_bet{1}=data.made_best_bet(strcmp(data.condition,conditions{3}) & p3p7_idx,:);
made_best_bet{2}=data.made_best_bet(strcmp(data.condition,conditions{4}),:);
nr_trials = size(data.correct,2);

figure(),hold on;
errorbar(squeeze(nanmean(made_best_bet{1})),squeeze(nanstd(made_best_bet{1}))./sqrt(sum(~isnan(made_best_bet{1}),1)),'k','LineWidth',3)
errorbar(squeeze(nanmean(made_best_bet{2})),squeeze(nanstd(made_best_bet{2}))./sqrt(sum(~isnan(made_best_bet{1}),1)),'r','LineWidth',3)

ylim([0 1]); xlim([0 nr_trials+1])
xlabel('Trial Nr.','FontSize',18),ylabel('made best bet','FontSize',18)
set(gca,'FontSize',16)
legend(conditions{3},conditions{4},'location','southeast')
title('P(left) 0.3 or 0.7','fontsize',16)
saveFigurePdf(gcf, [figDir,'made_best_bet'])


%%

%2. Test hypotheses
%2a. Did PR reduce the number of samples?
data.nr_samples=sum(data.observed,2);

for c=1:numel(conditions)
    in_condition=(strcmp(data.condition,conditions{c}) & p3p7_idx);
    avg_nr_samples(c)=mean(data.nr_samples(in_condition));
    sem_nr_samples(c)=sem(data.nr_samples(in_condition));
end

figure()
barwitherr([sem_nr_samples, sem(sim_nObservations)],[avg_nr_samples, mean(sim_nObservations)])
ylabel('Nr. Observations','FontSize',18)
set(gca,'FontSize',16)
set(gca,'XTickLabel',{'Monetary PR','Virtual PR','No PR','Timeouts','Optimal'})
title('P(left) 0.3 or 0.7','fontsize',16)
saveFigurePdf(gcf, [figDir,'nObservations_vs_condition'])

%%

p_observe{1}=data.observed(strcmp(data.condition,conditions{3})&p3p7_idx,:);
p_observe{2}=data.observed(strcmp(data.condition,conditions{4}),:);

nr_trials = size(data.correct,2);

figure(),
errorbar(squeeze(mean(p_observe{1})),squeeze(sem(p_observe{1})),'k','LineWidth',3),hold on
errorbar(squeeze(mean(p_observe{2})),squeeze(sem(p_observe{2})),'r','LineWidth',3),hold on
errorbar(mean(sim_observed),sem(sim_observed),'--b','LineWidth',3),hold on

ylim([0 1]); xlim([0 nr_trials+1])
xlabel('Trial Nr.','FontSize',18),ylabel('P(Observe)','FontSize',18)
set(gca,'FontSize',16)
legend(conditions{3},conditions{4},'optimal')
title('P(left) 0.3 or 0.7','fontsize',16)
saveFigurePdf(gcf, [figDir,'pObserve_vs_trialNum'])

%%

%2b. Did PR increase the total reward?
data.total_reward=sum(data.rewards,2);
total_reward=data.total_reward;
for c=1:numel(conditions)
    in_condition=(strcmp(data.condition,conditions{c})&p3p7_idx);
    avg_reward(c)=mean(total_reward(in_condition));
    sem_reward(c)=sem(total_reward(in_condition));
end

figure()
barwitherr([sem_reward, sem(sim_reward)],[avg_reward mean(sim_reward)])
ylabel('Total Reward','FontSize',18)
set(gca,'FontSize',16)
set(gca,'XTickLabel',{'Monetary PR','Virtual PR','No PR','Timeouts','Optimal'})
title('P(left) 0.3 or 0.7','fontsize',16)
saveFigurePdf(gcf, [figDir,'reward_vs_condition'])
