function Q=getQFromV(V,T,R,gamma)

if not(exist('gamma','var'))
    gamma=1;
end

nr_states=size(V,1);
nr_actions=size(T,3);

Q=zeros(nr_states,nr_actions);

for s=1:nr_states
    for a=1:nr_actions
        Q(s,a)=T(s,:,a)*(gamma*V+R(s,a));
        if abs(Q(s,a))<0.1
            disp('problem!')
        end
    end
end

end