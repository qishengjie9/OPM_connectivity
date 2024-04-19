function meg = compute_meg2(simulated_sources, opm_space)

% MEG direct problem
% Compute scalp MEG from cortical sources
%
% inputs: simulated_sources: cortical level sources, nb_regions*nb_samples,
% montage: name of the opm based on which MEG data will be
% generated {'SPMgainmatrix_sim_opm_15mm','SPMgainmatrix_sim_opm_20mm','SPMgainmatrix_sim_opm_25mm',
%'SPMgainmatrix_sim_opm_30mm',SPMgainmatrix_sim_opm_35mm,'SPMgainmatrix_sim_opm_40mm',}


% This code was originally developped by Sahar Allouch.
% contact: saharallouch@gmail.com

%%
% load leadfield struct
addpath '.\sim_time_domain'
addpath '.\sim_time_domain\common_cal'
% load(['.\Input\leadfield\SPMgainmatrix_sim_opm_' opm_space],'G');
% load('Seeders');

% load(['inputs/ftLeadfield_BS_order_66_Colin27_channels_' montage],'ftLeadfield')
% 
% % load sources struct, sources.Orient = orientations of the sources
% load('inputs/sources_BS_order_66_Colin27','sources')
% source_Orient = transpose(sources.Orient);

load('Input/leadfield/sources','sources')
load(['Input/leadfield/ftLeadfield_order_66_ICBM_channels_' opm_space],'ftLeadfield')
source_Orient = transpose(sources.Orient);

leadfields_const = zeros(size(ftLeadfield.label,1),66);

% constrain the orientation of the sources to the normal to the surface
for i=1:66
    leadfields_const(:,i) = ftLeadfield.leadfield{i}*source_Orient(:,i);
end

% compute meg
meg = leadfields_const*simulated_sources;


end