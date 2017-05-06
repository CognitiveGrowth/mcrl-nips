cost = 0.001;
voc1 = zeros(s,1);
voc2 = zeros(s,1);
vpi = zeros(s,1);
voc30 = zeros(s,1);
bias = ones(s,1);
stde=@(st) st(1)*st(2)/((st(1)+st(2))^2+(st(1)+st(2)+1));
stds = zeros(s,1);
to = zeros(s,1);
b = zeros(s,1);
for i=1:s
    st = S(i,:);
%     
%     stds(i) = stde(st);
%     
%     to(i) = sum(st);
%     
%     b(i) = max(st)/sum(st);
%     
%     t = st(1)+ st(2);   
%     mvoc = 1/(t*(t+1))*(st(1)*max(st(1)+1,st(2)) + st(2)*max(st(1),st(2)+1));
%     voc1(i) = mvoc-max(st)/sum(st)-cost;

    voc2(i) = nvoc(3,st,cost);
    
%     vpi(i) = 1 - max(st)/sum(st);
    vpi(i) = valueOfPerfectInformationBernoulli(st(1),st(2));
    
    voc30(i) = nvoc(33-sum(st),st,cost);
end
% X = cat(2,voc2,bias);
% X = cat(2,vpi,voc1,bias)
X = cat(2,vpi,voc2,bias);
[w,wint,r,rint,stats] = regress(voc30,X);
figure();
scatter(voc30,X*w);
title(num2str(stats(1)));