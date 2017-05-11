in = 0.2021
[A,c] = min(abs(voc_hat + in))
[i,j] = find(state_action == c)


st = S(i,:);  
st_m = reshape(st,2,nr_arms)';
er = max(st_m(:,1) ./ sum(st_m,2));

vpiij = valueOfPerfectInformationMultiArmBernoulli(st_m(:,1),st_m(:,2),j);
voc1ij = VOC1MultiArmBernoulli(st_m(:,1),st_m(:,2),j,cost)-er;

f = [voc1ij,vpiij,er,1]
f*w
fp = X(c,:)
fp*w