function VPI=valueOfPerfectInformation(mu,sigma,c)
%mu: vector of expected values of the returns of all possible actions
%sigma: corresponding standard deviations
%c: index of the action about which perfect information is being obtained

[mu_sorted,pos_sorted]=sort(mu,'descend');

max_val=mu_sorted(1);
max_pos=pos_sorted(1);

secondbest_val=mu_sorted(2);
secondbest_pos=pos_sorted(2);

if c==max_pos
    %information is valuable if it reveals that action c is suboptimal
    ub=secondbest_val;
    lb=mu(c)-5*sigma(c);
    
    VPI = integral(@(x) normpdf(x,mu(c),sigma(c)).*(secondbest_val-x),lb,ub);    
else
    %information is valuable if it reveals that action is optimal
    ub=mu(c)+5*sigma(c);
    lb=max_val;
    
    if ub>lb
        VPI = integral(@(x) normpdf(x,mu(c),sigma(c)).*(x-max_val),lb,ub);
    else
        VPI=0;
    end
end


end