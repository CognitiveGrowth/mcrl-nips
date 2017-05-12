
qw=[data(idx_FB).delays];mean(qw(:))
qw1=[data(idx_FB).delays1];mean(qw1(:))
qw2=[data(idx_FB).delays2];mean(qw2(:))
qw3=[data(idx_FB).delays3];mean(qw3(:))


qw=[data(idx_FB).delays];qw=qw(1:8,:);mean(qw(:))
qw1=[data(idx_FB).delays1];qw1=qw1(1:8,:);mean(qw1(:))
qw2=[data(idx_FB).delays2];qw2=qw2(1:8,:);mean(qw2(:))
qw3=[data(idx_FB).delays3];qw3=qw3(1:8,:);mean(qw3(:))


%%

% for t = 1:20
%     trial_properties(t).reward_by_state(

%%

figure('position',[200,200,400,400]); hold on;
axis off
locations = ...
    {[.5,.5],[.7,.5],[.5,.7],[.3,.5],[.5,.3],...
    [.9,.5],[.5,.9],[.1,.5],[.5,.1],...
    [.9,.7],[.9,.3],[.7,.9],[.3,.9],[.1,.7],[.1,.3],[.7,.1],[.3,.1]};

for i = 1:17
    plot(locations{i}(1),locations{i}(2),'ok','markersize',40)
    text(locations{i}(1),locations{i}(2),num2str(i),'horizontalalignment','center')
end

%%

for i=1:569
    if isempty(clicks_and_paths{i}.delays)
        meandelay(i)=0;
    else
        meandelay(i)=mean(clicks_and_paths{i}.delays);
    end
end

%%

% load('../MouselabMDPExperiment_normalized.mat')
% 
% %experiment_json=loadjson('/Users/Falk/Dropbox/PhD/Metacognitive RL/mcrl-experiment/data/1/human_raw/A/server-trials.json')
% experiment_json=loadjson('~/Dropbox/PhD/Metacognitive RL/mcrl-experiment/MouselabMDPExperiment.json');
% 
% 
% for e=1:numel(experiment_json)
%     properties_json(e)=evaluateMouselabMDP(experiment_json{e}.T,...
%         experiment_json{e}.R,experiment_json{e}.start_state,...
%         experiment_json{e}.horizon,false);
% end
% 
% addpath('..')
% for e=1:numel(experiment)
%     properties(e)=evaluateMouselabMDP(experiment(e).T,experiment(e).R,...
%         experiment(e).start_state,experiment(e).horizon,false); 
% end
% 
% figure()
% hist(score)
% title('Score','FontSize',16)
% 
% mean(score)
% std(score)
% 
% figure()
% hist(nr_clicks)
% title('Nr. Clicks','FontSize',16)
% 
% mean(inspected_all_states)
% 
% mean(nr_clicks)
% std(nr_clicks)
% 
% 
% for i=1:numel(score)
%     max_score(i)=properties_json(trialID(i)+1).R_total(end);
%     relative_performance(i)=score(i)/max_score(i);
% end
% 
% mean(relative_performance)
% std(relative_performance)
% 
% %%
% mean(action_times)/1000
% 
% for a=1:3
%     q95(a,:)=quantile(action_times(:,a)'/1000,0.95)
% end

%%


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