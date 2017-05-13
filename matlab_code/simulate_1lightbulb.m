function R_tot = simulate_1lightbulb(horizon,nEpisodes,S,T,R,PRs,epsilon,alpha,gamma)

Q = zeros(size(S));
nStates = size(T,1);
R_tot = zeros(1,nEpisodes);
% cc=[];
for e = 1:nEpisodes
    sp = 1;
    r_cum = 0;
%     c=0;
    while true
%         c=c+1;
        s = sp;
        a = e_greedy_selection( Q , s, epsilon );
        r = R(s,a) + PRs(s,a);
        r_cum = r_cum + R(s,a);
        sp = randsample(nStates,1,true,T(s,:,a));
        [Q, TD_error] = UpdateQLearning( s, a, r, sp, Q , alpha, gamma );
        if a == 2
%             cc=[cc,c];
            break
        end
    end
    R_tot(e) = r_cum;
end
end

function [ a ] = e_greedy_selection( Q , s, epsilon )
nactions = size(Q,2);
if (rand()>epsilon)
    a = GetBestAction(Q,s);
else
    a = randi(nactions);
end
end

function [ a ] = GetBestAction( Q, s )
nactions=size(Q,2);
[v idx]    = sort(Q(s,:),'descend');
x          = diff(v);
i          = find(x,1);
if isempty(i)
    a = randi(nactions);
else
    j = randi(i);
    a = idx(j);
end
end

function [ Q, TD_error ] = UpdateQLearning( s, a, r, sp, Q , alpha, gamma )
TD_error =   ((r + gamma*max(Q(sp,:))) - Q(s,a));
Q(s,a) =  Q(s,a) + alpha * TD_error;
end