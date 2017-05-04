classdef (Abstract) MDP 
    properties
        nr_actions;
        gamma;
        actions;
    end
    
    methods (Abstract)
        [mdp,s0]=newEpisode(mdp);
        s=sampleS0(mdp);
        true_or_false=isTerminalState(mdp,s);
        ER=expectedReward(mdp,s,a);
        [r,s]=simulateTransition(mdp,s,a);
        [next_states,p_next_states]=predictNextState(mdp,s,a);
        actions=getActions(mdp);
        
    end
end