addpath('./MatlabTools/')

addpath('../')

exact

% tmp = matlab.desktop.editor.getActive;
% cd(fileparts(tmp.Filename));

costs=0.01;

nr_states=size(states,1)-1;
S=states(1:nr_states,:);
nr_arms = size(states(1,:),2)/2;

nr_observations=sum(states,2)-2*nr_arms;
max_nr_observations=max(nr_observations); 

valid_states=find(and(nr_observations<max_nr_observations,...
    nr_observations>=0));
s_vstates = size(valid_states);
n_vstates = s_vstates(1);


load ../results/nlightbulb_problem

%% Fill in the regressors
for c=1:numel(costs)
    Q_star=getQFromV(nlightbulb_mdp(c).v_star,nlightbulb_mdp(c).T,nlightbulb_mdp(c).R);
    cost = costs(c);
    voc1 = zeros(nr_states,nr_arms);
    vpi = zeros(nr_states,nr_arms);
    voc = zeros(nr_states,nr_arms);
    ers = zeros(nr_states,nr_arms);
    bias = ones(nr_states*nr_arms,1);
    state_action = zeros(nr_states,nr_arms);
    count = 0;
    for k=1:numel(valid_states)
        i = valid_states(k);
        st = S(i,:);  
        st_m = reshape(st,2,nr_arms)';
        er = max( st_m(:,1) ./ sum(st_m,2));
        for j=1:nr_arms
            count = count +1;
            state_action(i,j) = count;
            ers(i,j) = er;
            vpi(i,j) = valueOfPerfectInformationMultiArmBernoulli(st_m(:,1),st_m(:,2),j);
            voc1(i,j) = VOC1MultiArmBernoulli(st_m(:,1),st_m(:,2),j,cost);
            voc(i,j) = Q_star(i,j) - cost - er; %fix this by getting q_from_v
        end
    end
    
%% Regression
    vpiv = vpi(valid_states,:)';
    voc1v = voc1(valid_states,:)';
    ersv = ers(valid_states,:)';
    bias_size = nr_arms*n_vstates;
    X = cat(2,voc1v(:),vpiv(:),bias(1:bias_size));
    feature_names={'VOC1','VPI','1'};
%     X = cat(2,voc1(:),vpi(:),bias);
    
%     vocl = voc';
    voc_valid_states = voc(valid_states,:)';
    voc_valid_states = voc_valid_states(:);
    
    [w,wint,r,rint,stats] = regress(voc_valid_states,X);
    voc_hat=X*w;
    figure();
    scatter(voc_hat,voc_valid_states);
    title(['R^2=',num2str(stats(1))]);
    xlabel('Predicted VOC','FontSize',16)
    ylabel('VOC','FontSize',16)
    
    sign_disagreement=find(sign(voc_hat).*sign(voc_valid_states)==-1);
    numel(sign_disagreement)/numel(voc_valid_states);
    
    max(voc_valid_states(sign_disagreement));
    
    %% Plot fit to Q-function
    
    Q_hat=reshape(voc_hat,nr_arms,n_vstates)' + ersv' + cost;
    Q_hat=[Q_hat,ersv(1,:)'];
    V_hat=max(Q_hat,[],2);
    
%     R2=corr(Q_star(valid_states,:),Q_hat(valid_states,:))^2;
%     qs = Q_star(1:nr_states,:);
%     R2 = corr(qs(:),Q_hat(:))^2;
    qh = Q_hat(valid_states,:);
    qs = Q_star(valid_states,:);
    R2=corr(qs(:),qh(:))^2;
    
    fig_Q=figure();
    scatter(qh(:),qs(:))
    set(gca,'FontSize',16)
    xlabel(modelEquation(feature_names,w),'FontSize',16)
    ylabel('$Q^\star$','FontSize',16,'Interpreter','LaTeX')
    title(['Linear Fit to Q-function of n-lightbulb meta-MDP, R^2=',num2str(R2)],'FontSize',16)
    saveas(fig_Q,'../results/figures/QFitNBulbs.fig')
    saveas(fig_Q,'../results/figures/QFitNBulbs.png')
    
    load ../results/nlightbulb_problem
    nlightbulb_problem(c).mdp=nlightbulb_mdp(c);
    nlightbulb_problem(c).fit.w=w;
    nlightbulb_problem(c).fit.Q_star=qs;
    nlightbulb_problem(c).fit.Q_hat=Q_hat;
    nlightbulb_problem(c).fit.R2=R2;
    nlightbulb_problem(c).fit.feature_names=feature_names;
    nlightbulb_problem(c).fit.features=X;
%     nlightbulb_problem(c).optimal_PR=nlightbulb_problem(c).mdp.optimal_PR;
end
save('../results/nlightbulb_fit.mat','nlightbulb_problem')