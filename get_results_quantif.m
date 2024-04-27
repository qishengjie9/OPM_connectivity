% results quantification
clear all

opm_space        = {'15mm','20mm','25mm','30mm','35mm','40mm'};
inv = {'lcmv','ungmv','mne','wmne','sloreta', 'eloreta'};
conn = {'plv','wpli','wpli_debiased','psi','aec','aec_orth'};

nb_subj     =   40;
nb_epochs   =   5;

nets = {'DMN10_samelead_nonoise'};

for n = 1:1%length(nets)
    % loop over all subjects
    for s = 1:nb_subj      
        % loop over all epochs of each subject
        for e = 1:nb_epochs
            % loop over connectivity measures
            for c = 1:length(conn)
                % load ref connectivity matrices
                load([nets{n} '/cmats/Subject_' num2str(s)  '/epoch_' num2str(e) '/cmat_ref_' conn{c}],'cmat_ref')
                p = 1;
                cmat_ref = threshold_proportional(cmat_ref,p);
                % loop over OPM array configurations
                for m = 1:length(opm_space)
                    % condition set because aec_orth does not exists
                    if strcmp(conn{c},'aec_orth') && ismember(opm_space{m},{'40mm'})
                         continue
                    end 
                    % loop over inverse methods
                    for iv = 1:length(inv)
                            
                        % load reconstructed network
                        load([nets{n} '/cmats/Subject_' num2str(s)  '/epoch_' num2str(e) '/cmat_est_' conn{c} '_' inv{iv} '_' opm_space{m} '_gamma_' num2str(gamma(g)) '.mat'],'cmat_est') 
                        p = 1;
%                       cmat_ref = threshold_proportional(cmat_ref,p);
                        cmat_est = threshold_proportional(cmat_est,p);
                        % pearson correlation
                        nb_rois = size(cmat_ref,1);
                        x = cmat_ref(triu(true(nb_rois),1));
                        y = cmat_est(triu(true(nb_rois),1));
%                       corr_mat = corrcoef(cmat_ref,cmat_est);
                        corr_mat = corrcoef(x,y);
                        results.pearson_correlation = corr_mat(1,2);  
                        % proportional threshold
                        p = (10*9)/(66*65); % keep only 30 edges == nb of edges in the reference network.
%                       p = 0.01;
                        cmat_ref_thre = threshold_proportional(cmat_ref,p);
                        cmat_est_thre = threshold_proportional(cmat_est,p);
                        % closeness acccuracy
                        results.closeness_accuracy = get_closeness_accuracy(cmat_ref_thre,cmat_est_thre); 
                        % edge contribution
                        tmp = get_edge_contribution(cmat_ref,cmat_est);
                        results.edge_contribution = tmp;   
                        if exist([nets{n} '/results/Subject_' num2str(s)  '/epoch_' num2str(e)],'dir') ~= 7
                             mkdir([nets{n} '/results/Subject_' num2str(s) '/epoch_' num2str(e)])
                        end                            
                        save([nets{n} '/results/Subject_' num2str(s)  '/epoch_' num2str(e) '/results_' conn{c} '_' inv{iv} '_' opm_space{m} '_no_thre_prop.mat'],'results');
                     end
                 end
             end
         end
     end
end
