function demo_plot(varargin)

    p = inputParser();
    p.addParameter('style', 'rectangle', @ischar);
    p.addParameter('ksdensity', true, @islogical);
    p.addParameter('seed', 1, @isscalar);
    p.addParameter('nGroups', 6, @isscalar);
    p.addParameter('nBars', 5, @isscalar);
    p.addParameter('labelRotation', 0, @isscalar);
    p.addParameter('labelAlignment', 'center', @ischar);
    p.addParameter('nBridgesWithin', 3, @isscalar);
    p.addParameter('nBridgesSpanning', 3, @isscalar);
    p.addParameter('allPositive', true, @islogical);
    p.addParameter('confidenceIntervals', false, @islogical);
    p.addParameter('avoidAdjacentBridges', false, @islogical);
    p.addParameter('bridgeTickLength', 0.1, @isscalar); % in mm, can be 0
    p.addParameter('bridgesExtendToBars', false, @islogical); 
    p.addParameter('result_plot',@ismatrix);
    %p.addParameter('result_plot');
    p.addParameter('file_save',@ischar);
    p.addParameter('inverse_method',@ischar);
    
    p.parse(varargin{:});

    s = RandStream('mt19937ar','Seed', p.Results.seed);
    RandStream.setGlobalStream(s);

    clf;
    bp = BarPlot('ylabel', p.Results.inverse_method);

    G = p.Results.nGroups;
    B = p.Results.nBars;

    cmap = parula(B);
    opm_space        = {'15mm','20mm','25mm','30mm','35mm','40mm'};

    for iG = 1:G
        %g = bp.addGroup(sprintf('Group %d', iG));
        g = bp.addGroup(opm_space(iG),'FontSize',15);
        for iB = 1:B
            if iG==6 && iB==6
                continue
            end
            barArgsCommon = {'FaceColor', cmap(iB, :)};%, ...
                %'LabelRotation', p.Results.labelRotation, ...
                %'HorizontalAlignment', p.Results.labelAlignment};
            
            if strcmp(p.Results.style, 'rectangle')
               
                tmp =squeeze(p.Results.result_plot(iG,iB,:));
                median_val = median(tmp);
                std_val = std(tmp);
                if p.Results.allPositive
                    median_val = abs(median_val);
                end
                
                if ~p.Results.confidenceIntervals
                    % draw error away from baseline
                    errorArgs =  {'error', std_val};
                else
                    % draw full interval error
                    errorArgs = {'errorHigh', abs(2*randn), 'errorLow', abs(2*randn)};
                end
%                 g.addBar([' '], median_val, 'labelAbove', sprintf('%.2f', median_val), ...
%                     errorArgs{:}, barArgsCommon{:});
                g.addBar([' '], median_val, errorArgs{:}, barArgsCommon{:},'FontSize',1);
                
            elseif strcmp(p.Results.style, 'violin')
                %v = 10*randn + 2*rand(100, 1);
                tmp =squeeze(p.Results.result_plot(iG,iB,:));
                tmp(tmp == 0)=[];
                if p.Results.ksdensity
                    g.addViolinBar(' ',tmp, 'locationType', 'median', 'style', 'ksdensity', barArgsCommon{:});
                else
                    g.addViolinBar(sprintf('Bar %d', iB), p.Results.result_plot(iG,iB,:), 'locationType', 'median', 'style', 'histogram', 'binWidth', 0.2, barArgsCommon{:});
                end
            end
        end

        % draw random subset of bridges
%         [I, J] = ndgrid(1:B, 1:B);
%         eligMat = J > I;
%         
%         for n = 1:p.Results.nBridgesWithin
%             if ~any(eligMat(:))
%                 break;
%             end
%             idxElig = find(eligMat(:));
%             idx = randsample(idxElig, 1);
%             [i, j] = ind2sub(size(eligMat), idx);
%             eligMat(i, j) = false;
%             g.addBridge(repmat('*', 1, min(4, j-i+1)), g.bars(i), g.bars(j), ...
%                 'tickLength', p.Results.bridgeTickLength, 'avoidAdjacentBridges', p.Results.avoidAdjacentBridges, ...
%                 'FontSize', 6, 'extendToBars', p.Results.bridgesExtendToBars);
%         end
    end

    % draw random subset of spanning bridges
%     [allBars, groupIdx] = bp.getAllBars();
%     N = numel(allBars);
%     [I, J] = ndgrid(1:N, 1:N);
%     eligMat = groupIdx(I) ~= groupIdx(J);
% 
%     for n = 1:p.Results.nBridgesSpanning
%         if ~any(eligMat)
%             break;
%         end
%         idxElig = find(eligMat(:));
%         idx = randsample(idxElig, 1);
%         [i, j] = ind2sub(size(eligMat), idx);
%         eligMat(i, j) = false;
%         bp.addBridge('**', allBars(i), allBars(j), ...
%             'tickLength', p.Results.bridgeTickLength, 'avoidAdjacentBridges', p.Results.avoidAdjacentBridges, ...
%             'FontSize', 6, 'extendToBars', p.Results.bridgesExtendToBars);
%     end

    bp.render();

    ax = AutoAxis(gca);
    ax.gridOn('y', 'yMinor', true);
    ax.tickFontSize = 15;
    ax.tickFontColor = [1,1,1];
    ax.tickLineWidth = 1;
    ax.update();
    saveas(gcf, p.Results.file_save); %保存当前窗口的图像
    %imwrite(img, p.Results.file_save); 
    %saveFigure(p.Results.file_save)
end
