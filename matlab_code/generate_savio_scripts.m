costs=[0.05,0.10,0.20,0.40,0.80,1.60];

for c=1:numel(costs)
    
    script=['solve_MouselabMDP_SAVIO(',num2str(costs(c)),');'];
    script_name=['solve_MouselabMDP_SAVIO_',int2str(c),'.m'];
    
    fid=fopen(script_name,'w');
    fwrite(fid,script)
    fclose(fid)
    
    unix('cp ../savio_template.sh submit_job.sh')
    fid=fopen('submit_job.sh','a')
    fprintf(fid, ['\n','matlab -nodisplay -nodesktop -r "run ',...
        '/global/home/users/flieder/matlab_code/',script_name,'"']);
    fclose(fid);
    
    complete=unix('sbatch submit_job.sh')

     
end