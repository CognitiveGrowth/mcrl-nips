function save_mdp_output(name,values,policy,P,R,S,discount,pseudoR,c)

cost = c;
save(name,'values','policy','P','R','S','discount','pseudoR','cost')