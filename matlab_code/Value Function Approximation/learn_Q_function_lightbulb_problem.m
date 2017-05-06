%evaluate and tune Bayesian-SARSAQ with the features identified by linear
%regression
clear

addpath('../MatlabTools/') %change to your directory for MatlabTools
addpath('../metaMDP/')
addpath('../Supervised/')


load ../../results/lightbulb_fit.mat

nr_actions=2;
nr_states=2;
gamma=1;

feature_names={'VPI','VOC_1','VOC_2','E[R|guess,b]','1'};
selected_features=[1;2;4];

nr_features=numel(selected_features); 


mdp=metaMDP(nr_actions,gamma,nr_features);

nr_episodes=10000;

fexr=@(s,a,mdp) feature_extractor(s,a,mdp,selected_features);


mdp.action_features=1:nr_features;

sigma0=1;
glm=BayesianGLM(nr_features,sigma0);
glm.mu_0=[1;1;1];
glm.mu_n=[1;1;1];
[glm,avg_MSE,R_total]=BayesianSARSAQ(mdp,fexr,nr_episodes,glm);

figure(),
subplot(2,1,1)
plot(smooth(avg_MSE,100))
xlabel('Episode','FontSize',16)
ylabel('Average MSE','FontSize',16)

subplot(2,1,2)
plot(smooth(R_total,100))
xlabel('Episode','FontSize',16)
ylabel('R_{total}','FontSize',16)


w=glm.mu_n;
figure()
bar(w)
ylabel('Learned Weights','FontSize',16)
set(gca,'XTickLabel',feature_names(selected_features),'FontSize',16)

%plot the corresponding fit to the Q-function
nr_states=size(lightbulb_problem.mdp.states,1);

for s=1:nr_states
    F(s,:)=fexr(lightbulb_problem.mdp.states(s,:),1,mdp);
end

valid_states=and(sum(lightbulb_problem.mdp.states,2)<=30,...
    sum(lightbulb_problem.mdp.states,2)>0);

Q_hat(:,1)=F*w;
Q_hat(:,2)=F(:,3);
V_hat=max(Q_hat,[],2);

R2=corr(Q_hat(valid_states,1),lightbulb_problem.fit.Q_star(valid_states,1))

fig_Q=figure()
scatter(Q_hat(valid_states),lightbulb_problem.fit.Q_star(valid_states,1))
set(gca,'FontSize',16)
xlabel(['$\hat{Q}=',modelEquation(feature_names(selected_features),roundsd(w,4)),'$'],...
    'Interpreter','LaTeX','FontSize',16)
ylabel('$Q^\star$','FontSize',16,'Interpreter','LaTeX')
title(['Bayesian SARSA learns Q-function of 1-lightbulb meta-MDP, R^2=',num2str(roundsd(R2,4))],'FontSize',16)
saveas(fig_Q,'../../results/figures/QFitToyProblemBayesianSARSA.fig')
saveas(fig_Q,'../../results/figures/QFitToyProblemBayesianSARSA.png')

%% Compute approximate PRs
observe=1; guess=2;
for s=1:nr_states-1
    approximate_PR(s,observe)=Q_hat(s,observe)-V_hat(s);
    approximate_PR(s,guess)=Q_hat(s,guess)-V_hat(s);
end

lightbulb_problem.approximate_PRs=approximate_PR;

save('../../results/lightbulb_fit.mat','lightbulb_problem')