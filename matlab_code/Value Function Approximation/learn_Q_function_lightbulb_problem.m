%evaluate and tune Bayesian-SARSAQ with the features identified by linear
%regression
load ../../results/lightbulb_problem.mat

%TODO
nr_training_episodes=100;
nr_reps=10;
first_episode=1; last_rep=nr_training_episodes;
for rep=1:nr_reps
    glm(rep)=glm0;
    tic()
    [glm(rep),MSE(first_episode:nr_training_episodes,rep),...
        returns(first_episode:nr_training_episodes,rep)]=BayesianSARSAQ(...
        meta_MDP,feature_extractor,nr_training_episodes-first_episode+1,glm(rep));
    disp(['Repetition ',int2str(rep),' took ',int2str(round(toc()/60)),' minutes.'])
end
