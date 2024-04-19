function new_data = crosstalk_err(data_sim,crosstalkError,opm_space)

% add crosstalk error for the MEG data
%crosstalkError =0.05;
load(['Input/leadfield/sim_opm_' opm_space],'D') % channel file
sensor_pos = D.sensors.meg.chanpos;
if crosstalkError == 0
    new_data = data_sim;
else
    n_channels = size(sensor_pos,1);
    distance = zeros(n_channels);
%% create the crosstalk matrix
% obtain the distance between the sensors
    for i = 1:n_channels
        for j = 1:n_channels
            if(i == j)
                distance(i,j) = 50;%%50mm
            else
                distance(i,j) = norm(sensor_pos(i,:)-sensor_pos(j,:));
            end        
        end
    end
    distance_min = min(distance,[],'all');
    scale = (distance_min./distance).^3;%set the crosstalk is inversely proportional to the cube of distance
    scale = scale.*crosstalkError;
    scale = scale+eye(size(scale))-diag(diag(scale));
    %scale(logical(eye(size(scale)))) = 1;      % set the diagonal velue of scale to be 1
    tmp = zeros(size(data_sim));
% tmp2 = zeros(size(test.data));
% for i = 1:n_channels
%     for j = 1:n_channels
%         for t = 1:size(test.data,2)
%             tmp(i,t) = tmp(i,t)+test.data(j,t)*scale(i,j);
%         end       
%     end 
% end
    for t = 1:size(D.data,2)
        for i = 1:n_channels       
                tmp(i,t) = scale(i,1:n_channels)*data_sim(1:n_channels,t);     
        end 
    end
    %ori = D.data(); 
    new_data = tmp;
end

%cross = test.D.data();



