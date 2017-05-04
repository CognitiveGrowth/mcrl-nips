%solve Gaussian meta-level MDP with backwards induction

%1. Define meta-level MDP
%a) define states
sigma0=1;
resolution=sigma0/50;
delta_mu_values=-2*sigma0:resolution:2*sigma0;
sigma_values=sigma0:-resolution:0.1;
[MUs,SIGMAs]=meshgrid(delta_mu_values,sigma_values);
nr_states=numel(MUs)+1; %each combination of mu and sigma is a state and there is one additional terminal state
nr_actions=2; %action 1: sample, action 2: act
cost=0.01;

%b) define transition matrix
T=zeros(nr_states,nr_states,nr_actions);
R=zeros(nr_states,nr_states,nr_actions);

R(:,:,1)=-cost; %cost of sampling

for from=1:(nr_states-1)
        current_mu=MUs(from);
        current_sigma=SIGMAs(from);
        sample_values=(current_mu-3*current_sigma):resolution:(current_mu+3*current_sigma);
        p_samples=discreteNormalPMF(sample_values,current_mu,current_sigma);
        
        %In this case, the prior is the likelihood. Hence, both have the
        %same precision. Therefore, the posterior mean is the average of
        %the prior mean and the observation, and the posterior precision is
        %twice as high as the current precision.
        
        posterior_means  = (current_mu + sample_values)/2;
        posterior_sigmas = repmat(1/sqrt(2*1/current_sigma^2),size(posterior_means));
        
        [discrepancy_mu, mu_index] = min(abs(repmat(posterior_means,[numel(delta_mu_values),1])-...
            repmat(delta_mu_values',[1,numel(posterior_means)])));

        [discrepancy_sigma, sigma_index] = min(abs(repmat(posterior_sigmas,[numel(sigma_values),1])-...
            repmat(sigma_values',[1,numel(posterior_sigmas)])));
        
        to=struct('mu',delta_mu_values(mu_index),'sigma',sigma_values(sigma_index),...
        'index',sub2ind([numel(sigma_values),numel(delta_mu_values)],sigma_index,mu_index));
        
        %sum the probabilities of all samples that lead to the same state
        T(from,unique(to.index),1)=grpstats(p_samples,to.index,{@sum});
        
        %reward of acting
        R(from,nr_states,2)=max(0,current_mu);
end
T(:,:,2)=repmat([zeros(1,nr_states-1),1],[nr_states,1]);
T(end,:,:)=repmat([zeros(1,nr_states-1),1],[1,1,2]);


start_state.delta_mu=0;
start_state.sigma=sigma0;
start_state.index=sub2ind(size(MUs),find(sigma_values==start_state.sigma),...
    find(delta_mu_values==start_state.delta_mu));

horizon=10;
gamma=1;

[V, optimal_policy, ~] = mdp_finite_horizon(T, R, gamma, horizon);

%compute the VOC
for t=1:horizon-1
    for from=1:(nr_states-1)
        VOC(from,t)=dot(T(from,:,1),V(:,t+1))-R(from,end,2)-cost;
        VPIs(from)=valueOfPerfectInformation([MUs(from),0],[SIGMAs(from),0],1);
    end
    VOC(nr_states,t)=0;
end

%%
for t=1:4
    
    fig1=figure(1)
    subplot(4,1,t)
    imagesc(delta_mu_values,sigma_values,reshape(V(1:end-1,t),size(MUs)))
    xlabel('\mu','FontSize',16)
    ylabel('\sigma','FontSize',16)
    title(['Optimal Value Function, Step ',int2str(t)],'FontSize',18)
    colorbar()
    
    fig2=figure(2)
    subplot(4,1,t)
    imagesc(delta_mu_values,sigma_values,reshape(optimal_policy(1:end-1,t),size(MUs)))
    xlabel('\Delta\mu','FontSize',16)
    ylabel('\sigma','FontSize',16)
    title(['Optimal Policy, Step ',int2str(t)],'FontSize',18)
    
    fig3=figure(3)
    subplot(4,1,t)
    imagesc(delta_mu_values,sigma_values,reshape(VOC(1:end-1,t),size(MUs)))
    xlabel('\Delta\mu','FontSize',16)
    ylabel('\sigma','FontSize',16)
    title(['VOC(sample), Step ',int2str(t)],'FontSize',18)
    colorbar
end

[r,p]=corr(VOC(:,end),VOC(:,1))
X=[VOC(1:end-1,end),VPIs(:),ones(size(VOC(1:end-1,1)))];
[beta,beta_int,residuals,r_int,stats]=regress(VOC(1:end-1,1),[VOC(1:end-1,end),VPIs(:),ones(size(VOC(1:end-1,1)))]);
VOC_hat = X*beta;

[beta_restricted,beta_int_restricted,residuals_restricted,r_int_restricted,stats_restricted]=...
    regress(VOC(1:end-1,1),[VOC(1:end-1,end),ones(size(VOC(1:end-1,1)))]);

[r_VOC1_VOC,p]=corr(VOC(1:end-1,end),VOC(1:end-1,1))
[r_VPI_VOC,p]=corr(VPIs(:),VOC(1:end-1,1))
[r_VOC1_VPI,p]=corr(VOC(1:end-1,end),VPIs(:))

figure()
imagesc(delta_mu_values,sigma_values,reshape(residuals,size(MUs)))
xlabel('\mu','FontSize',16)
ylabel('\sigma','FontSize',16)
colorbar()

fig4=figure(4)
plot(VOC_hat,VOC(1:end-1,1),'*')
xlim([-0.2,0.25]),ylim([-0.2,0.25])
xlabel('Prediction','FontSize',16)
ylabel('VOC','FontSize',16)
title(['VOC=',num2str(beta(1)),'\times VOC_1 + ',num2str(beta(2)),'\times VPI + ',num2str(beta(3)),', R^2=',num2str(stats(1))],'FontSize',16)

fig5=figure(5)
imagesc(delta_mu_values,sigma_values,reshape(VOC(1:end-1,1)-VOC(1:end-1,end-1),size(MUs)))
xlabel('\Delta\mu','FontSize',16)
ylabel('\sigma','FontSize',16)
title('VOC-VOC_1','FontSize',18)
colorbar()

V_hat=max(0,VOC(:,1)+R(:,end,2)) %V*(b)=max_c {VOC(b,c)+E[R|act,b]}
figure()
plot(V_hat,V(:,1),'x')

figure()
imagesc(delta_mu_values,sigma_values,reshape(V_hat(1:end-1),size(MUs)))
colorbar()


delta_V=V(1:end-1,1)-V_hat(1:end-1);
figure()
imagesc(delta_mu_values,sigma_values,reshape(delta_V,size(MUs)))
colorbar()



%% plot VOC_n as a function of n for mu=0, sigma=1

sigma_plot=[1,0.8,0.6];
mu_plot=[0,0.1,0.2];
[mu_grid,sigma_grid]=meshgrid(mu_plot,sigma_plot);


i=0;
for m=1:numel(mu_plot)
    for s=1:numel(sigma_plot)
        i=i+1;
        [~,m_ind]=min(abs(delta_mu_values-mu_plot(m)));
        [~,s_ind]=min(abs(sigma_values-sigma_plot(s)));
        state_index=sub2ind(size(MUs),s_ind,m_ind);
        
        VPI=valueOfPerfectInformation([mu_plot(m),0],[sigma_plot(s),0],1);
        
        fig6=figure(6)
        subplot(3,3,i)
        plot(VOC(state_index,end-1:-1:1)),hold on,
        ylabel('VOC_n','FontSize',16)
        xlabel('n','FontSize',16)
        %plot(5,VPI,'rx')
        %legend('VOC_n','VPI')
        title(['\mu=',num2str(mu_plot(m)),', \sigma=',...
            num2str(sigma_plot(s)),', VPI=',num2str(roundsd(VPI,2))],'FontSize',16)
    end
end