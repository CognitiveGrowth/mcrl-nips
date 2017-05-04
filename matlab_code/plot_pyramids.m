clear all

costs = .2*[.05,.022,.015,.009,.005]; %.005:.001:.1;

treeDepths = [10 13 13 30];
% samples: 1,1,13,29
for cc = 1:length(costs)
    disp(num2str(cc))
    c = costs(cc);
    
    eval(['load(''mdp_LP_output_',num2str(c),'.mat'')'])
    
    ix_5050 = diff(S,1,2)==1;
    nObs(cc) = find(policy(ix_5050)==2,1,'first')*2-1;
    
     plot_stateValueTree(values,policy,S,pseudoR_matrix,min_trial,nTrials,R,start_state,trial_num,SAVE)
     plot_stateValueTree_old(values,policy,S,pseudoR,cost,treeDepths(cc))
    
end

loss = costs.*nObs;
qw=[costs',nObs',loss'];

% figure,plot(costs,[1 1 5 13 21 29]);
