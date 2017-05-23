clear

load ControlExperiment
load ControlTrialProperties

nr_trials=length(control_experiment);
for t=1:nr_trials
    control_experiment(t).hallway_states=2:9;
    control_experiment(t).leafs=10:17;
    control_experiment(t).parent_by_state={[],[1],[1],[1],[1],[2],[3],[4],...
        [5],[6],[6],[7],[7],[8],[8],[9],[9]};
end

cost_per_click=1.60;
meta_MDP=MouselabMDPMetaMDPNIPS(true,'featureBased',4.5,10.6,control_experiment,cost_per_click);
meta_MDP.object_level_MDP=control_experiment(1);

%Test PR for a click
[state,meta_MDP]=meta_MDP.newEpisode()

actions=meta_MDP.getActions(state)

[r,next_state,PR]=meta_MDP.simulateTransition(state,actions(8))