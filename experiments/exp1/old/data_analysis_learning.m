cd('~/Dropbox/PhD/Metacognitive RL/mcrl-experiment')
clear
%%

%experiment_version = 'C';
experiment_version = 'D';

BLUE = [0,50,98]/255;
GOLD = [253,181,21]/255;
SAVE = false;
DO_STATS = true;
figdir = ['~/Dropbox/PhD/Metacognitive RL/mcrl-experiment/figures/',experiment_version,'/'];
if SAVE && ~exist(figdir,'dir')
    mkdir(figdir)
    mkdir([figdir,'stats/'])
end

import_data

if strcmp(experiment_version,'D')
    idx_FB = [data.condition]==1;
    idx_noFB = [data.condition]==0;
    idx_dlyFB = [data.condition]==2;
    idx_msgFB = [data.condition]==3;
    
    with_delay=ismember([data.condition],[1,2]);
    with_message=ismember([data.condition],[1,3]);
elseif strcmp(experiment_version,'C')
    idx_FB = [data.condition]==1;
    idx_noFB = [data.condition]==0;
end

addpath('../')

%% plot reward vs. number of clicks

fig=figure; hold on;
clicksFB = [data(idx_FB).nr_clicks1];
clicksNoFB = [data(idx_noFB).nr_clicks1];
rewFB = [data(idx_FB).score];
rewNoFB = [data(idx_noFB).score];
plot(clicksFB(:)-.05,rewFB(:),'.','color',GOLD)
plot(clicksNoFB(:)+.05,rewNoFB(:),'.','color',BLUE)
xlabel({'# clicks' 'before 1^{st} move'},'FontSize',24)
ylabel('relative reward','FontSize',24)
set(gca,'FontSize',24)
xlim([-.2 16.2])

X = [ones(size(clicksFB(:))), clicksFB(:)];
[b,bint,r,rint,stats]=regress(rewFB(:),X);
l1 = plot([0 16],[b(1) (b(2)*16+b(1))],'--','linewidth',2,'color',GOLD);
text(1,-6,['slope=',sprintf('%0.3f',b(2)),' p=',sprintf('%0.6f',stats(3))])
X = [ones(size(clicksNoFB(:))), clicksNoFB(:)];
[b,bint,r,rint,stats]=regress(rewNoFB(:),X);
l2 = plot([0 16],[b(1) (b(2)*16+b(1))],'--','linewidth',2,'color',BLUE);
text(1,-9,['slope=',sprintf('%0.3f',b(2)),' p=',sprintf('%0.6f',stats(3))])
legend([l1,l2],'feedback','no feedback')
if SAVE, saveas(gcf,[figdir,'/reward_vs_clicks'],'png');end

%% plot relative reward

figure; hold on;
y1 = [data(idx_FB).relative_reward];
y2 = [data(idx_noFB).relative_reward];
errorbar(mean(y1,2),sem(y1,2),'color',GOLD,'linewidth',3)
errorbar(mean(y2,2),sem(y2,2),'color',BLUE,'linewidth',3)
set(gca,'FontSize',24)
legend('feedback','no feedback','location','southeast')
xlabel('trial','FontSize',24)
ylabel('relative reward','FontSize',24)
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
    
    nr_subjects=[size(y1,2),size(y2,2)];
    trial_numbers1=repmat((1:nr_trials)',[1,nr_subjects(1)])
    X1=[trial_numbers1(:),ones(numel(trial_numbers1),1)];
    mdl_FB = fitnlm(X1,y1(:),'y~ sigmoid(b1*x1+b2*x2)' ,[0.5;0.05])
    
    trial_numbers2=repmat((1:nr_trials)',[1,nr_subjects(2)])
    X2=[trial_numbers2(:),ones(numel(trial_numbers2),1)];
    mdl_noFB = fitnlm(X2,y2(:),'y~ sigmoid(b1*x1+b2*x2)' ,[0.5;0.05])
    
    trial_numbers3=[trial_numbers1,trial_numbers2];
    condition=[ones(numel(trial_numbers1),1);zeros(numel(trial_numbers2),1)];
    
    
    y3=[y1,y2];
    
    if strcmp(experiment_version,'D')
        X3=[trial_numbers3(:),with_delay(:),with_message(:)];
        relative_reward_both = fitnlm(X3,y3(:),'y ~ (1-b1)*sigmoid(b2+x1*(b3+b4*x2+b5*x3+b6*x2*x3))',[0.01;0.01;0.25;0.2])
    elseif strcmp(experiment_version,'C')
        X3=[trial_numbers3(:),condition(:)];
        relative_reward_both = fitnlm(X3,y3(:),'y ~ (1-b1)*sigmoid(b2+x1*(b3+b4*x2))',[0.01;0.01;0.25;0.2])        
    end
    BIC_full=relative_reward_both.ModelCriterion.BIC;
    RSS_full=sum(relative_reward_both.Residuals.Raw.^2);
    DF_full=relative_reward_both.DFE;
    
    relative_reward_restricted = fitnlm(X3,y3(:),'y ~ (1-b1)*sigmoid(b2+x1*(b3+0*x2))',[0.01;0.01;0.25])
    BIC_restricted=relative_reward_restricted.ModelCriterion.BIC;
    RSS_restricted=sum(relative_reward_restricted.Residuals.Raw.^2);
    DF_restricted=relative_reward_restricted.DFE;

    F=(RSS_restricted-RSS_full)/(DF_restricted-DF_full)/(RSS_full/DF_full);
    DF_N=DF_restricted-DF_full;
    p=1-fcdf(F,DF_N,DF_full);

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
xlabel('trial','fontsize',24)
ylabel('delay after 1^{st} move (sec)','fontsize',24)
set(gca,'FontSize',24)
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
set(gca,'FontSize',24)
legend('feedback','no feedback','location','southeast')
xlabel('trial','FontSize',24)
ylabel('% optimal routes','FontSize',24)
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
    
    nr_subjects=[size(y1,2),size(y2,2)];
    trial_numbers1=repmat((1:nr_trials)',[1,nr_subjects(1)])
    X1=[trial_numbers1(:),ones(numel(trial_numbers1),1)];
    mdl_FB = fitnlm(X1,y1(:),'y~ sigmoid(b1*x1+b2*x2)' ,[0.5;0.05])
    
    trial_numbers2=repmat((1:nr_trials)',[1,nr_subjects(2)])
    X2=[trial_numbers2(:),ones(numel(trial_numbers2),1)];
    mdl_noFB = fitnlm(X2,y2(:),'y~ sigmoid(b1*x1+b2*x2)' ,[0.5;0.05])
    
    trial_numbers3=[trial_numbers1,trial_numbers2];
    condition=[ones(numel(trial_numbers1),1);zeros(numel(trial_numbers2),1)];
    X3=[trial_numbers3(:),condition];
    y3=[y1,y2];
    optimal_routes_both = fitnlm(X3,y3(:),'y~ (1-b1)*sigmoid(b2+(b3+b4*x2)*x1)' ,[0.1;0.1;0.05;0.01])
    
    BIC_full=optimal_routes_both.ModelCriterion.BIC;
    RSS_full=sum(optimal_routes_both.Residuals.Raw.^2);
    DF_full=optimal_routes_both.DFE;

       
    routes_restricted = fitnlm(X3,y3(:),'y~ (1-b1)*sigmoid(b2+(b3+0*x2)*x1)' ,[0.1;0.1;0.05])
    BIC_restricted=routes_restricted.ModelCriterion.BIC;
    RSS_restricted=sum(routes_restricted.Residuals.Raw.^2);
    DF_restricted=routes_restricted.DFE;

    F=(RSS_restricted-RSS_full)/(DF_restricted-DF_full)/(RSS_full/DF_full);
    DF_N=DF_restricted-DF_full;
    p=1-fcdf(F,DF_N,DF_full);
    
    
end

%% plot nr clicks before each move

figure; hold on;
y1 = [data(idx_FB).nr_clicks1];
y2 = [data(idx_noFB).nr_clicks1];
errorbar(mean(y1,2),sem(y1,2),'color',GOLD,'linewidth',3)
errorbar(mean(y2,2),sem(y2,2),'color',BLUE,'linewidth',3)
set(gca,'FontSize',24)
% errorbar(mean([data.nr_clicks2],2),sem([data.nr_clicks2],2),'linewidth',3)
% errorbar(mean([data.nr_clicks3],2),sem([data.nr_clicks3],2),'linewidth',3)
% legend('move 1','move 2','move 3','location','southeast')
legend('feedback','no feedback','location','southeast')
xlabel('trial','FontSize',24)
ylabel({'# clicks' 'before 1^{st} move'},'FontSize',24)
if SAVE, saveas(gcf,[figdir,'/nr_clicks'],'png');end

if DO_STATS
    close all hidden
    conds = [ones(size(y1(:))); zeros(size(y2(:)))];
    trial = repmat([1:nr_trials]',numel(conds)/nr_trials,1);
    [p, tt, stats, terms] = anovan([y1(:);y2(:)],{conds(:) trial(:)}, ...
        'model', 'interaction', ...
        'display', 'on', ...
        'varnames', {'condition','trial'});
    if SAVE,saveas(1,[figdir,'/stats/optimal_routes.jpg']);end
    
    y1_rel=y1/16;
    y2_rel=y2/16;
    nr_subjects=[size(y1_rel,2),size(y2_rel,2)];
    trial_numbers1=repmat((1:nr_trials)',[1,nr_subjects(1)]);
    
    X1=[trial_numbers1(:),ones(numel(trial_numbers1),1)];
    mdl_FB = fitnlm(X1,y1_rel(:),'y~ sigmoid(b1*x1+b2*x2)' ,[0.05;0.5])
    
    trial_numbers2=repmat((1:nr_trials)',[1,nr_subjects(2)])
    X2=[trial_numbers2(:),ones(numel(trial_numbers2),1)];
    mdl_noFB = fitnlm(X2,y2_rel(:),'y~ sigmoid(b1*x1+b2*x2)' ,[0.05;0.5])
    
    trial_numbers3=[trial_numbers1,trial_numbers2];
    condition=[ones(numel(trial_numbers1),1);zeros(numel(trial_numbers2),1)];
    X3=[trial_numbers3(:),condition,ones(numel(trial_numbers3),1)];
    y3_rel=[y1_rel,y2_rel];
    nr_clicks_both = fitnlm(X3,y3_rel(:),'y~ (1-b1)*sigmoid((b2+b3*x2)*x1+b4*x3)' ,[0.01;0.01;0.25;0.2])
    
    BIC_full=nr_clicks_both.ModelCriterion.BIC;
    RSS_full=sum(nr_clicks_both.Residuals.Raw.^2);
    DF_full=nr_clicks_both.DFE;
    
    restricted_model=  fitnlm(X3,y3_rel(:),'y~ (1-b1)*sigmoid((b2+0*x2)*x1+b3*x3)' ,[0.01;0.01;0.2])
    RSS_restricted=sum(restricted_model.Residuals.Raw.^2)
    DF_restricted=restricted_model.DFE;
    BIC_restricted=restricted_model.ModelCriterion.BIC
    
    delta_BIC=BIC_restricted-BIC_full
    F=(RSS_restricted-RSS_full)/(DF_restricted-DF_full)/(RSS_full/DF_full);
    DF_N=DF_restricted-DF_full;
    p=1-fcdf(F,DF_N,DF_full);
    %A model comparison against the restricted version of the model with
    %$\beta_3=0$ confirmed that the term $\beta_3\cdot X_2$ was necessary
    %(BIC_full=446.82, BIC_restricted=85.99, F(1,1196)=95.39, p<10^{-15}).
    
end

%% plot the locations of clicks (before the first move)
clear nr_clicks

locations = ...
    {[.5,.5],[.7,.5],[.5,.7],[.3,.5],[.5,.3],...
    [.9,.5],[.5,.9],[.1,.5],[.5,.1],...
    [.9,.7],[.9,.3],[.7,.9],[.3,.9],[.1,.7],[.1,.3],[.7,.1],[.3,.1]};
cmap = parula(10000);

clear click_locations
for f = 1:2
figure('position',[0,0,1000,800]);
if f==1,dat=data(idx_FB);else,dat=data(idx_noFB);end
for i = 1:nr_trials
    click_locations{i} = [];
    for j = 1:length(dat)
        click_locations{i} = [click_locations{i},dat(j).click_locations{i}];
    end
end
for i = 1:nr_trials
    subplot(4,5,i); hold on;
    title(['trial ID ',num2str(i)])
    axis off
    for j = 2:17
        nr_clicks(j-1) = sum(click_locations{i}==j)/nr_subj;
    end
    nr_clicks_cmap = nr_clicks-min(nr_clicks);
    nr_clicks_cmap = round(10000*(nr_clicks_cmap)/max(nr_clicks_cmap));
    for j = 2:17
        plot(locations{j}(1),locations{j}(2),'s','MarkerEdgeColor','k','markersize',30,'MarkerFaceColor',cmap(max(1,nr_clicks_cmap(j-1)),:))
%         txt = sprintf('%0.2f',nr_clicks(j-1));
%         text(locations{j}(1),locations{j}(2),txt(2:4),'horizontalalignment','center')
        text(locations{j}(1),locations{j}(2),num2str(trial_properties(i).reward_by_state(j-1)),'horizontalalignment','center')
    end
end

if SAVE && f==1, saveas(gcf,[figdir,'/click_locations_FB'],'png');end
if SAVE && f==2, saveas(gcf,[figdir,'/click_locations_noFB'],'png');end
end

%% check for pruning

% clicked2_given_clicked1 = nan(length(data),nr_trials);
% reward_mat = nan(nr_subj,nr_trials,nr_states);
% click1_mat = nan(nr_subj,nr_trials,nr_states);
% click2_mat = nan(nr_subj,nr_trials,nr_states);
% 
% clicked2_given_clicked1 = [];
% for i = 1:nr_subj
%     for j = [data(i).trialID]'+1
%         for k = 2:5
%             cur_rew = trial_properties(j).reward_by_state(k);
%             clicked_inner_state = ismember(k,data(i).clicks1{j});
%             if k == 2
%                 outer_states = [6, 10, 11];
%             elseif k == 3
%                 outer_states = [7, 12, 13];
%             elseif k == 4
%                 outer_states = [8, 14, 15];
%             elseif k == 5
%                 outer_states = [9, 16, 17];
%             end
%             clicked_outer_state = any(ismember(outer_states,data(i).clicks2{j}));
%             if clicked_inner_state && clicked_outer_state
%                 clicked2_given_clicked1 = [clicked2_given_clicked1; cur_rew, true];
%             elseif clicked_inner_state && ~clicked_outer_state
%                 clicked2_given_clicked1 = [clicked2_given_clicked1; cur_rew, false];
%             end
%         end
%     end
% end
% rew = clicked2_given_clicked1(:,1);
% for bin = 1:7
%     switch bin
%         case 1
%             idx = rew < -10;
%         case 2
%             idx = rew < -5 && rew >= -10;
%         case 3
%             idx = rew < 0 && rew >= -5;
%         case 4
%             idx = rew < 5 && rew >= -10;
%         case 5
%             idx = rew < 10 && rew >= -10;
%         case 6
%             idx = rew < 15 && rew >= -10;
%         case 7
%             idx = rew >= -10;
%     end
% end
% [B,dev,stats] = mnrfit(clicked2_given_clicked1(:,1),clicked2_given_clicked1(:,2));


% k = 0;
% for i = 1:nr_subj
%     for j = [data(i).trialID]'+1
%         k = k+1;
%         clicks1 = data(i).clicks1{j};
%         clicks2 = data(i).clicks2{j};
%         click1_mat(i,j,1:length(clicks1)) = clicks1;
%         click2_mat(i,j,1:length(clicks2)) = clicks2;
%         reward_mat(i,j,:) = trial_properties(j).reward_by_state;
% %         if data(i).cli
% %         clicked2_given_clicked1(i,j) = 
%     end
% end
% 
% click1_mat = click1_mat(:);
% click2_mat = click2_mat(:);
% reward_mat = reward_mat(:);



% figure,
% plot(reward_mat,