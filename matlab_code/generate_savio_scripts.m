costs=[0.05,0.10,0.20,0.40,0.80,1.60];
nr_initial_values=5;

for init=1:nr_initial_values
    for c=1:numel(costs)
        
        script=['solve_MouselabMDP_SAVIO(',num2str(costs(c)),',',int2str(init),');'];
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