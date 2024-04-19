function [] = run_all_epochs()
% addpath E:\matlab_toolbox\brainstorm3\
% addpath E:\matlab_toolbox\fieldtrip-master_29092019\
addpath '.\sim_time_domain';
srate = 256;
fmin = 8;
fmax = 12;

net = 'DMN_samelead_nonoise';
file_alpha = '.\source_timeseries\TimeDomain4mm\Alpha';
file_xi = '.\source_timeseries\TimeDomain4mm\xi';

for  s = 1:40
    for e = 1:5
        
        % read the alpha data
        load([file_alpha '/Subject_' num2str(s) '/alpha' '.mat']);
        load([file_xi '/Subject_' num2str(s) '/xi' '.mat']);
        load('Seeders');
        load('index_full');
        connections  = [15 16 19 20 27 28 45 46 49 50];
        index_background=setdiff(1:66,connections);
        [~, index_noise, ~] = intersect(index_full,Seeders(index_background),'stable');       
        
        data = data_alpha(:,:,e);
        data_brainnoise = data_xi(:,:,e);
        data_source=zeros(size(data));
        data_source(connections,:) = data(connections,:);
        data_source(index_background,:)=data_brainnoise(index_noise,:);
        % trim the first second of the simulations (model unstability)
        
        % remove DC offset
        data_source = remove_DC_offset(data_source);
        
        % normalize signals
        data_source = data_source./max(data_source,[],2);
        
        % bandpass filter
        data_filtered = bst_bandpass_filtfilt(data_source,srate,fmin,fmax);
        conn = {'plv','wpli','wpli_debiased','psi','aec','aec_orth'};
        
        for c = 1:length(conn)
            
            % get connectivity matrix
            cfg = [];
            cfg.srate = srate;
            cfg.fmin = fmin;
            cfg.fmax = fmax;
            cfg.conn_meth = conn{c};
            
            switch c
                case 1
                    cfg.window = 10/(fmin+(fmax-fmin)/2); % 10 cycles
                    cfg.step = cfg.window;  % no overlap
                case 2
                    cfg.window = 10/(fmin+(fmax-fmin)/2); % 10 sec
                    cfg.step = cfg.window; % 0.5 sec
                case 3
                    cfg.window = 10/(fmin+(fmax-fmin)/2); % 10 sec
                    cfg.step = cfg.window; % 0.5 sec
                case 4
                    cfg.window = 6; % 6 sec
                    cfg.step = 0.5; % 0.5 sec
                case 5
                    cfg.window = 6; % 6 sec
                    cfg.step = 0.5; % 0.5 sec
                case 6
                    cfg.window = 6; % 6 sec
                    cfg.step = 0.5; % 0.5 sec
            end
            
            % get connectivity matrix
            cmat_ref = get_connectivity(data_filtered,cfg);
            
            if exist([net '/cmats/Subject_' num2str(s)  '/epoch_' num2str(e)],'dir') ~= 7
                mkdir([net '/cmats/Subject_' num2str(s) '/epoch_' num2str(e)])
            end
            
            save([net '/cmats/Subject_' num2str(s)  '/epoch_' num2str(e) '/cmat_ref_' conn{c} '.mat'],'cmat_ref')
            
            %%
            opm_space = {'15mm','20mm','25mm','30mm','35mm','40mm'};
            %inv = {'mne','wmne','eloreta','lcmv','wlcmv'};
            inv = {'lcmv','wlcmv','mne','wmne','sloreta', 'eloreta'};
            for m = 1:length(opm_space)
                
                if strcmp(conn{c},'aec_orth') && ismember(opm_space{m},{'25mm','30mm','35mm','40mm'})
                    continue
                end
                
                for iv = 1:length(inv)                   
                    % compute scalp meg
                    meg = compute_meg(data_source,opm_space{m});
                    % add scalp MEG noise
                    %meg = additive_noise(meg,gamma(g)); %(gamma = [0.5,1]; 1 = no noise)
                    n_opm = size(meg,1);
                    noiseCov = eye(n_opm);
                    % noiseCov = inverse.CalculateNoiseCovarianceTimeWindow(eeg);
                        
                    % solving the inverse problem
                    %filters = get_inverse_solution(meg,srate,inv{iv},opm_space{m},noiseCov);
                        
                    est_data = source_reconstruction(meg,srate,inv{iv},opm_space{m},noiseCov);
                    % bandpass filter
                    est_data = bst_bandpass_filtfilt(est_data,srate,fmin,fmax);
                        
                    % get connectivity matrix
                    cmat_est = get_connectivity(est_data,cfg);
%                   heatmap(cmat_est);
                    if exist([net '/cmats/Subject_' num2str(s) '/epoch_' num2str(e)],'dir') ~= 7
                       mkdir([net '/cmats/Subject_' num2str(s) '/epoch_' num2str(e)])
                    end
                        
                    save([net '/cmats/Subject_' num2str(s)  '/epoch_' num2str(e) '/cmat_est_' conn{c} '_' inv{iv} '_' opm_space{m} '.mat'],'cmat_est')
                end
            end
        end
    end
end
