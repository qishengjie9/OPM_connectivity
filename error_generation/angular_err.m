function coregfile = angular_err(simfile,errindex,angularError)
if (angularError ==0)
    coregfile = simfile;
else
    
    matlabbatch = [];
    matlabbatch{1}.spm.meeg.source.sensorshift.D = {simfile};
    matlabbatch{1}.spm.meeg.source.sensorshift.val = 1;
    matlabbatch{1}.spm.meeg.source.sensorshift.movewhat = 'independent';
    matlabbatch{1}.spm.meeg.source.sensorshift.meanshift = [0 0 0];
    matlabbatch{1}.spm.meeg.source.sensorshift.sdshift = [0 0 0];
    matlabbatch{1}.spm.meeg.source.sensorshift.meanangshift = [angularError angularError angularError];
    matlabbatch{1}.spm.meeg.source.sensorshift.sdangshift = [1 1 1];
    matlabbatch{1}.spm.meeg.source.sensorshift.outprefix = num2str(errindex);
    [a1,~]=spm_jobman('run', matlabbatch);
    tmp_file=cell2mat(a1{1,1}.D);

    matlabbatch = [];
    matlabbatch{1}.spm.meeg.source.headmodel.D = {tmp_file};
    matlabbatch{1}.spm.meeg.source.headmodel.val = 1;
    matlabbatch{1}.spm.meeg.source.headmodel.comment = '';
    matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.custom.mri = {'F:\simulation-paper\simulation-OPM\single_subj_T1.nii'};
    matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.custom.cortex = {deblank('F:\simulation-paper\simulation-OPM\cortex_20484.surf.gii')};
    %matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.custom.cortex = {deblank(cortex_anatModel)};
    matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.custom.iskull = {''};
    matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.custom.oskull = {''};
    matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.custom.scalp = {''};
    matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshres = 3;
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'nas';
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.type = [1 85 -41];
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'lpa';
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.type = [-83 -20 -65];
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'rpa';
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.type = [83 -20 -65];
    matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.useheadshape = 0;
    matlabbatch{1}.spm.meeg.source.headmodelhelmet.forward.eeg = 'EEG BEM';
    matlabbatch{1}.spm.meeg.source.headmodelhelmet.forward.meg = 'Single Shell';            

    [a2,~]=spm_jobman('run', matlabbatch);
    coregfile = cell2mat(a2{1}.D); 
end
% add gain error for the MEG data
