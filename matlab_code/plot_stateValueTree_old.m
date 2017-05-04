function plot_stateValueTree_old(values,policy,S,pseudoR,cost,treeDepth)
% function plot_stateValueTree(values,policy,S,pseudoR,cost)
% 
% plots a decision tree for a binomial variable, showing the value of every
% state (computed from solving the MDP formulation of the problem)
% 
% inputs are of length N where N is the number of states.
% The states are assumed to be ordered as such:
% [1H1T, 2H1T, 1H2T, 1H3T, 2H2T 3H1T, etc.], where 1H1T is the state of 
% having sampled 1 head and 1 tail from coin flips
% 
% values: vector of state values
% policy: vector of actions to take under the optimal policy
% S: Nx2 matrix showing the number of heads (coloumn 1) and the number of
% tails (column 2) in each state (rows)
% pseudoR: vector of pseudorewards for each state
% cost: scalar value of the cost of sampling
% 
% Paul M. Krueger, pmk@berkeley.edu, May 2016


% where to save the figure
figDir = '~/Desktop/Tom_Griffiths/rotation/figures/optimal_sampling/';

% can load results instead of inputting them
if nargin < 5
    load(['mdp_LP_output_0.005.mat'])
end

% set the number of rows for the decision tree (i.e., number of coin flips)
% note: changing this number much may require tweeking the markersize and
% fontsize in order for the pyramid to look nice
if nargin < 6
    treeDepth = 13;
end

% compute the coordinate position for every state to plot
step = 1/treeDepth;
coords{1} = [0.5, 1];
for i = 1:treeDepth
    x = -i;
    for j = 1:i+1
        coords{length(coords)+1} = [0.5+x*step, 1-i*step];
        x = x+2;
    end
end

% set the range of colors
nColors = 10000;
cmap = parula(nColors);
minV = min(values(1:length(coords))); %.5
maxV = max(values(1:length(coords))); %1

figure('position',[440 378 560 420]); hold on;

% loop through the states
for i = 1:length(coords)
    
    % map the state value to the colorscale
    V = values(i);
    frac = round((V - minV)/(maxV - minV)*(nColors-1))+1;
    color = cmap(frac,:);
    
	% plot the state as a square with the color indicating state value
    plot(coords{i}(1),coords{i}(2),'s','markersize',40,'markeredgecolor','k','markerfacecolor',color)
    
    % text is red when the optimal action is 2, and black otherwise
    if policy(i) == 2
        colorStr = 'r';
    else
        colorStr = 'k';
    end

    plot(coords{i}(1),coords{i}(2)+.015,'x','color',colorStr)
%     % display the number of heads and tails
%     text(coords{i}(1),coords{i}(2)+.015,[num2str(S(i,1)),'H,',num2str(S(i,2)),'T'],'horizontalalignment','center','verticalalignment','bottom','color',colorStr,'fontsize',8)
%     
%     % diaplay the value of the state
%     text(coords{i}(1),coords{i}(2)+.01,[sprintf('%0.3f',values(i))],'horizontalalignment','center','verticalalignment','top','color',colorStr,'fontsize',8)
%     
%     % or dipaly the pseudoreward of the state
%     text(coords{i}(1),coords{i}(2)-.015,[sprintf('%0.3f',pseudoR(i))],'horizontalalignment','center','verticalalignment','top','color',colorStr,'fontsize',8)

end

set(gca,'xlim',1.05*get(gca,'xlim'))
set(gca,'ylim',1.05*get(gca,'ylim'))
axis off
caxis([minV maxV])
colorbar
title({'value of states',['cost of sampling = ',num2str(cost)],'(H=heads, T=tails; red text \Rightarrow action 2 under optimal policy)'})

% save the figure as a nice pdf
if ~exist(figDir,'dir')
    mkdir(figDir)
end
costStr = num2str(cost);
costStr = costStr(3:end);
saveFigurePdf(gcf, [figDir,'stateValueTree_cost',costStr])
