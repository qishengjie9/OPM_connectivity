function eigenvalue = eigenvalue_calculate(data)
% normalized data
data_normalized = data/norm(data);
covariance_data = cov(data_normalized');
eigen = eig(covariance_data);
eigenvalue = sort(eigen,'descend');
