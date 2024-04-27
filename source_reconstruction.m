function source = source_reconstruction(meg,srate,inv_meth,opm_space,noiseCov)
% compute MEG inverse solution using 'lcmv','ungmv','mne','wmne','sloreta', or 'eloreta'
% inputs: meg: nb_channels*nb_samples
% srate: sampling rate
% OPM_array: OPM_array based on which MEG data was computed. opm_space = 
%{'15mm','20mm','25mm','30mm','35mm','40mm'};.

% Outputs: reconstructed data: nb_regions*nb_times, nb_regions denotes the number
% of cortical sources, nb_times denotes the sample points.
load('Input/leadfield/Headmodel','ftHeadmodel')
load('Input/leadfield/sources','sources')
load(['Input/leadfield/ftLeadfield_order_66_ICBM_channels_' opm_space],'ftLeadfield')
load(['Input/leadfield/sim_opm_' opm_space],'D') % channel file
grad.label = D.sensors.meg.label;
grad.unit = D.sensors.meg.unit;
grad.coilpos = D.sensors.meg.chanpos;
grad.coilori = D.sensors.meg.chanori;
grad.chantype = D.sensors.meg.chantype;
% grad.chanunit = D.sensors.meg.chanunit;
% 
% load('inputs/sources_BS_order_66_Colin27','sources') % sources location and orientation
% load(['inputs/ft_channels_Colin27_channels_' montage],'elec') % channel file
% load('inputs/ftHeadmodel_Colin27','ftHeadmodel') % headmodel
% load(['inputs/ftLeadfield_BS_order_66_Colin27_channels_' montage],'ftLeadfield') % leadfield

%%

epoch_length = size(meg,2)/srate;
%filters = [];

ftData.trial{1} = meg;
ftData.time{1}  = 0:1/srate:epoch_length-1/srate;
ftData.grad = grad;
ftData.label = grad.label';
ftData.fsample = srate;
%clear meg

cfg                      = [];
cfg.covariance           = 'yes';
cfg.covariancewindow     = 'all';
cfg.keeptrials           = 'no';    %if 'yes' no avg field in the output struct
timelock                 = ft_timelockanalysis(cfg,ftData);

% General options
cfg = struct ; 
cfg.method = inv_meth ; % 'lcmv','ungmv','mne','wmne','sloreta', or 'eloreta'
cfg.sourcemodel = ftLeadfield ; % from output of ft_prepare_sourcemodel
cfg.sourcemodel.mom = transpose(sources.Orient);
cfg.headmodel = ftHeadmodel ; % from output of ft_prepare_headmodel
cfg.grad = grad ; % from output of ft_read_sens and aligned to headmodel
cfg.senstype = 'meg' ;
cfg.keepfilter = 'yes' ; % keep filters for resolution analysis


% Method specific options
switch inv_meth
    case 'lcmv'
%         cfg.lambda = 0.05 ; % set regulatization parameter
%         cfg.lcmv.fixedori        = 'no';
%         cfg.lcmv.keepfilter      = 'yes';
%         %cfg.lcmv.keepmom         = 'no';
%         cfg.keepleadfield        = 'no';
%         [~,source] = evalc('ft_sourceanalysis(cfg,timelock)') ; % do Fieldtrip source analysis
%         source = cell2mat(source.avg.mom) ; % add source data back to the source structure
    cfg                      = [];
    cfg.method               = 'lcmv';
    cfg.sourcemodel          = ftLeadfield;
    cfg.sourcemodel.mom      = transpose(sources.Orient);
    cfg.headmodel            = ftHeadmodel;
    cfg.lcmv.fixedori        = 'no';
    cfg.lcmv.keepfilter      = 'yes';
    cfg.lcmv.keepmom         = 'no';
    cfg.keepleadfield        = 'no';
    cfg.lcmv.lambda          = '5%'; % 1%';   % '5%'    '10%'   '15%'   '20%'    '25%'
    
    cfg.lcmv.projectnoise    = 'no';
    cfg.reducerank  = 2;
%     cfg.lcmv.weightnorm      = 'unitnoisegain';
    
    src                      = ft_sourceanalysis(cfg,timelock);
    
    filters(:,:)            = cell2mat(src.avg.filter);
    source = filters * meg;
        
    case 'ungmv'
        cfg.method = 'lcmv' ; % first construct the LCMV solution
        cfg.lambda = 0.05 ; % set regularization parameter
        [~,source] = evalc('ft_sourceanalysis(cfg,timelock)') ; % do Fieldtrip source analysis
        filt = cell2mat(source.avg.filter) ; % get filter
        filt = filt./vecnorm(filt,2,2) ; % normalize by vector norm of filter
        %S = filt*data.avg ; % construct source data
        source = filt*meg ; % construct source data
        
%         for i = 1:size(filt,1) 
%             source.avg.mom{i} = S(i,:) ; % add source data back to the source structure
%             source.avg.filter{i} = filt(i,:) ; % add filter back to the source structure
%         end
        
    case {'mne'}
        cfg.(inv_meth).lambda = 0.05 ; % set regularization parameter
        [~,source] = evalc('ft_sourceanalysis(cfg,timelock)') ; % do Fieldtrip source analysis
        tmp = zeros(66,size(meg,2));
        for i=1:66
            tmp(i,:) = (source.avg.mom{i})'*sources.Orient(i,:)';
        end
        source = tmp ; % add source data back to the source structure
    case {'sloreta'}
        cfg.(inv_meth).lambda = 0.05 ; % set regularization parameter
        [~,source] = evalc('ft_sourceanalysis(cfg,timelock)') ; % do Fieldtrip source analysis
        source = cell2mat(source.avg.mom);
        
    case {'eloreta'}
        cfg.(inv_meth).lambda = 0.05 ; % set regularization parameter
        [~,source] = evalc('ft_sourceanalysis(cfg,timelock)'); % do Fieldtrip source analysis
        source = cell2mat((source.avg.mom)') ; % add source data back to the source structure        
    case 'wmne'
        cfg.method = 'mne' ; 
        cfg.mne.lambda = 0.05 ; % set regularization parameter
        lf = cell2mat(ftLeadfield.leadfield) ; % get leadfield matrix
        cfg.mne.sourcecov = sparse(diag(1./sqrt(sum(lf.^2)))) ; % set weights to 1 over leadfield norm
        cfg.mne.scalesourcecov = true ; % scale to uniformity for comparison with MNE/eLORETA
        [~,source] = evalc('ft_sourceanalysis(cfg,timelock)') ; % do Fieldtrip source analysis 
        tmp = zeros(66,size(meg,2));
        for i=1:66
            tmp(i,:) = (source.avg.mom{i})'*sources.Orient(i,:)';
        end
        source = tmp ;
    otherwise
        error('Input method not known')

end
