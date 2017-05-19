clear;

load ../results/2lightbulb_problem.mat
Q_star_2 = nlightbulb_mdp.Q_star;
S_2 = nlightbulb_mdp.states;
T_2 = nlightbulb_mdp.T;
R_2 = nlightbulb_mdp.R;
load ../results/nlightbulb_problem.mat

%%
nSims = 1000;
epsilon     = 0.25;  % probability of a random action selection

for n = 2:4
    disp(num2str(n))
    switch n
        case 2
            load ../results/2lightbulb_fit.mat
            Q_hat = nlightbulb_problem.Q_hat_BSARSA;
            Q_star = Q_star_2;
            S = S_2;
            T = T_2;
            R = R_2;
        case 3
            load ../results/nlightbulb_fit.mat
            Q_hat = nlightbulb_problem.Q_hat_BSARSA;
            Q_star = nlightbulb_mdp(1).Q_star;
            S = nlightbulb_mdp(1).states;
            T = nlightbulb_mdp(1).T;
            R = nlightbulb_mdp(1).R;
        case 4
            load ../results/4lightbulb_fit.mat
            Q_hat = nlightbulb_problem.Q_hat_BSARSA;
            Q_star = nlightbulb_mdp(2).Q_star;
            S = nlightbulb_mdp(2).states;
            T = nlightbulb_mdp(2).T;
            R = nlightbulb_mdp(2).R;
        case 5
            load ../results/5lightbulb_fit.mat
            Q_hat = nlightbulb_problem.Q_hat_BSARSA;
            Q_star = nlightbulb_mdp(3).Q_star;
            S = nlightbulb_mdp(3).states;
            T = nlightbulb_mdp(3).T;
            R = nlightbulb_mdp(3).R;
    end
    nActions = size(T,3);
    nStates = size(T,1);
    for p = 1:2
        ER = nan(nSims,1);
        if p == 1
            Q = Q_star;
        else
            Q = Q_hat;
        end
        for i = 1:nSims
            if ~rem(i,100),disp(num2str(i));end
            s = 1;
            r_cum = 0;
            while true
                if (rand()>epsilon)
                    [~,a] = sort(Q(s,:),'descend');
                    a = a(1);
                else
                    a = randi(nActions);
                end
                r_cum = r_cum + R(s,a);
                if a == nActions
                    break
                end
                s = randsample(nStates,1,true,T(s,:,a));
            end
            ER(i) = r_cum;
        end
        ER_m(n-1,p) = mean(ER);
        ER_s(n-1,p) = sem(ER);
    end
end
%%


figure; hold on;
h = bar(ER_m);
set(gca,'xtick',1:3,'xticklabel',{'2','3','4'})
xlabel('num. bandits','fontsize',18)
ylabel('expected return','fontsize',18)
legend('optimal policy','approximate policy')
pause(0.1); %pause allows the figure to be created
for ib = 1:numel(h)
    %XData property is the tick labels/group centers; XOffset is the offset
    %of each distinct group
    xData = h(ib).XData+h(ib).XOffset;
    e = errorbar(xData,ER_m(:,ib),ER_s(:,ib),'k.');
    set(e,'linewidth',2)
end
% saveas(gcf,['../results/figures/nbandit_expectedReturn','png');