clear;

n = 1;

switch n
    case 1
        load('../results/lightbulb_problem.mat')
        load('../results/lightbulb_fit.mat')
        c = 10;
        PRs_opt = squeeze(lightbulb_mdp(c).optimal_PR(:,1,:));
        PRs_aprx = [lightbulb_problem(c).approximate_PRs;[0,0]];
        pi_star = lightbulb_mdp(c).pi_star;
        S = lightbulb_mdp(c).states;
        T = lightbulb_mdp(c).T;
        R = lightbulb_mdp(c).R;
    case 3
        load('../results/nlightbulb_problem.mat') % exact
        load('../results/nlightbulb_fit.mat') % approximate
        PRs_opt = squeeze(nlightbulb_mdp.exact_PR);
        PRs_aprx = [nlightbulb_problem.approximate_PRs];
        pi_star = nlightbulb_mdp.pi_star;
        S = nlightbulb_mdp.states;
        T = nlightbulb_mdp.T;
        R = nlightbulb_mdp.R;
end

alpha       = 0.1;   % learning rate
gamma       = 1;  % discount factor
epsilon     = 0.25;  % probability of a random action selection
nEpisodes = 1000;

nActions = size(T,3);
nSims = 2000;

PRs_none = zeros(size(PRs_opt));
PRs_opt = PRs_opt + R;
PRs_aprx = PRs_aprx + R;

R_noPR = nan(nSims,nEpisodes);
parfor i = 1:nSims
    disp(num2str(i))
    R_noPR(i,:) = simulate_nlightbulb(nEpisodes,T,R,PRs_none,epsilon,alpha,gamma);
end
R_aprxPR = nan(nSims,nEpisodes);
parfor i = 1:nSims
    disp(num2str(i))
    R_aprxPR(i,:) = simulate_nlightbulb(nEpisodes,T,R,PRs_aprx,epsilon,alpha,gamma);
end
R_optPR = nan(nSims,nEpisodes);
parfor i = 1:nSims
    disp(num2str(i))
    R_optPR(i,:) = simulate_nlightbulb(nEpisodes,T,R,PRs_opt,epsilon,alpha,gamma);
end
R_optPi = nan(nSims,1);
nStates = size(T,1);
parfor j = 1:nEpisodes
    disp(num2str(j))
    for i = 1:nSims
        s = 1;
        r_cum = 0;
        while true
            if (rand()>epsilon)
                a = pi_star(s);
            else
                a = randi(nActions);
            end
            r_cum = r_cum + R(s,a);
            if a == nActions
                break
            end
            s = randsample(nStates,1,true,T(s,:,a));
        end
        R_optPi(i,j) = r_cum;
%         R_optPi(i) = r_cum;
    end
end

figure; hold on;
% plot(mean(R_noPR),'k')
% plot(mean(R_aprxPR),'b')
% plot(mean(R_optPR),'r')
% plot(mean(R_optPi),'g')
% plot([1 nEpisodes],[mean(R_optPi),mean(R_optPi)],'g--','linewidth',2)
h = errorbar(smooth(mean(R_noPR),20),smooth(sem(R_noPR),20),'k'); h.CapSize = 0;
h = errorbar(smooth(mean(R_aprxPR),20),smooth(sem(R_aprxPR),20),'b'); h.CapSize = 0;
h = errorbar(smooth(mean(R_optPR),20),smooth(sem(R_optPR),20),'r'); h.CapSize = 0;
h = errorbar(smooth(mean(R_optPi),20),smooth(sem(R_optPi),20),'g'); h.CapSize = 0;
legend('no PRs','approximate PRs','optimal PRs','optimal policy','location','southeast')
xlabel('learning episode','fontsize',18)
ylabel('reward','fontsize',18)
saveas(gcf,['../results/figures/',num2str(n),'lightbulb_simulations_',num2str(nEpisodes),'Episodes'],'png');