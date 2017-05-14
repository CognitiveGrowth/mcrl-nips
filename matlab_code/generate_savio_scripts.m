costs=[2,2.4,2.8];%[0.01,3.20,6.40,12.80];
nr_initial_values=24;
continue_previous_run=false;

evaluate_BSARSA=true;
evaluate_full_observation_policy=true;

for c=1:numel(costs)
    
    if evaluate_full_observation_policy
        script=['evaluateFullObservationPolicy(',num2str(costs(c)),');'];
        script_name=['observe_everything_SAVIO_',int2str(c),'.m'];
        
        fid=fopen(script_name,'w');
        fwrite(fid,script)
        fclose(fid)
        
        unix('cp ../savio_template.sh submit_job.sh')
        fid=fopen('submit_job.sh','a');
        fprintf(fid, ['\n','matlab -nodisplay -nodesktop -r "run ',...
            '/global/home/users/flieder/matlab_code/',script_name,'"']);
        fclose(fid);
        
        complete=unix('sbatch submit_job.sh')
    end
end

if evaluate_BSARSA
    for init=1:nr_initial_values
        for c=1:numel(costs)
            script=['solve_MouselabMDP_SAVIO(',num2str(costs(c)),',',...
                int2str(init),',',int2str(continue_previous_run),');'];
            script_name=['solve_MouselabMDP_SAVIO_',int2str(c),'_',int2str(init),'.m'];
            
            fid=fopen(script_name,'w');
            fwrite(fid,script)
            fclose(fid)
            
            unix('cp ../savio_template.sh submit_job.sh')
            fid=fopen('submit_job.sh','a');
            fprintf(fid, ['\n','matlab -nodisplay -nodesktop -r "run ',...
                '/global/home/users/flieder/matlab_code/',script_name,'"']);
            fclose(fid);
            
            complete=unix('sbatch submit_job.sh')
        end
    end
end