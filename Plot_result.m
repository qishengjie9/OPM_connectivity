% plot the violin or bar drawing of the results
net = 'DMN10_nonoise';

conn = {'plv','wpli','wpli_debiased','psi','aec','aec_orth'};
inv = {'lcmv','ungmv','mne','wmne','sloreta', 'eloreta'};
%opm_space = {'256','128','64','32','19'};
opm_space        = {'15mm','20mm','25mm','30mm','35mm','40mm'};
correlationmat = zeros(6,6,6,200);
closenessmat = zeros(6,6,6,200);
edgecontributionmat  = zeros(6,6,6,66,66);
edge_contribution = zeros(6,6,6);
correlation = {};
closeness  = {};
for m = 1:length(opm_space)
    for c = 1:length(conn)
        
        if strcmp(conn{c},'aec_orth') && ismember(opm_space{m},{'40mm'})
            continue
        end
        
        for iv = 1:length(inv)                 
            for s = 1:40
                for e = 1:5
                    %load([net '/cmats/Subject_' num2str(s) '/epoch_' num2str(e) '/cmat_est_' conn{c} '_' inv{i} '_Montage_' opm_space{m} '_gamma_' gamma '.mat'])
                    load([net '/results/Subject_' num2str(s)  '/epoch_' num2str(e) '/results_' conn{c} '_' inv{iv} '_' opm_space{m} '_no_thre_prop.mat'],'results');
                    correlationmat (m,c,iv,(s-1)*5+e) = results.pearson_correlation;
                    closenessmat(m,c,iv,(s-1)*5+e)  = results.closeness_accuracy;
                    edgecontributionmat(m,c,iv,:,:)  = squeeze(edgecontributionmat(m,c,iv,:,:))+results.edge_contribution;
                    correlation(end+1,:) = {results.pearson_correlation, opm_space{m}, conn{c},inv{iv},s,e}; 
                    closeness(end+1,:) = {results.closeness_accuracy, opm_space{m}, conn{c},inv{iv},s,e};
                end
            end          
        
        end
    end
end

%% for correlation csv file generation
col_correlation={'correlation', 'opm_space',...
    'connectivity_method','inverse_method','subject','epoch'};
filename_correlation = [net '/correlation.csv']; 
T_correlation = table(correlation(:,1),correlation(:,2),...
    correlation(:,3),correlation(:,4),...
    correlation(:,5),correlation(:,6),...
    'VariableNames',col_correlation);
writetable(T_correlation,filename_correlation,'Delimiter',',');
%% for closeness csv file generation
col_closeness={'closeness', 'opm_space',...
    'connectivity_method','inverse_method','subject','epoch'};
filename_closeness = [net '/closeness.csv']; 
T_closeness = table(closeness(:,1),closeness(:,2),...
    closeness(:,3),closeness(:,4),...
    closeness(:,5),closeness(:,6),...
    'VariableNames',col_closeness);
writetable(T_closeness,filename_closeness,'Delimiter',',');

for m = 1:length(opm_space)
    for c = 1:length(conn)
        
        if strcmp(conn{c},'aec_orth') && ismember(opm_space{m},{'40mm'})
            continue
        end
        for iv = 1:length(inv)
            tmp = squeeze(abs(edgecontributionmat(m,c,iv,:,:)));
            [~,ind] = sort(tmp(:),'descend');
            load('index_DMN.mat','index_DMN');           
            edge_contribution(m,c,iv) = sum(ismember(ind(1:30),index_DMN))/30;
        end
    end
end
%% for correlation plot

if exist([net '/correlation'],'dir') ~= 7
    mkdir([net '/correlation'])
end
for iv = 1:length(inv)
    %demo();
    result_plot = squeeze(correlationmat(:,:,iv,:));
    file_save = [net '/correlation/' inv{iv},'.png'];
    BarPlot.demo_plot('result_plot',result_plot,'file_save',file_save,'inverse_method',inv{iv});
end
%% for closeness plot
if exist([net '/closeness'],'dir') ~= 7
    mkdir([net '/closeness'])
end
for iv = 1:length(inv)
    %demo();
    result_plot = squeeze(closenessmat(:,:,iv,:));
    file_save = [net '/closeness/' inv{iv},'.png'];
    BarPlot.demo_plot('result_plot',result_plot,'file_save',file_save,'inverse_method',inv{iv});
end
%% for edge contribution plot
if exist([net '/edge_contribution'],'dir') ~= 7
    mkdir([net '/edge_contribution'])
end
for iv = 1:length(inv)
    %demo();
    result_plot = edge_contribution(:,:,iv);
    file_save = [net '/edge_contribution/' inv{iv},'.png'];
    BarPlot.demo_plot('result_plot',result_plot,'file_save',file_save,'inverse_method',inv{iv});
end
