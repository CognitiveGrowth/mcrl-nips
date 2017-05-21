costs=[0.01,2.80]; %,1.60 is already taken care of

parfor c=1:numel(costs)
    policySearchMouselabMDP(costs(c))
end

%%
addpath([pwd,'/MatlabTools/'])
%create meta-level MDP

add_pseudorewards=false;
pseudoreward_type='none';

mean_payoff=4.5;
std_payoff=10.6;

load('MouselabMDPExperiment_normalized')

actions_by_state{1}=[];
actions_by_state{2}=[1];
actions_by_state{3}=[2];
actions_by_state{4}=[3];
actions_by_state{5}=[4];
actions_by_state{6}=[1,1];
actions_by_state{7}=[2,2];
actions_by_state{8}=[3,3];
actions_by_state{9}=[4,4];
actions_by_state{10}=[1,1,2];
actions_by_state{11}=[1,1,4];
actions_by_state{12}=[2,2,3];
actions_by_state{13}=[2,2,4];
actions_by_state{14}=[3,3,2];
actions_by_state{15}=[3,3,4];
actions_by_state{16}=[4,4,3];
actions_by_state{17}=[4,4,1];
for e=1:numel(experiment)
    experiment(e).actions_by_state=actions_by_state;
    experiment(e).hallway_states=2:9;
    experiment(e).leafs=10:17;
    experiment(e).parent_by_state=[1,1,1,1,1,2,3,4,5,6,6,7,7,8,8,9,9];
end

costs=[0.01,1.60,2.80];
w_observe_everything=[1;1;1];
w_observe_nothing=[-1.3;0.4;0.3];

[ER_hat_everything,result_everything]=evaluatePolicy(w_observe_everything,0.01,1000)
[ER_hat_nothing,result_nothing]=evaluatePolicy(w_observe_nothing,2.80,1000)

for c=1:numel(costs)
    
    load(['../results/BO_c',int2str(100*costs(c)),'n25.mat'])
    
    w_policy=BO.w_hat;
    glm_policy=BayesianGLM(3,1e-6);
    glm_policy.mu_n=w_policy;
    glm_policy.mu_0=w_policy;
    nr_episodes=1000;
    
    meta_MDP=MouselabMDPMetaMDPNIPS(add_pseudorewards,pseudoreward_type,mean_payoff,std_payoff,experiment);
    meta_MDP.cost_per_click=costs(c);
    
    feature_extractor=@(s,c,meta_MDP) meta_MDP.extractStateActionFeatures(s,c);
    
    [glm_Q(c),MSE(:,c),R_total(:,c)]=BayesianValueFunctionRegression(meta_MDP,feature_extractor,nr_episodes,glm_policy)
    
end