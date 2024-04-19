function [] = get_headmodel_and_leadfields()
% prepare headmodel and leadfield with fieldtrip for Colin27
SurfaceFiles = {'Input/mri_surface/tess_head2.mat';...
    'Input/mri_surface/tess_outerskull2.mat';...
    'Input/mri_surface/tess_innerskull2.mat'};

ftGeometry = BS_to_ft_tess(SurfaceFiles);

cfg = [];
cfg.method = 'openmeeg';


cfg.conductivity = [0.33,0.004125,0.33];
% cfg.tissue = ['scalp','skull','brain'];
ftHeadmodel = ft_prepare_headmodel(cfg, ftGeometry);

save('Input/leadfield/Headmodel','ftHeadmodel') % headmodel

%% leadfields
load('Input/leadfield/Headmodel','ftHeadmodel')
load('Input/leadfield/sources','sources')

% Convert to a FieldTrip grid structure
ftGrid.pos    = sources.Loc;            % source points
ftGrid.inside = 1:size(sources.Loc,1);  % all source points are inside of the brain
ftGrid.unit   = 'm';
opm_space = {'15mm','20mm','25mm','30mm','35mm','40mm'};
for m = 1:length(opm_space)
    load(['Input/leadfield/sim_opm_' opm_space{m}],'D') % channel file
    grad.label = D.sensors.meg.label;
    grad.unit = D.sensors.meg.unit;
    grad.coilpos = D.sensors.meg.coilpos;
    grad.coilori = D.sensors.meg.coilori;
    grad.chanpos = D.sensors.meg.chanpos;
    grad.chanori = D.sensors.meg.chanori;
    cfg = [];
    cfg.grad      = grad;
    cfg.grid      = ftGrid;
    cfg.reducerank     = 2;
    cfg.headmodel = ftHeadmodel;  % Volume conduction model
    
    ftLeadfield = ft_prepare_leadfield(cfg);
    
    save(['Input/leadfield/ftLeadfield_order_66_ICBM_channels_' opm_space{m}],'ftLeadfield')
end
end


