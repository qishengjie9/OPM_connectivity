function meg = meg_add_noise(meg,data_brainnoise,opm_space)

% MEG direct problem
% Compute scalp MEG from cortical sources
%
% inputs: simulated_sources: cortical level sources, nb_regions*nb_samples,
% montage: name of the opm based on which MEG data will be
% generated {'SPMgainmatrix_sim_opm_15mm','SPMgainmatrix_sim_opm_20mm','SPMgainmatrix_sim_opm_25mm',
%'SPMgainmatrix_sim_opm_30mm',SPMgainmatrix_sim_opm_35mm,'SPMgainmatrix_sim_opm_40mm',}


% This code was originally developped by qishengjie.
% contact: qishengjie@buaa.edu.cn

%%
% load leadfield struct
addpath '.\sim_time_domain'
addpath '.\sim_time_domain\common_cal'
%load('Input/leadfield/sources','sources')
%load(['Input/leadfield/ftLeadfield_order_66_ICBM_channels_' opm_space],'ftLeadfield')
load(['Input/leadfield/brainnoise_ftLeadfield_order_66_ICBM_channels_' opm_space],'ftLeadfield')
load(['Input/mri_surface/tess_cortex_pial_low2'],'VertNormals')



load('Seeders');
load('index_full');
[~,brain_index]  = setdiff(index_full,Seeders);
db_source = 0.2;
db_sens = 0.1;
%load('brainnoise4mm_seed');
Nnoise      = length(index_full);
leadfields_const = zeros(size(ftLeadfield.label,1),Nnoise);
%% add biological noise to sensors
source_Orient = (VertNormals(index_full,:))';


% constrain the orientation of the sources to the normal to the surface
for i=1:Nnoise
    leadfields_const(:,i) = ftLeadfield.leadfield{i}*source_Orient(:,i);
end

% compute brain noise 
meg_brainnoise = leadfields_const(:,brain_index)*data_brainnoise(brain_index,:);
%rs_tmp              = G(:,index_full)*data_brainnoise;
SourceNoiseRatio=db_source* (sum(std(meg').^2)/length(std(meg')))^(1/2) / (sum(std(meg_brainnoise').^2)/length(std(meg_brainnoise')))^(1/2);
%SourceNoiseRatio2=db_source* rms(meg,'all')/rms(meg_brainnoise,'all');
noisesources  = SourceNoiseRatio*meg_brainnoise;

%% add sensor noise to Sensors
rs_tmp              = randn(size(meg));
%SourceNoise = db_sens*(sum(std(meg').^2)/length(std(meg')))^(1/2)/(sum(std(rs_tmp').^2)/length(std(rs_tmp')))^(1/2);
SensorNoiseRatio = db_sens*rms(meg,'all')/rms(rs_tmp,'all');
%SourceNoise2 = db_sens*rms(meg)/rms(rs_tmp);
noisesensors  = SensorNoiseRatio*rs_tmp;
%% add the Time Series Data and Biological Noise
meg = meg + noisesources+noisesensors;
end