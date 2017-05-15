addpath('./GeneralMDP/')
load('file')

costs=0.01;

for c=1:numel(costs)
    cost = costs(c);
    nTrials = 30;
    rewardCorrect = 1;
    rewardIncorrect = 0;
    cost = costs(c);
    
    discount = 1;
    [values, policy] = mdp_finite_horizon (transition, rewards, discount, 7);

    s = length(states);
    steps = sum(states(s-1,:));
    for i=1:s
        if sum(states(i,:)) == steps && not(policy(i,1) == 4)
            disp('error: non-terminal state where it should be')
        end
    end
    
    nlightbulb_mdp(c).v_star=values(:,1);
    nlightbulb_mdp(c).pi_star=policy(:,1);
    nlightbulb_mdp(c).states=states;
    nlightbulb_mdp(c).T=transition;
    nlightbulb_mdp(c).R=rewards;
    nlightbulb_mdp(c).cost=cost;
end
save('../results/nlightbulb_problem.mat','nlightbulb_mdp') 