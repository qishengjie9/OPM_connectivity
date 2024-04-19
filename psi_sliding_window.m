function psi = psi_sliding_window(data,srate,window,step,fmin,fmax)

%%
[nb_signals, nb_samples] = size(data);

elec.chanpos = zeros(nb_signals,3);
elec.elecpos = zeros(nb_signals,3);
elec.unit = 'm';
for i = 1:nb_signals
    elec.label(i,1) = {['S' num2str(i)]};
end

ftData.fsample = srate;
ftData.elec = elec;
ftData.label = elec.label';

%%
win_samples = ceil(window*srate);
nb_shifts  = ceil(step*srate);

mid_window = win_samples/2:nb_shifts:nb_samples-win_samples/2;
nb_windows = length(mid_window);

for i = 1:nb_windows
    ftData.time{i} =  0:1/srate:((win_samples/srate)-1/srate);
    ftData.trial{i} = data(:,1 + mid_window(i) - win_samples/2 : mid_window(i)+win_samples/2);
end

%% cross-spectrum
cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'fourier';
cfg.tapsmofrq = 2;
cfg.foilim = [fmin,fmax];
freq = ft_freqanalysis(cfg, ftData);

% cfg = [];
% cfg.method = 'mtmfft';
% cfg.output = 'powandcsd';
% cfg.taper = 'hanning';
% cfg.foilim = [fmin,fmax];
% cfg.pad = 'nextpow2';
% cfg.keeptrials = 'yes';

% cfg.foi = 10;
% cfg.tapsmofrq = 2;

%freq = ft_freqanalysis(cfg, ftData);

%% wpli
cfg = [];
cfg.method = 'psi';
cfg.bandwidth = 2;
conn_psi = ft_connectivityanalysis(cfg,freq);
%conn_psi2 = mean(abs(conn_psi.psispctrm),2);
psi = mean(conn_psi.psispctrm,3);
%     conn_wpli = abs(mean(conn_wpli.wplispctrm,2));

heatmap(psi);

% psi = zeros(66,66);
% for c = 1:65
%     ids = 1:66-c;
%     psi (c+1:66,c) = conn_psi2(ids,1);
%     conn_psi2(ids) = [];
% end
% 
% psi = psi + psi.';
% wpli = conn_wpli;
end


