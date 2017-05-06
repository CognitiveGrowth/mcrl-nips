function f=feature_extractor(st,a,mdp)
n = mdp.nr_arms*mdp.features_per_a+8;
f = zeros(n,1);

stde=@(s) s(1)*s(2)/((s(1)+s(2))^2+(s(1)+s(2)+1));
t =@(s) s(1)+s(2);
b =@(s) max(s(1),s(2))/t(s);
mvoc =@(s) 1/(t(s)*(t(s)+1))*(s(1)* max(s(1)+1,s(2)) + s(2)*max(s(1),s(2)+1));

p = st(:,1)./sum(st,2);
[p_s,indices] = sort(p,'descend');


f(mdp.nr_arms*mdp.features_per_a+1) = p_s(1);
f(mdp.nr_arms*mdp.features_per_a+2) = stde(st(indices(1),:));
f(mdp.nr_arms*mdp.features_per_a+3) = p_s(1)*(1-p_s(1));

f(mdp.nr_arms*mdp.features_per_a+4) = p_s(2);
f(mdp.nr_arms*mdp.features_per_a+5) = stde(st(indices(2),:));
f(mdp.nr_arms*mdp.features_per_a+6) = p_s(2)*(1-p_s(2));

e_max = 1-(prod(1-p));
f(mdp.nr_arms*mdp.features_per_a+7) = e_max;
f(mdp.nr_arms*mdp.features_per_a+8) = e_max*(1-e_max);

for i=1:mdp.nr_arms
    al = st(i,:);
    if a == i
        arm_f = [stde(al), -t(al)*mdp.cost, 0, mvoc(al)-b(al), b(al)*mdp.rewardCorrect,1];
        
    else
        arm_f = [stde(al), -t(al)*mdp.cost, mdp.cost, mvoc(al)-b(al), mvoc(al)*mdp.rewardCorrect-mdp.cost,1];   
    end
    f((i-1)*mdp.features_per_a+1:i*mdp.features_per_a) = arm_f;
end

