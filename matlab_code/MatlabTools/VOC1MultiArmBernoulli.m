function VOC1=VOC1MultiArmBernoulli(alphas,betas,c,cost)
%alphas: vector of alpha parameters of the Bernoulli distributions over the
%arms' reward probabilities
%betas: vector of the beta parameters of the Bernoulli distribtions over
%the arms' reward probabilities
%c: index of the action about which perfect information is being obtained

E_correct=alphas(:)./(alphas(:)+betas(:));
[sorted_values,arm_numbers]=sort(E_correct,'descend');

mu_alpha=sorted_values(1);
mu_beta=sorted_values(2);
alpha=arm_numbers(1);
beta=arm_numbers(2);


if c==alpha %information can only be valuable by revealing that alpha is actually suboptimal
    if (alphas(c)/(alphas(c)+betas(c)+1))<mu_beta %decison could change
        p_no_reward=(1-mu_alpha);
        delta_u=(mu_beta-alphas(c)/(alphas(c)+betas(c)+1));
        delta_EU=p_no_reward*delta_u;
    else
        delta_EU=0;
    end
else
    %information can only be valuable by revealing that c is actually
    %better than alpha
    if ((1+alphas(c))/(alphas(c)+betas(c)+1))>mu_alpha %decison could change
        p_reward=sorted_values(c);
        delta_u=((1+alphas(c))/(alphas(c)+betas(c)+1))-mu_alpha;
        delta_EU=p_reward*delta_u;
    else
        delta_EU=0;
    end
end

VOC1=delta_EU-cost;

end