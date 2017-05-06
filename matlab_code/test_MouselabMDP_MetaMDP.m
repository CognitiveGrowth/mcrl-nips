%{
add_pseudorewards=false;
pseudoreward_type='none';
mean_payoff=1;
std_payoff=2;

load MouselabMDPExperiment

meta_MDP=MouselabMDPMetaMDP(add_pseudorewards,pseudoreward_type,mean_payoff,std_payoff,experiment(1));

[state,meta_MDP]=newEpisode(meta_MDP)

nr_episodes=2;
policy=@(state,mdp) drawSample(mdp.actions)
[R_total,problems,states,chosen_actions,indices]=inspectPolicyGeneral(meta_MDP,policy,nr_episodes)
%}

%%
clear
%create meta-level MDP

add_pseudorewards=false;
pseudoreward_type='none';

mean_payoff=1;
std_payoff=2;
load('MouselabMDPExperiment_normalized')

%{
temp=load('MouselabMDPExperiment');

experiment=cell2mat(temp.experiment);
experiment=rmfield(experiment,'states_by_step')
experiment=rmfield(experiment,'states');
for e=1:numel(experiment)
    
    nr_states=numel(temp.experiment{e}.states{1});

    experiment(e).states_by_step{1}={temp.experiment{e}.states_by_step{1}};
    nr_steps=numel(temp.experiment{e}.states_by_step);
    for step=2:nr_steps
        experiment(e).states_by_step{step}=[temp.experiment{e}.states_by_step{step}{:}];
    end
    
    for s=1:nr_states
        temp_states(s)=temp.experiment{e}.states{1}{s};
        if s==1
            temp_states2(s)=rmfield(temp_states(s),'actions');
        end
        
        nr_actions=numel(temp_states(s).actions);
        if nr_actions>1
            for a=1:nr_actions
                temp_states2(s).actions(a)=temp_states(s).actions{a};
            end
        else
            temp_states2(s).actions=temp.experiment{e}.states{1}{s}.actions;
        end
    end
    experiment(e).states=temp_states2; 
    clear temp_states2
    
    experiment(e).nextState=@(state,action) find(experiment(e).T(state,:,action));
end

states=experiment(1).states;
states_by_path=containers.Map();

for s=1:numel(states)        
    states_by_path(num2str(states(s).path))=states(s);    
end

for e=1:numel(experiment)
    experiment(e).states_by_path=states_by_path;
end
%}

meta_MDP=MouselabMDPMetaMDP(add_pseudorewards,pseudoreward_type,mean_payoff,std_payoff,experiment);

%initialize value function approximation
sigma0=1;

state_feature_names={'max mu','sigma(argmax mu(a))','E[max R]','STD[max R]',...
                    'mu(beta)', 'sigma(beta)'};
action_feature_names={'Expected_regret','regret_reduction','VOC',...
                'uncertainty reduction','sigma_R','p_best_action','sigma_best_action',...
                'underplanning','complete_planning','cost'};
            
feature_names={state_feature_names{:}, action_feature_names{:}};
            
mu0=[0.5,0,0.5,0,0.25,0,-1,2,2,2,-0.25,1,-1,-1,1,-1]';
nr_features=numel(mu0);
glm0=BayesianGLM(nr_features,sigma0)
glm0.mu_n=mu0(:);

feature_extractor=@(s,c,meta_MDP) meta_MDP.extractStateActionFeatures(s,c);

load MouselabMDPMetaMDPTestFeb-17-2017

nr_training_episodes=100;
nr_reps=2;
first_episode=1; last_rep=nr_training_episodes;
for rep=2:nr_reps
    glm(rep)=glm0;
    tic()
    [glm(rep),MSE(first_episode:nr_training_episodes,rep),...
        returns(first_episode:nr_training_episodes,rep)]=BayesianSARSAQ(...
        meta_MDP,feature_extractor,nr_training_episodes-first_episode+1,glm(rep));
    disp(['Repetition ',int2str(rep),' took ',int2str(round(toc()/60)),' minutes.'])
end
save MouselabMDPMetaMDPTestFeb-18-2017

clear avg_returns, clear sem_avg_return, clear avg_RMSE, clear sem_RMSE
bin_width=20;
for r=1:nr_reps
    [avg_returns(:,r),sem_avg_return(:,r)]=binnedAverage(returns(:,r),bin_width)
    [avg_RMSE(:,r),sem_RMSE(:,r)]=binnedAverage(sqrt(MSE(:,r)),bin_width);
end
best_run=argmax(avg_returns(end,:));

avg_MSE=mean(MSE(:,best_run),2);

R_total=mean(returns(:,best_run),2);

nr_episodes=size(R_total,1);
bin_width=20;
episode_nrs=bin_width:bin_width:nr_episodes;
[avg_RMSE,sem_RMSE]=binnedAverage(sqrt(avg_MSE),bin_width);
[avg_R,sem_R]=binnedAverage(R_total,bin_width);

figure()
subplot(2,1,1)
errorbar(episode_nrs,avg_R,sem_R,'g-o','LineWidth',2), hold on
set(gca,'FontSize',16)
xlabel('Episode','FontSize',16)
ylabel('R_{total}','FontSize',16),
title('Semi-gradient SARSA (Q) in Mouselab Task','FontSize',18)
%ylim([0,10])
xlim([0,nr_episodes+5])
%hold on
%plot(smooth(R_total,100),'r-')
%legend('RMSE','R_{total}')
xlabel('#Episodes','FontSize',16)
subplot(2,1,2)
errorbar(episode_nrs,avg_RMSE,sem_RMSE,'g-o','LineWidth',2), hold on
xlim([0,nr_episodes+5])
set(gca,'FontSize',16)
xlabel('Episode','FontSize',16)
ylabel('RMSE','FontSize',16),
%legend('with PR','without PR')
%hold on
%plot(smooth(R_total,100),'r-')
%legend('RMSE','R_{total}')
xlabel('#Episodes','FontSize',16)

feature_names=meta_MDP.feature_names

weights=[glm(1:nr_reps).mu_n];
figure()
bar(weights),
%bar(w)
%ylim([0,0.3])
set(gca,'XTick',1:numel(feature_names),'XTickLabel',feature_names)
set(gca,'XTickLabelRotation',45,'FontSize',16)
ylabel('Learned Weights','FontSize',16)
title(['Bayesian SARSA without PR, ',int2str(nr_episodes),' episodes'],'FontSize',18)

policy=@(state,mdp) contextualThompsonSampling(state,meta_MDP,glm(best_run))
[R_total,problems,states,chosen_actions,indices]=inspectPolicyGeneral(meta_MDP,policy,nr_episodes)
