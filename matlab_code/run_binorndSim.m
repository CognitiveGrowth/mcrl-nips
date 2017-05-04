clear all;
cd ~/Desktop/Tom_Griffiths/collapsingBoundsExp/matlab_code/
addpath(genpath('~/Documents/MATLAB/Add-Ons/Toolboxes/Markov Decision Processes (MDP) Toolbox'))

%%

% tic
% c = .1;
% s = 0;
% for t = 1:ceil(1/c)
%     s = s + t + 1;
% end
% S = nan(s,2);
% R = nan(s,2);
% P = zeros(s);
% s = 0;
% for t = 1:ceil(1/c)
%     for i = 1:t+1
%         S(s+i,:) = [i, t+2-i];
%         R(s+i,:) = [i/(t+2), (t+2-i)/(t+2)];
%         P(s+i,s+i+t+1:s+i+t+2) = fliplr(R(s+i,:));
%     end
%     s = s + t + 1;
% end
% R = max(R,[],2);
% P = P(1:s,1:s);
% toc


%%


costs = .005:.001:.1;%[.1 .05 .01 .005];%.005:.001:.01; %.99;%.002:.002:.004; %[.005 .01 .05]; %.0005 .001    %logspace(log10(.1/213),log10(.05),8);%[.1 .05 .01 .005 .001];
discount = .99999;

for cc = 1:length(costs)
    tic
    disp(num2str(cc))
    c = costs(cc);
    max_samples = max(ceil(.7/c), 10);
    s = max_samples*(max_samples+1)/2 + max_samples + 1; % size of state space
    S = nan(s,2);
    R = nan(s,2);
    P = zeros(s);
    P2 = [zeros(s,s-1) ones(s,1)];
    s = 0;
    for t = 0:max_samples
        for i = 1:t+1 % possible states for each sample
            S(s+i,:) = [i, t+2-i];
            if s+i+t+1 > size(P,1)
                R(s+i,:) = 0;
                P(s+i,end) = 0;
                P2(s+i,end) = 0;
            else
                R(s+i,:) = [i/(t+2), (t+2-i)/(t+2)];
                P(s+i,s+i+t+1:s+i+t+2) = fliplr(R(s+i,:));
            end
        end
        s = s + t + 1;
    end
    P = cat(3,P,P2);
    R = [-c*ones(s,1), max(R,[],2)];
% %     R = [-c.*[1:s]', max(R,[],2)];
    [values, policy] = mdp_LP(P, R, discount);
    last_sample = find(policy==1,1,'last');
    if last_sample > (s - 2*max_samples - 1)
        error('state space too small')
    else
        last_sample = [(-1.5+sqrt(1.5^2-4*.5*-last_sample))/(2*.5) (-1.5-sqrt(1.5^2-4*.5*-last_sample))/(2*.5)];
        disp(['max samples: ',num2str(ceil(max(last_sample))),' (state space ',num2str(max_samples),' ',num2str(ceil(max(last_sample))/max_samples),')'])
    end
    
    pseudoR = nan(size(S,1),1);
    for i = 1:size(S,1)
        idxH = find(S(:,1)==(S(i,1)+1) & S(:,2)==S(i,2));
        idxT = find(S(:,1)==S(i,1) & S(:,2)==(S(i,2)+1));
        if isempty(idxH) || isempty(idxT)
            continue
        end
        PRH = discount*values(idxH) - values(i);
        PRT = discount*values(idxT) - values(i);
        pseudoR(i) = S(i,1)/sum(S(i,:))*PRH + S(i,2)/sum(S(i,:))*PRT;
        % or could not count first state [1, 1] as actual flips: so
        % S(:,i)=S(:,i)-1;
    end
    
    save_mdp_output(['mdp_LP_output_',num2str(c),'.mat'],values,policy,P,R,S,discount,pseudoR,c)
    toc
end


%%

% ccc = .01;%[.001 .005 .01 .05 .1];
% ppp = .1:.2:.9;
%
% nSim = 100;
% discount = .999;
%
% avgReward = nan(nSim,length(ppp),length(ccc));
% N_samp = nan(nSim,length(ppp),length(ccc));
% pseudoR = nan(nSim,length(ppp),length(ccc),ceil(1/ccc(1)));
% reward = nan(nSim,length(ppp),length(ccc),ceil(1/ccc(1)));
% state_values = nan(nSim,length(ppp),length(ccc),ceil(1/ccc(1)));
%
% for cc = 1:length(ccc)
%     c = ccc(cc);
%     s = 0;
%     for t = 1:ceil(1/c)+1
%         s = s + t + 1;
%     end
%     S = nan(s,2);
%     R = nan(s,2);
%     P = zeros(s);
%     s = 0;
%     for t = 1:ceil(1/c)+1
%         for i = 1:t+1
%             S(s+i,:) = [i, t+2-i];
%             if s+i+t+1 > size(P,1)
%                 R(s+i,:) = 0;
%                 P(s+i,end) = 1;
%             else
%                 R(s+i,:) = [i/(t+2), (t+2-i)/(t+2)];
%                 P(s+i,s+i+t+1:s+i+t+2) = fliplr(R(s+i,:));
%             end
%         end
%         s = s + t + 1;
%     end
%     P = cat(3,P,[zeros(s,s-1) ones(s,1)]);
%     R = [-c*ones(s,1), max(R,[],2)];
%     for pp = 1:length(ppp)
%         p = ppp(pp);
%         for i = 1:nSim
%             n0 = 1;
%             n1 = 1;
%             sample = 1;
%             t = 0;
%             while sample
%                 if binornd(1,p)
%                     n1 = n1 + 1;
%                 else
%                     n0 = n0 + 1;
%                 end
%                 idx = find(S(:,1)==n1 & S(:,2)==n0);
%                 R = R(idx:end,:);
%                 P = P(idx:end,idx:end,:);
%                 S = S(idx:end,:);
%                 [values, policy] = mdp_LP(P, R, discount);
%                 t = t+1;
%                 sample = policy(1) == 1;
%                 R(:,2) = R(:,2) - c;
%                 state_values(i,pp,cc,t) = values(1);
%                 pseudoR(i,pp,cc,t) = discount*values(2) - values(1);
%             end
%             N_samp(i,pp,cc) = t;
%             avgReward(i,pp,cc) = -c*t + max(p,1-p);
%             reward(i,pp,cc) = -c*t + (binornd(1,p)==(abs(max(S(idx,:))-2)));
%         end
%     end
% end
% save('run_binorndSim_out','avgReward','reward','pseudoR','N_samp','state_values','ccc','ppp','nSim')