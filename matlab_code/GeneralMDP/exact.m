addpath('./GeneralMDP/')
load('file')

costs=[0.01];
nr_states = size(states,1);
nr_arms = size(states,2)/2;
nTrials = sum(states(end-1,:))-2*nr_arms;
rewardCorrect = 1;
rewardIncorrect = 0;
discount = 1;

for c=1:numel(costs)
    cost = costs(c);
    
    [values, policy] = mdp_finite_horizon (transition, rewards, discount, nTrials+1);
    Q_star=getQFromV(values(:,1),transition,rewards);

    steps = sum(states(end-1,:));
    for i=1:nr_states
        if sum(states(i,:)) == steps && not(policy(i,1) == 4)
            disp('error: non-terminal state where it should be')
        end
    end
    
    for s=1:nr_states-1
        for a=1:nr_arms+1
            exact_PR(s,a)=Q_star(s,a)-values(s);
        end
    end
    
    nlightbulb_mdp(c).Q_star=Q_star;
    nlightbulb_mdp(c).exact_PR=exact_PR;
    nlightbulb_mdp(c).v_star=values(:,1);
    nlightbulb_mdp(c).pi_star=policy(:,1);
    nlightbulb_mdp(c).states=states;
    nlightbulb_mdp(c).T=transition;
    nlightbulb_mdp(c).R=rewards;
    nlightbulb_mdp(c).cost=cost;
end
save('../results/nlightbulb_problem.mat','nlightbulb_mdp') 