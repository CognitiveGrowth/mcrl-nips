%submit Mouselab learnign simulations to Savio

nr_conditions=3;
nr_reps=100;
for r=1:nr_reps
    for c=1:nr_conditions
        job=['simulateMouselabLearningSavio(',int2str(r),',',int2str(c),')'];
        job_name=['Mouselab_learning_simulation_c',int2str(c),'_r',int2str(r),'.m'];
        submitJob2Savio(job,job_name)
    end
end