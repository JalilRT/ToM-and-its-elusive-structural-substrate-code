% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'~\vbm_prepro_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});
