cd('~/Dropbox/PhD/Metacognitive RL/mcrl-experiment')
clear
%%

experiment_version = 'B';

BLUE = [0,50,98]/255;
GOLD = [253,181,21]/255;
SAVE = true;
DO_STATS = true;
figdir = ['~/Dropbox/PhD/Metacognitive RL/mcrl-experiment/figures/',experiment_version,'/'];
if SAVE && ~exist(figdir,'dir')
    mkdir(figdir)
    mkdir([figdir,'stats/'])
end

if strcmp(experiment_version,'1E')
    load('data_1D');
    data_1D = data;
    load('data_1E');
    data_1E = data;
    data = [data_1D,data_1E];
else
    import_data
end

% conditions: 0: no FB, no break; 1: no FB, 10min break; 2: FB, no break; 3: FB, 10min break
idx0 = [data.condition]==0;
idx1 = [data.condition]==1;
idx2 = [data.condition]==2;
idx3 = [data.condition]==3;
idx4 = [data.condition]==4;
if strcmp(experiment_version,'1E')
    legendStr = {'feedback','no feedback','delay feedback','message feedback','object-level delays'};
    legendOrd = '[h1,h0,h2,h3,h4]';
    colorOrd = {'BLUE','GOLD','BLUE','BLUE','BLUE'};
    linestyleOrd = {'--','-',':','-.','-'};
else
    legendStr = {'feedback','no feedback','delay feedback','message feedback','object-level delays'};
    legendOrd = '[h1,h0,h2,h3]';
    colorOrd = {'BLUE','GOLD','BLUE','BLUE','BLUE'};
    linestyleOrd = {'--','-',':','-.','-'};
end

addpath('../')

%% plot reward vs. number of clicks

figure; hold on;
clicks0 = [data(idx0).nr_clicks1];
clicks1 = [data(idx1).nr_clicks1];
clicks2 = [data(idx2).nr_clicks1];
clicks3 = [data(idx3).nr_clicks1];
clicks4 = [data(idx4).nr_clicks1];
rew0 = [data(idx0).score];
rew1 = [data(idx1).score];
rew2 = [data(idx2).score];
rew3 = [data(idx3).score];
rew4 = [data(idx4).score];
plot(clicks0(:)-.05,rew0(:),'.','color',eval(colorOrd{1}))
plot(clicks1(:)+.05,rew1(:),'.','color',eval(colorOrd{2}))
plot(clicks2(:)+.15,rew2(:),'.','color',eval(colorOrd{3}))
plot(clicks3(:)+.25,rew3(:),'.','color',eval(colorOrd{4}))
plot(clicks4(:)+.35,rew4(:),'.','color',eval(colorOrd{5}))
xlabel({'# clicks' 'before 1^{st} move'},'FontSize',18)
ylabel('reward ($)','FontSize',18)
xlim([-.2 16.2])

X = [ones(size(clicks0(:))), clicks0(:)];
[b,bint,r,rint,stats]=regress(rew0(:),X);
h0 = plot([0 16],[b(1) (b(2)*16+b(1))],linestyleOrd{1},'linewidth',2,'color',eval(colorOrd{1}));
text(1,-6,['slope=',sprintf('%0.3f',b(2)),' p=',sprintf('%0.6f',stats(3))])
X = [ones(size(clicks1(:))), clicks1(:)];
[b,bint,r,rint,stats]=regress(rew1(:),X);
h1 = plot([0 16],[b(1) (b(2)*16+b(1))],linestyleOrd{2},'linewidth',2,'color',eval(colorOrd{2}));
text(1,-9,['slope=',sprintf('%0.3f',b(2)),' p=',sprintf('%0.6f',stats(3))])
X = [ones(size(clicks2(:))), clicks2(:)];
[b,bint,r,rint,stats]=regress(rew2(:),X);
h2 = plot([0 16],[b(1) (b(2)*16+b(1))],linestyleOrd{3},'linewidth',2,'color',eval(colorOrd{3}));
text(12,-6,['slope=',sprintf('%0.3f',b(2)),' p=',sprintf('%0.6f',stats(3))])
X = [ones(size(clicks3(:))), clicks3(:)];
[b,bint,r,rint,stats]=regress(rew3(:),X);
h3 = plot([0 16],[b(1) (b(2)*16+b(1))],linestyleOrd{4},'linewidth',2,'color',eval(colorOrd{4}));
text(12,-9,['slope=',sprintf('%0.3f',b(2)),' p=',sprintf('%0.6f',stats(3))])
X = [ones(size(clicks4(:))), clicks4(:)];
[b,bint,r,rint,stats]=regress(rew4(:),X);
h4 = plot([0 16],[b(1) (b(2)*16+b(1))],linestyleOrd{5},'linewidth',2,'color',eval(colorOrd{5}));
text(12,-9,['slope=',sprintf('%0.3f',b(2)),' p=',sprintf('%0.6f',stats(3))])
legend(eval(legendOrd),legendStr,'location','southeast')
if SAVE, saveas(gcf,[figdir,'/reward_vs_clicks'],'png');end

%% plot relative reward

figure; hold on;
y0 = [data(idx0).relative_reward]; %optimal feedback
y1 = [data(idx1).relative_reward]; %no feedback
y2 = [data(idx2).relative_reward]; %delay feedback
y3 = [data(idx3).relative_reward]; %message feedback
y4 = [data(idx4).relative_reward]; %delays based on object-level PRs
h0 = errorbar(mean(y0,2),sem(y0,2),linestyleOrd{1},'color',eval(colorOrd{1}),'linewidth',3);
h1 = errorbar(mean(y1,2),sem(y1,2),linestyleOrd{2},'color',eval(colorOrd{2}),'linewidth',3);
h2 = errorbar(mean(y2,2),sem(y2,2),linestyleOrd{3},'color',eval(colorOrd{3}),'linewidth',3);
h3 = errorbar(mean(y3,2),sem(y3,2),linestyleOrd{4},'color',eval(colorOrd{4}),'linewidth',3);
h4 = errorbar(mean(y4,2),sem(y4,2),linestyleOrd{5},'color',eval(colorOrd{5}),'linewidth',3);
legend(eval(legendOrd),legendStr,'location','southeast')
xlabel('trial','fontsize',36)
ylabel('relative reward','fontsize',36)
set(gca,'xtick',1:1:nr_trials,'fontsize',24);
xlim([0 nr_trials+1])

if SAVE, saveas(gcf,[figdir,'/relative_reward'],'png');end

if DO_STATS
    %     Group = [repmat('F',sum(idx0),1);repmat('C',sum(idx1),1)];
    %     Y = [y0';y1'];
    %     t = table(Group,Y(:,1),Y(:,2),Y(:,3),Y(:,4),Y(:,5),Y(:,6),Y(:,7),Y(:,8),Y(:,9),Y(:,10),Y(:,11),Y(:,12),Y(:,13),Y(:,14),Y(:,15),Y(:,16),Y(:,17),Y(:,18),Y(:,19),Y(:,20),...
    %         'VariableNames',{'Group','t1','t2','t3','t4','t5','t6','t7','t8','t9','t10','t11','t12','t13','t14','t15','t16','t17','t18','t19','t20'});
    %     Time = [1:20]';
    %     rm = fitrm(t,'t1-t20 ~ Group','WithinDesign',Time);
    close all hidden
    
    if strcmp(experiment_version,'1D')
        conds = [zeros(size(y0(:))); ones(size(y1(:))); 2*ones(size(y2(:))); 3*ones(size(y3(:))); 4*ones(size(y4(:)))];
    elseif strcmp(experiment_version,'1E')
        conds = [zeros(size(y1(:))); ones(size(y4(:)))];
        nr_subj=size(y1,2)+size(y4,2);
    end
    
    trial = repmat([1:nr_trials]',numel(conds)/nr_trials,1);
    subjs = repmat(1:nr_subj,nr_trials,1);
    
    
    if strcmp(experiment_version,'1E')
        [p, tt, stats, terms] = anovan([y1(:);y4(:)],{conds(:),trial(:)}, ...
            'model', 'interaction', ...
            'display', 'on', ...
            'varnames', {'condition','trial'});%,'subject'
        [h,p,ci,stats]=ttest2(y2(:),y4(:));
        
        
        %Test whether delays based on meta-level PRs are more effective than
        %delays based on object-level PRs
        
        y=[y2,y4];
        PR_type_factor=[zeros(size(y2)),ones(size(y4))];
        X=[trial(:),PR_type_factor(:)];
        
        model = fitnlm(X,y(:),'y ~ (1-b1)*sigmoid(b2+x1*(b3+b4*x2))',[0.01;0.01;0.25;0.2])
        BIC_full=model.ModelCriterion.BIC;
        RSS_full=sum(model.Residuals.Raw.^2);
        DF_full=model.DFE;
    end
    
    %'feedback','no feedback','delay feedback','messsage feedback'
    
    if strcmp(experiment_version,'1D')
        y=[y0,y1,y2,y3,y4];
        
        [p, tt, stats, terms] = anovan([y0(:);y1(:);y2(:);y3(:);y4(:)],{conds(:),trial(:)}, ...
            'model', 'interaction', ...
            'display', 'on', ...
            'varnames', {'condition','trial'});%,'subject'
        
        %y=[y1,y4];
        delay_factor=[ones(size(y0)),zeros(size(y1)),ones(size(y2)),zeros(size(y3)),ones(size(y4))];
        message_factor=[ones(size(y0)),zeros(size(y1)),zeros(size(y2)),ones(size(y3)),ones(size(y4))];
        %objPR_factor=[zeros(size(y1)),ones(size(y4))];
        X=[trial(:),delay_factor(:),message_factor(:)];
        %    X=[trial(:),objPR_factor(:)];
        
        [BICs_reward,models_reward,RSS_reward,DF_reward]=...
            modelSelectionLearningCurves(X,y)
        
        F=(RSS_reward(6)-RSS_reward(2))/(DF_reward(6)-DF_reward(2))/...
            (RSS_reward(2)/DF_reward(2));
        DF_N=DF_reward(6)-DF_reward(2);
        p=1-fcdf(F,DF_N,DF_reward(2));
        
        %The best model included both feedback variables but not their interaction (BIC 277.2).
        %According to the BIC, the full model (BIC 283.4) and the restricted models that excluded one
        %or both of the feedback factors (BIC >285.7) explained the data signficantly
        %less well.
    end
    
    if SAVE,saveas(1,[figdir,'/stats/relative_reward.jpg']);end
end
%% plot delays after first move

figure; hold on;
y0 = [data(idx0).delays1];
y1 = [data(idx1).delays1];
y2 = [data(idx2).delays1];
y3 = [data(idx3).delays1];
y4 = [data(idx4).delays1];
h0 = errorbar(mean(y0,2),sem(y0,2),linestyleOrd{1},'color',eval(colorOrd{1}),'linewidth',3);
h1 = errorbar(mean(y1,2),sem(y1,2),linestyleOrd{2},'color',eval(colorOrd{2}),'linewidth',3);
h2 = errorbar(mean(y2,2),sem(y2,2),linestyleOrd{3},'color',eval(colorOrd{3}),'linewidth',3);
h3 = errorbar(mean(y3,2),sem(y3,2),linestyleOrd{4},'color',eval(colorOrd{4}),'linewidth',3);
h4 = errorbar(mean(y4,2),sem(y4,2),linestyleOrd{5},'color',eval(colorOrd{5}),'linewidth',3);
legend(eval(legendOrd),legendStr)
xlabel('trial','fontsize',36)
ylabel('delay after 1^{st} move (sec)','fontsize',36)
set(gca,'xtick',1:1:nr_trials,'fontsize',24);
xlim([0 nr_trials+1])

if SAVE, saveas(gcf,[figdir,'/delays'],'png');end

if DO_STATS
    close all hidden
    trial = repmat([1:nr_trials]',numel(conds)/nr_trials,1);
    
    if strcmp(experiment_version,'1D')
        [p, tt, stats, terms] = anovan([y0(:);y1(:);y2(:);y3(:)],{trial(:),condition(:)}, ...
            'display', 'on', ...
            'varnames', {'trial','condition'});
        if SAVE,saveas(1,[figdir,'/stats/delays.jpg']);end
        
        y=[y0,y1,y2,y3,y4];
        [mean(y0(:)),mean(y1(:)),mean(y2(:)),mean(y3(:));
            sem(y0(:)),sem(y1(:)),sem(y2(:)),sem(y3(:))]
        
        [median(y0(:)),median(y1(:)),median(y2(:)),median(y3(:))]
        
        delay_factor=[ones(size(y0)),zeros(size(y1)),ones(size(y2)),zeros(size(y3))];
        message_factor=[ones(size(y0)),zeros(size(y1)),zeros(size(y2)),ones(size(y3))];
        X=[trial(:),delay_factor(:),message_factor(:)];
        delay_model = fitnlm(X,y(:),'y ~ b1+exp(b2-x1*(b3+b4*x2+b5*x3+b6*x2*x3))',[0.01;0.01;0.25;0.2;0.2;0.2])
        BIC_delay_full=delay_model.ModelCriterion.BIC;
        RSS_full=sum(delay_model.Residuals.Raw.^2);
        DF_full=delay_model.DFE;
        
        delay_model_restricted1 = fitnlm(X,y(:),'y ~ b1+exp(b2-x1*(b3+b4*x2+b5*x3))',[0.01;0.01;0.25;0.2;0.2])
        BIC_delay_restricted(1)=delay_model_restricted1.ModelCriterion.BIC;
        RSS_restricted1=sum(delay_model_restricted1.Residuals.Raw.^2);
        DF_restricted1=delay_model_restricted1.DFE;
        
        delay_model_restricted2 = fitnlm(X,y(:),'y ~ b1+exp(b2-x1*(b3+b4*x2+0*x3))',[0.01;0.01;0.25;0.2])
        BIC_delay_restricted(2)=delay_model_restricted2.ModelCriterion.BIC;
        RSS_restricted2=sum(delay_model_restricted2.Residuals.Raw.^2);
        DF_restricted2=delay_model_restricted2.DFE;
        
        
        delay_model_restricted3 = fitnlm(X,y(:),'y ~ b1+exp(b2-x1*(b3+0*x2+b4*x3))',[0.01;0.01;0.25;0.2])
        BIC_delay_restricted(3)=delay_model_restricted3.ModelCriterion.BIC;
        RSS_restricted3=sum(delay_model_restricted3.Residuals.Raw.^2);
        DF_restricted3=delay_model_restricted3.DFE;
        
        delay_model_restricted4 = fitnlm(X,y(:),'y ~ b1+exp(b2-x1*(b3+0*x2+0*x3))',[0.01;0.01;0.25])
        BIC_delay_restricted(4)=delay_model_restricted4.ModelCriterion.BIC;
        RSS_restricted4=sum(delay_model_restricted4.Residuals.Raw.^2);
        DF_restricted4=delay_model_restricted4.DFE;
        
        delay_model_restricted5 = fitnlm(X,y(:),'y ~ 0+exp(b1-x1*(b2+0*x2+0*x3))',[0.01;0.25])
        BIC_delay_restricted(5)=delay_model_restricted5.ModelCriterion.BIC;
        RSS_restricted5=sum(delay_model_restricted5.Residuals.Raw.^2);
        DF_restricted5=delay_model_restricted5.DFE;
        
        delay_model_restricted6 = fitnlm(X,y(:),'y ~ 0+exp(b1-x1*(0+0*x2+0*x3))',[0.01])
        BIC_delay_restricted(6)=delay_model_restricted6.ModelCriterion.BIC;
        RSS_restricted6=sum(delay_model_restricted6.Residuals.Raw.^2);
        DF_restricted6=delay_model_restricted6.DFE;
        
        BICs_delay=[BIC_delay_full,BIC_delay_restricted];
    end
    
end

%% plot proportion of optimal routes

figure; hold on;
y0 = [data(idx0).took_optimal_path];
y1 = [data(idx1).took_optimal_path];
y2 = [data(idx2).took_optimal_path];
y3 = [data(idx3).took_optimal_path];
y4 = [data(idx4).took_optimal_path];
h0 = errorbar(mean(y0,2),sem(y0,2),linestyleOrd{1},'color',eval(colorOrd{1}),'linewidth',3);
h1 = errorbar(mean(y1,2),sem(y1,2),linestyleOrd{2},'color',eval(colorOrd{2}),'linewidth',3);
h2 = errorbar(mean(y2,2),sem(y2,2),linestyleOrd{3},'color',eval(colorOrd{3}),'linewidth',3);
h3 = errorbar(mean(y3,2),sem(y3,2),linestyleOrd{4},'color',eval(colorOrd{4}),'linewidth',3);
h4 = errorbar(mean(y4,2),sem(y4,2),linestyleOrd{5},'color',eval(colorOrd{5}),'linewidth',3);
legend(eval(legendOrd),legendStr,'location','southeast')
xlabel('trial','fontsize',36)
ylabel('% optimal routes','fontsize',36)
set(gca,'xtick',1:1:nr_trials,'fontsize',24);
xlim([0 nr_trials+1])

if SAVE, saveas(gcf,[figdir,'/optimal_routes'],'png');end

if DO_STATS
    close all hidden
    
    if strcmp(experiment_version,'1D')
        conds = [zeros(size(y0(:))); ones(size(y1(:))); 2*ones(size(y2(:))); 3*ones(size(y3(:))); 4*ones(size(y4(:)))]
        trial = repmat([1:nr_trials]',numel(conds)/nr_trials,1);
        
        y=[y0,y1,y2,y3];
    elseif strcmp(experiment_version,'1E')
        y=[y2,y4];
    end
    
    [p, tt, stats, terms] = anovan(y(:),{conds(:) trial(:)}, ...
        'model', 'interaction', ...
        'display', 'on', ...
        'varnames', {'condition','trial'});
    if SAVE,saveas(1,[figdir,'/stats/optimal_routes.jpg']);end
    
    if strcmp(experiment_version,'1D')
        delay_factor=[ones(size(y0)),zeros(size(y1)),ones(size(y2)),zeros(size(y3))];
        message_factor=[ones(size(y0)),zeros(size(y1)),zeros(size(y2)),ones(size(y3))];
        X=[trial(:),delay_factor(:),message_factor(:)];
        optimal_route_model = fitnlm(X,y(:),'y ~ (1-b1)*sigmoid(b2+x1*(b3+b4*x2+b5*x3+b6*x2*x3))',[0.01;0.01;0.25;0.2;0.2;0.2])
        BIC_full=optimal_route_model.ModelCriterion.BIC;
        RSS_full=sum(optimal_route_model.Residuals.Raw.^2);
        DF_full=optimal_route_model.DFE;
        
        [BICs_routes,models_routes,RSS_routes,DF_routes]=...
            modelSelectionLearningCurves(X,y);
        
        [val,pos]=min(BICs_routes);
        models_routes{pos}
        
        F_routes=(RSS_routes(6)-RSS_routes(2))/(DF_routes(6)-DF_routes(2))/...
            (RSS_routes(2)/DF_routes(2));
        DF_N=DF_routes(6)-DF_routes(2);
        p_routes=1-fcdf(F_routes,DF_N,DF_routes(2));
    end
    if strcmp(experiment_version,'1E')
        y=[y2,y4];
        PR_type_factor=[zeros(size(y2)),ones(size(y4))];
        X=[trial(:),PR_type_factor(:)];
        
        model = fitnlm(X,y(:),'y ~ (1-b1)*sigmoid(b2+x1*(b3+b4*x2))',[0.01;0.01;0.25;0.2])
        BIC_full=model.ModelCriterion.BIC;
        RSS_full=sum(model.Residuals.Raw.^2);
        DF_full=model.DFE;

    [p, tt, stats, terms] = anovan(y(:),{conds(:) trial(:)}, ...
        'model', 'interaction', ...
        'display', 'on', ...
        'varnames', {'condition','trial'});
        
        
    end
    
end

%% plot nr clicks before each move

figure; hold on;
y0 = [data(idx0).nr_clicks1];
y1 = [data(idx1).nr_clicks1];
y2 = [data(idx2).nr_clicks1];
y3 = [data(idx3).nr_clicks1];
y4 = [data(idx4).nr_clicks1];
h0 = errorbar(mean(y0,2),sem(y0,2),linestyleOrd{1},'color',eval(colorOrd{1}),'linewidth',3);
h1 = errorbar(mean(y1,2),sem(y1,2),linestyleOrd{2},'color',eval(colorOrd{2}),'linewidth',3);
h2 = errorbar(mean(y2,2),sem(y2,2),linestyleOrd{3},'color',eval(colorOrd{3}),'linewidth',3);
h3 = errorbar(mean(y3,2),sem(y3,2),linestyleOrd{4},'color',eval(colorOrd{4}),'linewidth',3);
h4 = errorbar(mean(y4,2),sem(y4,2),linestyleOrd{5},'color',eval(colorOrd{5}),'linewidth',3);
legend(eval(legendOrd),legendStr,'location','southeast')
xlabel('trial','fontsize',36)
ylabel('# clicks','fontsize',36)
set(gca,'xtick',1:1:nr_trials,'fontsize',24);
xlim([0 nr_trials+1])

if SAVE, saveas(gcf,[figdir,'/nr_clicks'],'png');end

if DO_STATS
    close all hidden
    trial = repmat([1:nr_trials]',numel(conds)/nr_trials,1);
    [p, tt, stats, terms] = anovan([y0(:);y1(:);y2(:);y3(:)],{conds(:) trial(:)}, ...
        'model', 'interaction', ...
        'display', 'on', ...
        'varnames', {'condition','trial'});
    if SAVE,saveas(1,[figdir,'/stats/nr_clicks.jpg']);end
    
    y=[y0,y1,y2,y3];
    delay_factor=[ones(size(y0)),zeros(size(y1)),ones(size(y2)),zeros(size(y3))];
    message_factor=[ones(size(y0)),zeros(size(y1)),zeros(size(y2)),ones(size(y3))];
    X=[trial(:),delay_factor(:),message_factor(:)];
    
    [BICs_clicks,models_clicks,RSS_clicks,DF_clicks]=...
        modelSelectionLearningCurves(X,y);
    
    [best_BIC,best_model]=min(BICs_clicks);
    models_clicks{best_model}
    
    F_clicks=(RSS_clicks(6)-RSS_clicks(2))/(DF_clicks(6)-DF_clicks(2))/...
        (RSS_clicks(2)/DF_clicks(2));
    DF_N=DF_clicks(6)-DF_clicks(2);
    p_clicks=1-fcdf(F_clicks,DF_N,DF_clicks(2));
    
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
    for f = 1:5
        figure('position',[0,0,1200,600]);
        if f==1
            dat=data(idx0);
        elseif f==2
            dat=data(idx1);
        elseif f==3
            dat=data(idx2);
        elseif f==4
            dat=data(idx3);
        elseif f==5
            dat=data(idx4);
        end
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
            subplot(3,4,i); hold on;
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
            if SAVE && f==1, saveas(gcf,[figdir,'/click_locations_0_before1stFlight'],'png');end
            if SAVE && f==2, saveas(gcf,[figdir,'/click_locations_1_before1stFlight'],'png');end
            if SAVE && f==3, saveas(gcf,[figdir,'/click_locations_2_before1stFlight'],'png');end
            if SAVE && f==4, saveas(gcf,[figdir,'/click_locations_3_before1stFlight'],'png');end
            if SAVE && f==5, saveas(gcf,[figdir,'/click_locations_4_before1stFlight'],'png');end
        else
            if SAVE && f==1, saveas(gcf,[figdir,'/click_locations_0_anytime'],'png');end
            if SAVE && f==2, saveas(gcf,[figdir,'/click_locations_1_anytime'],'png');end
            if SAVE && f==3, saveas(gcf,[figdir,'/click_locations_2_anytime'],'png');end
            if SAVE && f==4, saveas(gcf,[figdir,'/click_locations_3_anytime'],'png');end
            if SAVE && f==5, saveas(gcf,[figdir,'/click_locations_4_anytime'],'png');end
        end
    end
end

%% check for pruning

types = {'any','all'}; % do they have to click any of the outer nodes, or all?
for t = 1:length(types)
    type = types{t};
    figure; hold on;
    for c = 1:5
        if c==1
            dat=data(idx0);
        elseif c==2
            dat=data(idx1);
        elseif c==3
            dat=data(idx2);
        elseif c==4
            dat=data(idx3);
        elseif c==5
            dat=data(idx4);
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
            eh = errorbar(bin+.5,1-proportion(b),sem(1-clicked2_given_clicked1(idx,2)),'k','linewidth',3);
            if c == 1
                h0 = plot(bin-.5,1-proportion(b),'s','MarkerEdgeColor','k','markersize',18,'MarkerFaceColor',GOLD);
            elseif c == 2
                h1 = plot(bin+.5,1-proportion(b),'s','MarkerEdgeColor','k','markersize',18,'MarkerFaceColor',BLUE);
            elseif c == 3
                h2 = plot(bin+.5,1-proportion(b),'s','MarkerEdgeColor','r','markersize',18,'MarkerFaceColor',BLUE);
            elseif c == 4
                h3 = plot(bin+.5,1-proportion(b),'s','MarkerEdgeColor','g','markersize',18,'MarkerFaceColor',BLUE);
            elseif c == 5
                h4 = plot(bin+.5,1-proportion(b),'s','MarkerEdgeColor','g','markersize',18,'MarkerFaceColor',BLUE);
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
    legend(eval(legendOrd),legendStr,'location','northeast')
    if SAVE, saveas(gcf,[figdir,'/prunning_',type,'_1'],'png');end
end

if DO_STATS
    %X=[reward{2,1}];
    %[b,dev,stats]=glmfit(X,pruned{2,1},'Binomial');
    
    pruning_1=pruned{2,1};
    stem_reward_1=reward{2,1};
    subject_1=categorical(subject_nrs{2,1});
    data_table_1=table(pruning_1,stem_reward_1,subject_1);
    
    pruning_0=pruned{1,1};
    stem_reward_0=reward{1,1};
    subject_0=categorical(subject_nrs{1,1});
    data_table_0=table(pruning_0,stem_reward_0,subject_0);
    
    FB=[zeros(numel(pruning_1),1); ones(numel(pruning_0),1)];
    pruning=[pruning_1(:);pruning_0(:)];
    stem_reward=[stem_reward_1(:);stem_reward_0(:)];
    subject=[subject_1(:);subject_0(:)];
    data_table=table(pruning,stem_reward,subject,FB)
    
    pruning_2=pruned{3,1};
    stem_reward_2=reward{3,1};
    subject_2=categorical(subject_nrs{3,1});
    data_table_2=table(pruning_2,stem_reward_2,subject_2);
    
    pruning_3=pruned{4,1};
    stem_reward_3=reward{4,1};
    subject_3=categorical(subject_nrs{4,1});
    data_table_3=table(pruning_3,stem_reward_3,subject_3);
    
    glme_1 = fitglme(data_table_1,'pruning_1 ~ 1+ stem_reward_1 + subject_1');
    glme_0 = fitglme(data_table_0,'pruning_0 ~ 1+ stem_reward_0 + subject_0');
    glme_2 = fitglme(data_table_2,'pruning_2 ~ 1+ stem_reward_2 + subject_2');
    glme_3 = fitglme(data_table_3,'pruning_3 ~ 1+ stem_reward_3 + subject_3');
    
    glme_all= fitglme(data_table,'pruning ~ 1+ stem_reward*FB + FB + subject');
    
end

%% plot common sets of click locations, for each trial

for f = 1:5
    if f==1
        dat=data(idx0);
    elseif f==2
        dat=data(idx1);
    elseif f==3
        dat=data(idx2);
    elseif f==4
        dat=data(idx3);
    elseif f==5
        dat=data(idx4);
    end
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
        if SAVE && f==1, saveas(gcf,[figdir,'/click_sets_trial',num2str(i),'_0'],'png');end
        if SAVE && f==2, saveas(gcf,[figdir,'/click_sets_trial',num2str(i),'_1'],'png');end
        if SAVE && f==3, saveas(gcf,[figdir,'/click_sets_trial',num2str(i),'_2'],'png');end
        if SAVE && f==4, saveas(gcf,[figdir,'/click_sets_trial',num2str(i),'_3'],'png');end
        if SAVE && f==5, saveas(gcf,[figdir,'/click_sets_trial',num2str(i),'_4'],'png');end
    end
end