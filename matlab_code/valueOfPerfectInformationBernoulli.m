function VPI=valueOfPerfectInformationBernoulli(alpha,beta)
%mu: vector of expected values of the returns of all possible actions
%sigma: corresponding standard deviations
%c: index of the action about which perfect information is being obtained

E_correct=[alpha,beta]/(alpha+beta);
[max_val,max_pos]=max(E_correct);

EV_original_preference = @(x) (alpha>beta)*x+(beta>alpha)*(1-x)+(alpha==beta)*0.5;


VPI = integral(@(x) betapdf(x,alpha,beta).*(max(x,1-x)-EV_original_preference(x)),0,1);    

end