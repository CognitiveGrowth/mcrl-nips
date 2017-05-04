clear all;
host = getenv('USER');
if strcmp(host(1:4),'paul')
    cd ~/Desktop/Tom_Griffiths/collapsingBoundsExp/matlab_code/
    addpath(genpath('~/Documents/MATLAB/Add-Ons/Toolboxes/Markov Decision Processes (MDP) Toolbox'))
else
    % Falk path goes here
    cd
    addpath(genpath(''))
end

%%

nTrials = 30;
rewardCorrect = 1;
rewardIncorrect = 0;
cost = 0.01;
discount = 1;
s = nTrials*(nTrials+1)/2; % size of state space
S = nan(s,2); % the states
R = nan(s,2); % rewards
P1 = zeros(s); % transition matrix for action 1
P2 = eye(s); % transition matrix for action 2 (state doesn't change)
min_trial = nan(s,1); % the minimum possible trial number for a given state

s = 0; % state index
for t = 1:nTrials
    for i = 1:t % t possible states at *begining* of each trial
        S(s+i,:) = [i, t+1-i]; % number of "heads," number of "tails"
        p_correct = [i/(t+1), (t+1-i)/(t+1)];
        R(s+i,:) = p_correct * rewardCorrect +(1-p_correct)*(rewardIncorrect); % reward for guessing each option   
        P1(s+i,s+i+t:s+i+t+1) = fliplr(p_correct);
        min_trial(s+i) = t;
    end
    s = s + t;
end
P1 = P1(1:s,1:s);
P = cat(3,P1,P2);
R = [cost*ones(s,1), max(R,[],2)]; % zero reward for action 1

[values, policy] = mdp_finite_horizon (P, R, discount, nTrials);

pseudoR_matrix = get_pseudoreward_matrix(S,values,min_trial,discount,R);
save('mdp_pseudorewards','values','policy','P','R','S','pseudoR_matrix','discount','nTrials','min_trial')
save(['mdp_pseudorewardsPlusExpectedR_',num2str(nTrials),'trials'],'values','policy','P','R','S','pseudoR_matrix','discount','nTrials','min_trial')
save(['mdp_pseudorewards_compareSARSA_',num2str(nTrials),'trials'],'values','policy','P','R','S','pseudoR_matrix','discount','nTrials','min_trial')

% save in format that falk requested
PR_observe = pseudoR_matrix(:,1:nTrials,1);
PR_bet = pseudoR_matrix(:,1:nTrials,2);
save(['TverskyEdwards_pseudorewards_',num2str(nTrials),'trials'],'PR_observe','PR_bet','S')
