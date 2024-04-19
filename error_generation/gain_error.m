function data_out = gain_error(data_in,GainError)
% add gain error for the MEG data
if (GainError==0)
    data_out = data_in;
else
    for i = 1:size(data_in,1)
      tmp = 1 + (2 * rand(1) - 1) * GainError;
        for j = 1:size(data_in,2)
            data_out(i,j) = data_in(i,j)*tmp;
        end
    end
end
%norm(data_in-data_out);
%1-norm(data_in-data_out)/norm(data_in);
% add crosstalk error for the MEG data
%crosstalkError =0.05;