classdef generalMDP < MDP
    
    properties
        features_per_a;
        action_features;
        rewardCorrect = 1;
        rewardIncorrect = 0;
        cost;
        discount = 1;
        nr_arms;
    end
    methods
        function mdp=generalMDP(nr_arms,gamma)
            mdp.nr_arms=nr_arms;
            mdp.cost = 1/100;
            mdp.nr_actions=nr_arms+1; 
            mdp.actions = 1:nr_arms+1;
            mdp.gamma=gamma;
            mdp.actions=1:mdp.nr_actions;
            mdp.features_per_a = 6;
            mdp.action_features= 1:nr_arms*mdp.features_per_a+8;
        end
        
        function [s,mdp]=sampleS0(mdp)
            s=ones(mdp.nr_arms,2);
        end
        
        function [s0,mdp]=newEpisode(mdp)
            mdp=generalMDP(mdp.nr_arms,mdp.gamma);
            s0=mdp.sampleS0();
        end
        
        function true_or_false=isTerminalState(mdp,s)
            true_or_false=s(1)+s(2)>7 || s(1) == -1;
        end
        
        function ER=expectedReward(mdp,s,a)
            if a <= mdp.nr_arms
                ER = -mdp.cost;
            elseif a == mdp.nr_arms+1
                ER = mdp.rewardCorrect*max(s(:,1)./sum(s,2));
            end
        end
        
        function [r,s_next,PR]=simulateTransition(mdp,s,a)
            flip = rand;
            if s(1) == -1
                r = 0;
                s_next = -ones(mdp.nr_arms,2);
            elseif a <= mdp.nr_arms
                pheads = s(a,1)/(s(a,1)+s(a,2));
                heads = flip <= pheads;
                r = -mdp.cost;
                s_next = s;
                if heads
                    s_next(a,:)=[s_next(a,1)+ 1,s_next(a,2)];
                else
                    s_next(a,:)=[s_next(a,1),s_next(a,2)+1];
                end
            elseif a == mdp.nr_arms+1
                pheads = max(s(:,1));
                heads = flip <= pheads;
                if heads
                    r = mdp.rewardCorrect;
                else
                    r = 0;
                end
                s_next = -ones(mdp.nr_arms,2);
            end 
            PR = 0;
        end
        
        function [next_states,p_next_states]=predictNextState(mdp,s,a)
            if s(1) == -1
                p_next_states=1; 
                next_states=-ones(mdp.nr_arms,2);
            elseif a == mdp.nr_arms
                p_next_states=1; 
                next_states=-ones(mdp.nr_arms,2);
            elseif a <= mdp.nr_arms
                next_states=[s,s,-ones(mdp.nr_arms,2)];
                next_states(1,a,1) = s(a,1)+1;
                next_states(1,a,2) = s(a,2)+1;
                p = s(a,1)/(s(a,1)+s(a,2));
                p_next_states=[p,1-p,0];
            end
                
        end
        
        function [actions,mdp]=getActions(mdp,s)
            actions=1:mdp.nr_actions;
        end
        
        function [action_features]=extractActionFeatures(mdp,state,action)
            action_features=feature_extractor(state,action,mdp);
        end
                
    end

end