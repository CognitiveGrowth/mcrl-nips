setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');

addpath('./GeneralMDP/')
rewardCorrect = 1;
rewardIncorrect = 0;
discount = 1;

nrs_arms = [3,4,5];
nrs_balls = 6;
costs = 0.01;

for c=1:numel(costs)
    for na=1:numel(nrs_arms)
        for nb=1:numel(nrs_balls)
    
    cost = costs(c);
    nr_arms = nrs_arms(na);
    nr_balls = nrs_balls(nb);
    
    commandStr = ['python ./GeneralMDP/generate_state_matrices.py ',...
        int2str(nr_balls),' ',int2str(nr_arms),' ',num2str(cost)];
    [status, commandOut] = system(commandStr);

    load('./GeneralMDP/file')
    
    nr_states = size(states,1);
    nr_arms = size(states,2)/2;
    nTrials = sum(states(end-1,:))-2*nr_arms;
    
    [values, policy] = mdp_finite_horizon (transition, rewards, discount, nTrials+1);
    Q_star=getQFromV(values(:,1),transition,rewards);

    steps = sum(states(end-1,:));
    for i=1:nr_states
        if sum(states(i,:)) == steps && not(policy(i,1) == nr_arms+1)
            disp('error: non-terminal state where it should be')
        end
    end
    
    %% Calculate PRs (without rewards)
    exact_PR = nan(nr_states,nr_arms+1);
    for s=1:nr_states
        for a=1:nr_arms+1
            next_s = find(not(transition(s,:,a) == 0));
            evp = 0;
            for isp=1:numel(next_s)
                sp = next_s(isp);
                evp = evp + transition(s,sp,a)*values(sp,1);
            end
            exact_PR(s,a) = evp-values(s,1);
        end
    end
    
%     exact_PR = nan(nr_states,nr_arms+1);
%     exact_PR_Q = nan(nr_states,nr_arms+1);
%     for s=1:nr_states
%         for a=1:nr_arms+1
%             exact_PR_Q(s,a) = Q_star(s,a) - values(s,1);
%             next_s = find(not(transition(s,:,a) == 0));
%             evp = 0;
%             for isp=1:numel(next_s)
%                 sp = next_s(isp);
%                 evp = evp + transition(s,sp,a)*values(sp,1);
%             end
%             exact_PR(s,a) = evp+rewards(s,a)-values(s,1);
%         end
%     end
    
    %% Save
    nlightbulb_mdp(na,nb,c).Q_star=Q_star;
    nlightbulb_mdp(na,nb,c).exact_PR=exact_PR;
    nlightbulb_mdp(na,nb,c).v_star=values(:,1);
    nlightbulb_mdp(na,nb,c).pi_star=policy(:,1);
    nlightbulb_mdp(na,nb,c).states=states;
    nlightbulb_mdp(na,nb,c).T=transition;
    nlightbulb_mdp(na,nb,c).R=rewards;
    nlightbulb_mdp(na,nb,c).cost=cost;
    nlightbulb_mdp(na,nb,c).nr_arms=nr_arms;
    nlightbulb_mdp(na,nb,c).nr_balls=nr_balls;
        end
    end
end
save('../results/nlightbulb_problem.mat','nlightbulb_mdp','-v7.3') 