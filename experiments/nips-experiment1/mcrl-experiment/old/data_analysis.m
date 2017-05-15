cd('~/Dropbox/PhD/Metacognitive RL/mcrl-experiment')
clear
%%

experiment_version = 'B';

BLUE = [0,50,98]/255;
GOLD = [253,181,21]/255;
SAVE = false;
DO_STATS = false;
figdir = ['~/Dropbox/PhD/Metacognitive RL/mcrl-experiment/figures/',experiment_version,'/'];
if SAVE && ~exist(figdir,'dir')
    mkdir(figdir)
    mkdir([figdir,'stats/'])
end

import_data

addpath('../')

%% plot reward vs. number of clicks

figure; hold on;
clicksFB = [data(idx_FB).nr_clicks1];
clicksNoFB = [data(idx_noFB).nr_clicks1];
rewFB = [data(idx_FB).score];
rewNoFB = [data(idx_noFB).score];
plot(clicksFB(:)-.05,rewFB(:),'.','color',GOLD)
plot(clicksNoFB(:)+.05,rewNoFB(:),'.','color',BLUE)
xlabel({'# clicks' 'before 1^{st} move'},'FontSize',18)
ylabel('reward ($)','FontSize',18)
xlim([-.2 16.2])

X = [ones(size(clicksFB(:))), clicksFB(:)];
[b,bint,r,rint,stats]=regress(rewFB(:),X);
l1 = plot([0 16],[b(1) (b(2)*16+b(1))],'--','linewidth',2,'color',GOLD);
text(1,-6,['slope=',sprintf('%0.3f',b(2)),' p=',sprintf('%0.6f',stats(3))])
X = [ones(size(clicksNoFB(:))), clicksNoFB(:)];
[b,bint,r,rint,stats]=regress(rewNoFB(:),X);
l2 = plot([0 16],[b(1) (b(2)*16+b(1))],'--','linewidth',2,'color',BLUE);
text(1,-9,['slope=',sprintf('%0.3f',b(2)),' p=',sprintf('%0.6f',stats(3))])
legend([l1,l2],'feedback','no feedback','location','southeast')
if SAVE, saveas(gcf,[figdir,'/reward_vs_clicks'],'png');end

%% plot relative reward

figure; hold on;
y1 = [data(idx_FB).relative_reward];
y2 = [data(idx_noFB).relative_reward];
errorbar(mean(y1,2),sem(y1,2),'color',GOLD,'linewidth',3)
errorbar(mean(y2,2),sem(y2,2),'color',BLUE,'linewidth',3)
legend('feedback','no feedback','location','southeast')
xlabel('trial','fontsize',36)
ylabel('relative reward','fontsize',36)
set(gca,'xtick',5:5:nr_trials,'fontsize',24);
xlim([0 nr_trials+1])

if SAVE, saveas(gcf,[figdir,'/relative_reward'],'png');end

if DO_STATS
%     Group = [repmat('F',sum(idx_FB),1);repmat('C',sum(idx_noFB),1)];
%     Y = [y1';y2'];
%     t = table(Group,Y(:,1),Y(:,2),Y(:,3),Y(:,4),Y(:,5),Y(:,6),Y(:,7),Y(:,8),Y(:,9),Y(:,10),Y(:,11),Y(:,12),Y(:,13),Y(:,14),Y(:,15),Y(:,16),Y(:,17),Y(:,18),Y(:,19),Y(:,20),...
%         'VariableNames',{'Group','t1','t2','t3','t4','t5','t6','t7','t8','t9','t10','t11','t12','t13','t14','t15','t16','t17','t18','t19','t20'});
%     Time = [1:20]';
%     rm = fitrm(t,'t1-t20 ~ Group','WithinDesign',Time);
    close all hidden
    conds = [ones(size(y1(:))); zeros(size(y2(:)))];
    trial = repmat([1:nr_trials]',numel(conds)/nr_trials,1);
    subjs = repmat(1:nr_subj,nr_trials,1);
    [p, tt, stats, terms] = anovan([y1(:);y2(:)],{conds(:),trial(:)}, ...
        'model', 'interaction', ...
        'display', 'on', ...
        'varnames', {'condition','trial'});
    if SAVE,saveas(1,[figdir,'/stats/relative_reward.jpg']);end
end
%% plot delays after each move

figure; hold on;
y1 = [data(idx_FB).delays1];
y2 = [data(idx_noFB).delays1];
errorbar(mean(y1,2),sem(y1,2),'color',GOLD,'linewidth',3)
errorbar(mean(y2,2),sem(y2,2),'color',BLUE,'linewidth',3)
% errorbar(mean([data.delays2],2),sem([data.delays2],2),'linewidth',3)
% errorbar(mean([data.delays3],2),sem([data.delays3],2),'linewidth',3)
% legend('move 1','move 2','move 3')
legend('feedback','no feedback')
xlabel('trial','fontsize',36)
ylabel('delay after 1^{st} move (sec)','fontsize',36)
set(gca,'xtick',5:5:nr_trials,'fontsize',24);
xlim([0 nr_trials+1])

if SAVE, saveas(gcf,[figdir,'/delays'],'png');end

if DO_STATS
    close all hidden
    trial = repmat([1:nr_trials]',numel(conds)/nr_trials,1);
    [p, tt, stats, terms] = anovan([y1(:);y2(:)],{trial(:)}, ...
        'display', 'on', ...
        'varnames', {'trial'});
    if SAVE,saveas(1,[figdir,'/stats/delays.jpg']);end
end

%% plot proportion of optimal routes

figure; hold on;
y1 = [data(idx_FB).took_optimal_path];
y2 = [data(idx_noFB).took_optimal_path];
errorbar(mean(y1,2),sem(y1,2),'color',GOLD,'linewidth',3)
errorbar(mean(y2,2),sem(y2,2),'color',BLUE,'linewidth',3)
legend('feedback','no feedback','location','southeast')
xlabel('trial','fontsize',36)
ylabel('% optimal routes','fontsize',36)
set(gca,'xtick',5:5:nr_trials,'fontsize',24);
xlim([0 nr_trials+1])

if SAVE, saveas(gcf,[figdir,'/optimal_routes'],'png');end

if DO_STATS
    close all hidden
    conds = [ones(size(y1(:))); zeros(size(y2(:)))];
    trial = repmat([1:nr_trials]',numel(conds)/nr_trials,1);
    [p, tt, stats, terms] = anovan([y1(:);y2(:)],{conds(:) trial(:)}, ...
        'model', 'interaction', ...
        'display', 'on', ...
        'varnames', {'condition','trial'});
    if SAVE,saveas(1,[figdir,'/stats/optimal_routes.jpg']);end
end

%% plot nr clicks before each move

figure; hold on;
y1 = [data(idx_FB).nr_clicks1];
y2 = [data(idx_noFB).nr_clicks1];
errorbar(mean(y1,2),sem(y1,2),'color',GOLD,'linewidth',3)
errorbar(mean(y2,2),sem(y2,2),'color',BLUE,'linewidth',3)
% errorbar(mean([data.nr_clicks2],2),sem([data.nr_clicks2],2),'linewidth',3)
% errorbar(mean([data.nr_clicks3],2),sem([data.nr_clicks3],2),'linewidth',3)
% legend('move 1','move 2','move 3','location','southeast')
legend('feedback','no feedback','location','southeast')
xlabel('trial','fontsize',36)
ylabel('# clicks','fontsize',36)
set(gca,'xtick',5:5:nr_trials,'fontsize',24);
xlim([0 nr_trials+1])

if SAVE, saveas(gcf,[figdir,'/nr_clicks'],'png');end

if DO_STATS
    close all hidden
    conds = [ones(size(y1(:))); zeros(size(y2(:)))];
    trial = repmat([1:nr_trials]',numel(conds)/nr_trials,1);
    [p, tt, stats, terms] = anovan([y1(:);y2(:)],{conds(:) trial(:)}, ...
        'model', 'interaction', ...
        'display', 'on', ...
        'varnames', {'condition','trial'});
    if SAVE,saveas(1,[figdir,'/stats/nr_clicks.jpg']);end
end

%% plot the locations of clicks
clear nr_clicks
clear click_locations
locations = ...
    {[.5,.5],[.7,.5],[.5,.7],[.3,.5],[.5,.3],...
    [.9,.5],[.5,.9],[.1,.5],[.5,.1],...
    [.9,.7],[.9,.3],[.3,.9],[.7,.9],[.1,.7],[.1,.3],[.3,.1],[.7,.1]};
cmap = parula(10000);
for type = 1:2
    for f = 1:2
        figure('position',[0,0,1500,800]);
        if f==1,dat=data(idx_FB);else,dat=data(idx_noFB);end
        for i = 1:nr_trials
            click_locations{i} = [];
            for j = 1:length(dat)
                if type == 1
                    click_locations{i} = [click_locations{i},dat(j).click_locations_before_first_move{i}];
                else
                    click_locations{i} = [click_locations{i},dat(j).click_locations{i}];
                end
            end
        end
        for i = 1:nr_trials
            subplot(4,5,i); hold on;
            %     title(['trial ID ',num2str(i)])
            axis off
            for j = 2:17
                nr_clicks(j-1) = sum(click_locations{i}==j)/length(dat);
            end
            nr_clicks_cmap = nr_clicks-min(nr_clicks);
            nr_clicks_cmap = round(10000*(nr_clicks_cmap)/max(nr_clicks_cmap));
            for j = 2:17
                plot(locations{j}(1),locations{j}(2),'s','MarkerEdgeColor','k','markersize',30,'MarkerFaceColor',cmap(max(1,nr_clicks_cmap(j-1)),:))
                hcb = colorbar;
                set(hcb,'YTick',[0,.5,1],'YTickLabel',[sprintf('%0.2f\n',min(nr_clicks),mean(nr_clicks),max(nr_clicks))])
                %         txt = sprintf('%0.2f',nr_clicks(j-1));
                %         text(locations{j}(1),locations{j}(2),txt(2:4),'horizontalalignment','center')
                rew = trial_properties(i).reward_by_state(j);
                if rew < 0
                    rew = ['-$',num2str(abs(rew))];
                else
                    rew = ['$',num2str(rew)];
                end
                text(locations{j}(1),locations{j}(2),rew,'horizontalalignment','center')
            end
        end
        
        if type == 1
            if SAVE && f==1, saveas(gcf,[figdir,'/click_locations_FB_before1stFlight'],'png');end
            if SAVE && f==2, saveas(gcf,[figdir,'/click_locations_noFB_before1stFlight'],'png');end
        else
            if SAVE && f==1, saveas(gcf,[figdir,'/click_locations_FB_anytime'],'png');end
            if SAVE && f==2, saveas(gcf,[figdir,'/click_locations_noFB_anytime'],'png');end
        end
    end
end

%% check for pruning

types = {'any','all'}; % do they have to click any of the outer nodes, or all?
for t = 1:length(types)
    type = types{t};
    figure; hold on;
    for c = 1:2
        if c == 1
            dat = data(idx_FB);
        else
            dat = data(idx_noFB);
        end
        clicked2_given_clicked1 = nan(length(dat),nr_trials);
        reward_mat = nan(nr_subj,nr_trials,nr_states);
        click1_mat = nan(nr_subj,nr_trials,nr_states);
        click2_mat = nan(nr_subj,nr_trials,nr_states);
        clicked2_given_clicked1 = [];
        trial_IDs=[];
        subject_IDs=[];
        for i = 1:length(dat)
            for j = [dat(i).trialID]'+1
                for k = 2:5
                    cur_rew = trial_properties(j).reward_by_state(k);
                    clicked_inner_state = ismember(k,dat(i).clicks1{j});
                    if ~clicked_inner_state
                        continue
                    end
                    if k == 2
                        outer_states = [6, 10, 11];
                    elseif k == 3
                        outer_states = [7, 12, 13];
                    elseif k == 4
                        outer_states = [8, 14, 15];
                    elseif k == 5
                        outer_states = [9, 16, 17];
                    end
                    clicks = dat(i).clicks2{j};
                    inner_click_idx = find(clicks == k);
                    clicked_outer_states = ismember(outer_states,clicks);
                    if strcmp(type,'all')
                        clicked_outer = all(clicked_outer_states);
                        clicked_inner_before_outer = all(inner_click_idx < ...
                            find(ismember(clicks,outer_states)));
                    elseif strcmp(type,'any')
                        clicked_outer = any(clicked_outer_states);
                        clicked_inner_before_outer = all(inner_click_idx < ...
                            find(ismember(clicks,outer_states(clicked_outer_states))));
                    end
                    if  clicked_outer && clicked_inner_before_outer
                        clicked2_given_clicked1 = [clicked2_given_clicked1; cur_rew, true, i];
                    elseif  ~clicked_outer
                        clicked2_given_clicked1 = [clicked2_given_clicked1; cur_rew, false, i];
                    end
                end
            end
        end
        rew = clicked2_given_clicked1(:,1);
        reward_values=-12.5:5:17.5;
        for b = 1:7
            switch b
                case 1
                    idx = rew <= -10;
                    bin = -12.5;
                case 2
                    idx = rew <= -5 & rew > -10;
                    bin = -7.5;
                case 3
                    idx = rew <= 0 & rew > -5;
                    bin = -2.5;
                case 4
                    idx = rew <= 5 & rew > 0;
                    bin = 2.5;
                case 5
                    idx = rew <= 10 & rew > 5;
                    bin = 7.5;
                case 6
                    idx = rew <= 15 & rew > 10;
                    bin = 12.5;
                case 7
                    idx = rew > 15;
                    bin = 17.5;
            end

            proportion(b) = mean(clicked2_given_clicked1(idx,2));
            if c == 1
                eh = errorbar(bin-.5,1-proportion(b),sem(1-clicked2_given_clicked1(idx,2)),'k','linewidth',3);
                h1 = plot(bin-.5,1-proportion(b),'s','MarkerEdgeColor','k','markersize',18,'MarkerFaceColor',GOLD);
            else
                eh = errorbar(bin+.5,1-proportion(b),sem(1-clicked2_given_clicked1(idx,2)),'k','linewidth',3);
                h2 = plot(bin+.5,1-proportion(b),'s','MarkerEdgeColor','k','markersize',18,'MarkerFaceColor',BLUE);
            end
        end
        
        reward{c,t}=clicked2_given_clicked1(:,1);
        pruned{c,t}=1-clicked2_given_clicked1(:,2);
        subject_nrs{c,t}=clicked2_given_clicked1(:,3);

    end
    xlabel('reward','fontsize',36)
    ylabel('pruning frequency','fontsize',36)
    set(gca,'fontsize',24);
    xlim([-15 20])
    legend([h1,h2],'feedback','no feedback','location','northeast')
    if SAVE, saveas(gcf,[figdir,'/prunning_',type,'_noFB'],'png');end
end

if DO_STATS
%X=[reward{2,1}];
%[b,dev,stats]=glmfit(X,pruned{2,1},'Binomial');

pruning_noFB=pruned{2,1};
stem_reward_noFB=reward{2,1};
subject_noFB=categorical(subject_nrs{2,1});
data_table_noFB=table(pruning_noFB,stem_reward_noFB,subject_noFB);

FB=[zeros(numel(pruning_noFB),1); ones(numel(pruning_FB),1)];
pruning=[pruning_noFB(:);pruning_FB(:)];
stem_reward=[stem_reward_noFB(:);stem_reward_FB(:)];
subject=[subject_noFB(:);subject_FB(:)];
data_table=table(pruning,stem_reward,subject,FB)

pruning_FB=pruned{1,1};
stem_reward_FB=reward{1,1};
subject_FB=categorical(subject_nrs{1,1});
data_table_FB=table(pruning_FB,stem_reward_FB,subject_FB);

glme_noFB = fitglme(data_table_noFB,'pruning_noFB ~ 1+ stem_reward_noFB + subject_noFB')
glme_FB = fitglme(data_table_FB,'pruning_FB ~ 1+ stem_reward_FB + subject_FB')

glme_all= fitglme(data_table,'pruning ~ 1+ stem_reward*FB + FB + subject')
end

%% plot common sets of click locations, for each trial

for f = 1:2
    if f==1,dat=data(idx_FB);else,dat=data(idx_noFB);end
    for i = 1:nr_trials
        clear click_fequencies click_sets
        click_sets{1} = dat(1).click_locations_before_first_move{i};
        click_fequencies(1) = 1;
        for j = 1:length(dat)
            cur_sequence = dat(j).click_locations_before_first_move{i};
            % make leaf node pairs on the same branch equivalent
            cur_sequence(cur_sequence==11) = 10;
            cur_sequence(cur_sequence==13) = 12;
            cur_sequence(cur_sequence==15) = 14;
            cur_sequence(cur_sequence==17) = 16;
            cur_sequence = sort(cur_sequence);
            plus1 = true;
            for k = 1:length(click_sets)
                if length(click_sets{k})==length(cur_sequence) && all(click_sets{k}==cur_sequence)
                    plus1 = false;
                    click_fequencies(k) = click_fequencies(k) + 1;
%                     break
                end
            end
            if plus1
                click_sets = vertcat(click_sets,cur_sequence);
                click_fequencies(end+1) = 1;
            end
        end
        [click_fequencies, ix] = sort(click_fequencies,'descend');
        figure('position',[0,0,450,450]);
        for h = 1:4
            subplot(2,2,h); hold on; axis off;
            xlim([-.05 1.05]); ylim([-.05 1.05])
            if click_fequencies(h) < 2
                break
            end
            title(['frequency: ',sprintf('%0.2f',click_fequencies(h)/nr_subj)]);
            skip = false;
            for l = 2:17
                if skip
                    skip = false;
                    text(locations{l}(1),locations{l}(2),rew,'horizontalalignment','center')
                    continue
                end
                rew = trial_properties(i).reward_by_state(l);
                if rew < 0
                    rew = ['-$',num2str(abs(rew))];
                else
                    rew = ['$',num2str(rew)];
                end
                if ismember(l,click_sets{ix(h)})
                    % indicate equivalence of leaf nodes
                    if l == 10 && sum(click_sets{ix(h)}==10)==1
                        plot(locations{10}(1),locations{10}(2),'s','MarkerEdgeColor','k','markersize',30,'MarkerFaceColor',mean([GOLD;BLUE]))
                        plot(locations{11}(1),locations{11}(2),'s','MarkerEdgeColor','k','markersize',30,'MarkerFaceColor',mean([GOLD;BLUE]))
                        skip = true;
                    elseif l == 12 && sum(click_sets{ix(h)}==12)==1
                        plot(locations{12}(1),locations{12}(2),'s','MarkerEdgeColor','k','markersize',30,'MarkerFaceColor',mean([GOLD;BLUE]))
                        plot(locations{13}(1),locations{13}(2),'s','MarkerEdgeColor','k','markersize',30,'MarkerFaceColor',mean([GOLD;BLUE]))
                        skip = true;
                    elseif l == 14 && sum(click_sets{ix(h)}==14)==1
                        plot(locations{14}(1),locations{14}(2),'s','MarkerEdgeColor','k','markersize',30,'MarkerFaceColor',mean([GOLD;BLUE]))
                        plot(locations{15}(1),locations{15}(2),'s','MarkerEdgeColor','k','markersize',30,'MarkerFaceColor',mean([GOLD;BLUE]))
                        skip = true;
                    elseif l == 16 && sum(click_sets{ix(h)}==16)==1
                        plot(locations{16}(1),locations{16}(2),'s','MarkerEdgeColor','k','markersize',30,'MarkerFaceColor',mean([GOLD;BLUE]))
                        plot(locations{17}(1),locations{17}(2),'s','MarkerEdgeColor','k','markersize',30,'MarkerFaceColor',mean([GOLD;BLUE]))
                        skip = true;
                    else
                        plot(locations{l}(1),locations{l}(2),'s','MarkerEdgeColor','k','markersize',30,'MarkerFaceColor',GOLD)
                    end
                    text(locations{l}(1),locations{l}(2),rew,'horizontalalignment','center')
                else %~(skip11 && l==11) || ~(skip13 && l==13) || ~(skip15 && l==15) || ~(skip17 && l==17)
                    plot(locations{l}(1),locations{l}(2),'s','MarkerEdgeColor','k','markersize',30,'MarkerFaceColor',BLUE)
                    text(locations{l}(1),locations{l}(2),rew,'horizontalalignment','center','color',[.99,.99,.99])
                end
            end
        end
        if SAVE && f==1, saveas(gcf,[figdir,'/click_sets_trial',num2str(i),'_FB'],'png');end
        if SAVE && f==2, saveas(gcf,[figdir,'/click_sets_trial',num2str(i),'_noFB'],'png');end
    end
end