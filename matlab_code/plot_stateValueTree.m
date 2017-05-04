function plot_stateValueTree(values,policy,S,pseudoR_matrix,min_trial,nTrials,R,start_state,trial_num,SAVE)
% function plot_stateValueTree(values,policy,S,pseudoR_matrix,min_trial)
%
% plots a decision tree for the tversky version of the binomial sampling
% task, showing the value of each state (computed from solving the MDP
% formulation of the problem)
% *NOTE: for illustration purposes, this will plot values and pseudorewards
% ONLY for sampling; because the game doesn't end when the agent predicts,
% the values and pseudorewards would change, making it diffecult to plot
% these contingencies; instead, this plot can be re-generated from any
% state-trial combination (after any number of predictions have been made)
% by giving this function the appropriate inputs
%
% since this task entails a finite horizon, the value of each state (and
% hence the pseudoreward) depends on the min_trial number
%
% The states (S) are assumed to be ordered as such:
% [1H1T, 2H1T, 1H2T, 1H3T, 2H2T 3H1T, etc.], where 1H1T is the state of
% having sampled 1 head and 1 tail from coin flips
%
% values: s x (n+1) matrix of state values, where s=number of states,
% n=number of trials
%
% policy: s x n matrix of actions to take under the optimal policy, given
% state (row) and min_trial (column)
%
% S: s x 2 matrix showing the number of heads (coloumn 1) and the number of
% tails (column 2) in each state (rows)
%
% pseudoR_matrix: s x (n+1) matrix of pseudorewards for each state and
% trial combination
%
% min_trial: s x 1 vector of the minimum possible trial number for a given
% state; i.e. if the agent only samples, what trial number will it be in
% for each state
%
% Paul M. Krueger, pmk@berkeley.edu, May 2016


% where to save the figure
host = getenv('USER');
if strcmp(host(1:4),'paul')
    figDir = '~/Desktop/Tom_Griffiths/tverskyExp/figures/';
else
    % Falk path goes here
    figDir = '';
end


% can load results instead of inputting them
if nargin < 7
    load('mdp_pseudorewards.mat')
end
if nargin < 8
    start_state = [1 1];
end
if nargin < 9
    trial_num = 1;
end
if nargin < 10
    SAVE = true;
end


% set the number of rows for the decision tree (i.e., number of coin flips)
% note: changing this number much may require tweeking the markersize and
% fontsize in order for the pyramid to look nice
treeDepth = 14;
total_trials = nTrials;
if trial_num + treeDepth > total_trials
    treeDepth = total_trials - trial_num + 1;
end


% select subset of pyramid if not starting from state [1 1]
idx = find(S(:,1)>=start_state(1) & S(:,2)>=start_state(2));
values = values(idx,trial_num:end);
policy = policy(idx,trial_num:end); 
pseudoR_matrix_action1 = pseudoR_matrix(idx,trial_num:end,1);
S = S(idx,:);
% min_trial = min_trial(idx);


% compute the coordinate position for every state to plot
step = 1/treeDepth;
coords{1} = [0.5, 1];
for i = 1:treeDepth-1
    x = -i;
    for j = 1:i+1
        coords{length(coords)+1} = [0.5+x*step, 1-i*step];
        x = x+2;
    end
end


% select values and pseudorewards *assuming sampling only* (i.e. no
% predictions)
for i = 1:length(coords)
    values_used(i) = values(i,min_trial(i));
    policy_used(i) = policy(i,min_trial(i));
    pseudoR_used(i) = pseudoR_matrix_action1(i,min_trial(i));
end
pseudoR_used(pseudoR_used==0) = 0;


% set colormap
nColors = 10000;
cmap = parula(nColors);
minV = min(values_used);
maxV = max(values_used);

figure('position',[880 385 560 420]); hold on;

% loop through the states
for i = 1:length(coords)
    
    % map the state value to the colorscale
    V = values_used(i);
    frac = round((V - minV)/(maxV - minV)*(nColors-1))+1;
    
    color = cmap(frac,:);
    
    % plot the state as a square with the color indicating state value
    plot(coords{i}(1),coords{i}(2),'s','markersize',38,'markeredgecolor','k','markerfacecolor',color)
    
    % text is red when the optimal action is 2, and black otherwise
    if policy_used(i) == 2
        colorStr = 'r';
    else
        colorStr = 'k';
    end
    
    % display the number of heads and tails
    text(coords{i}(1),coords{i}(2)+.02,[num2str(S(i,1)),'H,',num2str(S(i,2)),'T'],'horizontalalignment','center','verticalalignment','bottom','color',colorStr,'fontsize',8)
    
    % diaplay the value of the state
    text(coords{i}(1),coords{i}(2)+.01,sprintf('%0.3f',V),'horizontalalignment','center','verticalalignment','middle','color',colorStr,'fontsize',8)
    
    % dipaly the pseudoreward of the state
    text(coords{i}(1),coords{i}(2),sprintf('%0.3f',pseudoR_used(i)),'horizontalalignment','center','verticalalignment','top','color',colorStr,'fontsize',8)
    
end

set(gca,'xlim',1.05*get(gca,'xlim'))
set(gca,'ylim',1.05*get(gca,'ylim'))
axis off
caxis([minV maxV])
colorbar
title({'number of Heads, number of Tails',['state value (start state ',num2str(start_state(1)),'H,',num2str(start_state(2)),'T, trial ',num2str(trial_num),')'],'optimal pseudoreward for observing'})


if SAVE
    % save the figure as a nice pdf
    if ~exist(figDir,'dir')
        mkdir(figDir)
    end
    saveStr = ['_st',num2str(start_state(1)),'-',num2str(start_state(2)),'_trial',num2str(trial_num)];
    saveFigurePdf(gcf, [figDir,'stateValueTree_observe',saveStr])
end


pseudoR_matrix_action2 = pseudoR_matrix(idx,trial_num:end,2);
for i = 1:length(coords)
    values_used(i) = values(i,min_trial(i));
    policy_used(i) = policy(i,min_trial(i));
    pseudoR_used(i) = pseudoR_matrix_action2(i,min_trial(i));
end
pseudoR_used(pseudoR_used==0) = 0;


% set colormap
nColors = 10000;
cmap = parula(nColors);
minV = min(values_used);
maxV = max(values_used);

figure('position',[880 385 560 420]); hold on;

% loop through the states
for i = 1:length(coords)
    
    % map the state value to the colorscale
    V = values_used(i);
    frac = round((V - minV)/(maxV - minV)*(nColors-1))+1;
    
    color = cmap(frac,:);
    
    % plot the state as a square with the color indicating state value
    plot(coords{i}(1),coords{i}(2),'s','markersize',38,'markeredgecolor','k','markerfacecolor',color)
    
    % text is red when the optimal action is 2, and black otherwise
    if policy_used(i) == 2
        colorStr = 'r';
    else
        colorStr = 'k';
    end
    
    % display the number of heads and tails
    text(coords{i}(1),coords{i}(2)+.02,[num2str(S(i,1)),'H,',num2str(S(i,2)),'T'],'horizontalalignment','center','verticalalignment','bottom','color',colorStr,'fontsize',8)
    
    % diaplay the value of the state
    text(coords{i}(1),coords{i}(2)+.01,sprintf('%0.3f',V),'horizontalalignment','center','verticalalignment','middle','color',colorStr,'fontsize',8)
    
    % dipaly the pseudoreward of the state
    text(coords{i}(1),coords{i}(2),sprintf('%0.3f',pseudoR_used(i)),'horizontalalignment','center','verticalalignment','top','color',colorStr,'fontsize',8)
    
end

set(gca,'xlim',1.05*get(gca,'xlim'))
set(gca,'ylim',1.05*get(gca,'ylim'))
axis off
caxis([minV maxV])
colorbar
title({'number of Heads, number of Tails',['state value (start state ',num2str(start_state(1)),'H,',num2str(start_state(2)),'T, trial ',num2str(trial_num),')'],'optimal pseudoreward for betting'})

if SAVE
    saveFigurePdf(gcf, [figDir,'stateValueTree_bet',saveStr])
end


% plot pseudorewards for all possible state-trial combonations; state trial
% combinations that are impossible (or the last trial) have NaN values
figure('position',[0 0 560 805])
pseudoR_matrix = get_pseudoreward_matrix(S,values,min_trial,1,R);
pseudoR_matrix = pseudoR_matrix(:,:,1);
[nr,nc,na] = size(pseudoR_matrix);
pcolor([pseudoR_matrix(:,:,1) nan(nr,1); nan(1,nc+1)]);
shading flat;
set(gca, 'ydir', 'reverse');
caxis([min(pseudoR_matrix(:)) max(pseudoR_matrix(:))])
colorbar
nStates = (total_trials-trial_num+1)*(total_trials-trial_num+2)/2;
ylim([1 nStates+1])
xlim([1 total_trials-trial_num+2])
set(gca,'ytick',[1:nStates]+.5,'yticklabel',{num2str(S(1:nStates,:))})
set(gca,'xtick',[1:total_trials-trial_num+1]+.5,'xticklabel',trial_num:total_trials)
xlabel('trial number','fontsize',16)
ylabel('state','fontsize',16)
title(['pseudorewards for observing (start state ',num2str(start_state(1)),'H,',num2str(start_state(2)),'T, trial ',num2str(trial_num),')'],'fontsize',16)

if SAVE
    saveFigurePdf(gcf, [figDir,'PRs_observe',saveStr])
end

figure('position',[520 0 560 805])
pseudoR_matrix = get_pseudoreward_matrix(S,values,min_trial,1,R);
pseudoR_matrix = pseudoR_matrix(:,:,2);
[nr,nc,na] = size(pseudoR_matrix);
pcolor([pseudoR_matrix(:,:,1) nan(nr,1); nan(1,nc+1)]);
shading flat;
set(gca, 'ydir', 'reverse');
caxis([min(pseudoR_matrix(:)) max(pseudoR_matrix(:))])
colorbar
nStates = (total_trials-trial_num+1)*(total_trials-trial_num+2)/2;
ylim([1 nStates+1])
xlim([1 total_trials-trial_num+2])
set(gca,'ytick',[1:nStates]+.5,'yticklabel',{num2str(S(1:nStates,:))})
set(gca,'xtick',[1:total_trials-trial_num+1]+.5,'xticklabel',trial_num:total_trials)
xlabel('trial number','fontsize',16)
ylabel('state','fontsize',16)
title(['pseudorewards for betting (start state ',num2str(start_state(1)),'H,',num2str(start_state(2)),'T, trial ',num2str(trial_num),')'],'fontsize',16)

if SAVE
    saveFigurePdf(gcf, [figDir,'PRs_bet',saveStr])
end


% plot all state values-- again, only values that are possible to reach
figure('position',[1040 0 560 805])
values(isnan(pseudoR_matrix)) = NaN;
[nr,nc] = size(values);
pcolor([values nan(nr,1); nan(1,nc+1)]);
shading flat;
set(gca, 'ydir', 'reverse');
caxis([min(values(:)) max(values(:))])
colorbar
ylim([1 nStates+1])
xlim([1 total_trials-trial_num+2])
set(gca,'ytick',[1:nStates]+.5,'yticklabel',{num2str(S(1:nStates,:))})
set(gca,'xtick',[1:total_trials-trial_num+1]+.5,'xticklabel',trial_num:total_trials)
xlabel('trial number','fontsize',16)
ylabel('state','fontsize',16)
title(['state values (start state ',num2str(start_state(1)),'H,',num2str(start_state(2)),'T, trial ',num2str(trial_num),')'],'fontsize',16)

if SAVE
    saveFigurePdf(gcf, [figDir,'stateValues',saveStr])
end
