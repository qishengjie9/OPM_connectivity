clear all
clc
addpath('H:\matlab toolbox\fieldtrip-master_29092019\fieldtrip-master'); % 替换为你的 FieldTrip 安装路径
% addpath E:\matlab_toolbox\brainstorm3\
% addpath E:\matlab_toolbox\fieldtrip-master_29092019\
addpath '.\sim_time_domain';
srate = 256;
trim = 1;
fmin = 8;
fmax = 12;

% gamma = 0.7; %(gamma = [0.5,1]; 1 = no noise)
net = 'DMN_samelead_nonoisecrosstalk';
file_alpha = '.\source_timeseries\HIGGS_TimeDomain4mm\Alpha';
file_xi = '.\source_timeseries\HIGGS_TimeDomain4mm\xi';
opm_space = {'15mm','20mm','25mm','30mm','35mm','40mm'};
% compute the eigenvalue of simulated meg data for all.

eigen_simulated = cell(10,6);
for  s = 1:40
    for m = 1:length(opm_space)
        
        % read the alpha data
        load([file_alpha '/Subject_' num2str(s) '/alpha' '.mat']);
        load([file_xi '/Subject_' num2str(s) '/xi' '.mat']);
        load('Seeders');
        load('index_full');
        connections  = [15 16 19 20 27 28 45 46 49 50];
        % 获取不相等的元素
        index_background=setdiff(1:66,connections);
        [~, index_noise, ~] = intersect(index_full,Seeders(index_background),'stable');       
        data_l = data_alpha(:,:,1);
        data_brainnoise = data_xi(:,:,1);
        data_source=zeros(size(data_l));
        data_source(connections,:) = data_l(connections,:);
        data_source(index_background,:)=data_brainnoise(index_noise,:);
        % remove DC offset
        data_source = remove_DC_offset(data_source);
        % normalize signals
        data_source = data_source./max(data_source,[],2);
        meg = compute_meg2(data_source,opm_space{m});
        eigen_simulated{s,m} = eigenvalue_calculate(meg);   
    end
end
cfg = [];
cfg.dataset = 'l1-jxt1-raw.fif'; % 替换为你实际的文件名
data_l = ft_preprocessing(cfg);
dataMatrix_l = cat(2, data_l.trial{:});
eigen_sub1 = eigenvalue_calculate(dataMatrix_l(1:end-1,1:15360));

cfg = [];
cfg.dataset = 'm1-jxt1-raw.fif'; % 替换为你实际的文件名
data_m = ft_preprocessing(cfg);
dataMatrix_m = cat(2, data_m.trial{:});
eigen_sub2 = eigenvalue_calculate(dataMatrix_m(1:end-1,1:15360));
cfg = [];
cfg.dataset = 'w1-jxt1-raw.fif'; % 替换为你实际的文件名
data_w = ft_preprocessing(cfg);
dataMatrix_w = cat(2, data_w.trial{:});
eigen_sub3 = eigenvalue_calculate(dataMatrix_w(1:end-1,1:15360));

plot([1:length(eigen_simulated{1,1})],eigen_simulated{1,1},'k--',...
     [1:length(eigen_simulated{1,2})],eigen_simulated{1,2},'g--',...
     [1:length(eigen_simulated{1,3})],eigen_simulated{1,3},'b--',...
     [1:length(eigen_simulated{1,4})],eigen_simulated{1,4},'c--',...
     [1:length(eigen_simulated{1,5})],eigen_simulated{1,5},'m--',...
     [1:length(eigen_simulated{1,6})],eigen_simulated{1,6},'r--',...
     [1:length(eigen_sub1)],eigen_sub1,'k',...
     [1:length(eigen_sub2)],eigen_sub2,'r',...
     [1:length(eigen_sub3)],eigen_sub3,'g',...
    'LineWidth',1.5)
plot([1:length(eigen_simulated{2,1})],eigen_simulated{2,1},'k--',...
     [1:length(eigen_simulated{2,2})],eigen_simulated{2,2},'g--',...
     [1:length(eigen_simulated{2,3})],eigen_simulated{2,3},'b--',...
     [1:length(eigen_simulated{2,4})],eigen_simulated{2,4},'c--',...
     [1:length(eigen_simulated{2,5})],eigen_simulated{2,5},'m--',...
     [1:length(eigen_simulated{2,6})],eigen_simulated{2,6},'r--',...
     [1:length(eigen_sub1)],eigen_sub1,'k',...
     [1:length(eigen_sub2)],eigen_sub2,'r',...
     [1:length(eigen_sub3)],eigen_sub3,'g',...
    'LineWidth',1.5)

set(gca, 'Box', 'off', ...                                         % 边框
         'XGrid', 'on', 'YGrid', 'on', ...                         % 网格
         'TickDir', 'out', 'TickLength', [.01 .01], ...            % 刻度
         'XMinorTick', 'off', 'YMinorTick', 'off')% X坐标轴刻度标签
legend_set = {'Sim_15mm','Sim_20mm','Sim_25mm','Sim_30mm','Sim_35mm','Sim_40mm','Sub_1','Sub_2','Sub_3'};
legend(legend_set,'Interpreter', 'latex');      
set(gca, 'FontName', 'Times New Roman')
%set(gca, 'FontName', 'Arial')
set(gca, 'FontSize', 14,'FontWeight' , 'bold','LineWidth',1)
set(gca,'xlabel')
% 设置横坐标的范围
xlim([0 100]);  % 设置横坐标范围从 0 到 12

% 设置纵坐标的范围
ylim([0 7e-5]);  % 设置纵坐标范围从 -1.5 到 1.5
disp(eigenvalues);