function gc = gc_sliding_window(data,srate,window,step,fmin,fmax)

%%
% debiased = 1 --> debiased wPLI

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
% cfg = [];
% cfg.method = 'mtmfft';
% cfg.output = 'powandcsd';
% cfg.taper = 'hanning';
% cfg.foilim = [fmin,fmax];
% cfg.pad = 'nextpow2';
% cfg.keeptrials = 'yes';
cfg                   = [];
cfg.method    = 'mtmfft';
cfg.output    = 'fourier';
%cfg.foilim    = [fmin,fmax];
cfg.pad = 'nextpow2';
cfg.tapsmofrq = 2;
% cfg.foi = 10;
% cfg.tapsmofrq = 2;

freq = ft_freqanalysis(cfg, ftData);

%% wpli
cfg = [];
cfg.method = 'granger';
cfg.granger.conditional = 'no';
cfg.granger.sfmethod = 'bivariate';
conn_gc = ft_connectivityanalysis(cfg,freq);
[~, index_fre, ~] = intersect(conn_gc.freq,[8,9,10,11,12]);
conn_gc2 = mean(conn_gc.grangerspctrm(:,index_fre),2);
%     conn_wpli = abs(mean(conn_wpli.wplispctrm,2));


gc = zeros(66,66);
for c = 1:66
    ids_o = 1:65;
    if c == 1
        gc (c,2:end) = conn_gc2(ids_o,1);
        conn_gc2(ids_o) = [];
    elseif c == 66
        gc (c,1:65) = conn_gc2(ids_o,1); 
        conn_gc2(ids_o) = [];
    else
        gc (c,1:c-1) = conn_gc2(1:c-1,1);
        gc (c,c+1:66) = conn_gc2(c:65,1);
        %gc (c+1:66,c) = conn_gc(ids,1);
        conn_gc2(ids_o) = [];
    end
    
end
heatmap(gc);
%gc = gc + gc.';
% wpli = conn_wpli;
end


