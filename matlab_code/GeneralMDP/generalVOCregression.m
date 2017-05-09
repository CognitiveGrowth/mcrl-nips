addpath('./MatlabTools/')

% tmp = matlab.desktop.editor.getActive;
% cd(fileparts(tmp.Filename));

costs=0.01;

nr_states=size(states,1);
S=states;
nr_arms = size(states(1,:),2)/2;

load ../results/nlightbulb_problem

for c=1:numel(costs)
    cost = costs(c);
    voc1 = zeros(nr_states,nr_arms);
    vpi = zeros(nr_states,nr_arms);
    voc30 = zeros(nr_states,1);
    bias = ones(nr_states,1);
    disp('here')
    for i=1:nr_states
        st = S(i,:);  
        st_m = reshape(st,nr_arms,2); 
        
        for j=1:nr_arms
            vpi(i,j) = valueOfPerfectInformationMultiArmBernoulli(st_m(:,1),st_m(:,2),j);
            voc1(i,j) = VOC1MultiArmBernoulli(st_m(:,1),st_m(:,2),j,cost);
        end
               
        er = max(st_m(:,1) ./ sum(st_m,2));
        voc30(i) = values(i,1) - er;
    end
    % X = cat(2,voc2,bias);
    % X = cat(2,vpi,voc1,bias)
    X = cat(2,vpi,voc1,bias); feature_names={'VPI','VOC_1','1'};
    [w,wint,r,rint,stats] = regress(voc30,X);
    voc_hat=X*w;
    figure();
    scatter(voc_hat,voc30);
    title(num2str(stats(1)));
    
    sign_disagreement=find(sign(voc_hat).*sign(voc30)==-1)
    numel(sign_disagreement)/numel(voc30)
    
    max(voc30(sign_disagreement))
    
    E_guess=max(S,[],2)./sum(S,2);
    
    
    %% Plot fit to Q-function
    
    Q_hat(:,1)=voc_hat+E_guess;
    Q_hat(:,2)=E_guess;
    V_hat=max(Q_hat,[],2);
    
    valid_states=and(sum(S,2)<=30,sum(S,2)>0);
    
    Q_star=getQFromV(nlightbulb_mdp(c).v_star,nlightbulb_mdp(c).T,nlightbulb_mdp(c).R);
    R2=corr(Q_star(valid_states,1),Q_hat(valid_states))^2;
    
    fig_Q=figure()
    scatter(Q_hat(valid_states),Q_star(valid_states,1))
    set(gca,'FontSize',16)
    xlabel(modelEquation(feature_names,w),'FontSize',16)
    ylabel('$Q^\star$','FontSize',16,'Interpreter','LaTeX')
    title(['Linear Fit to Q-function of n-lightbulb meta-MDP, R^2=',num2str(R2)],'FontSize',16)
    saveas(fig_Q,'../results/figures/QFitNBulbs.fig')
    saveas(fig_Q,'../results/figures/QFitNBulbs.png')
    
    load ../results/nlightbulb_problem
    nlightbulb_problem(c).mdp=lightbulb_mdp(c);
    nlightbulb_problem(c).fit.w=w;
    nlightbulb_problem(c).fit.Q_star=Q_star;
    nlightbulb_problem(c).fit.Q_hat=Q_hat;
    nlightbulb_problem(c).fit.R2=R2;
    nlightbulb_problem(c).fit.feature_names=feature_names;
    nlightbulb_problem(c).fit.features=X;
    nlightbulb_problem(c).optimal_PR=nlightbulb_problem(c).mdp.optimal_PR;
end
save('../results/nlightbulb_fit.mat','nlightbulb_problem')