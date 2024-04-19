function sigma = cal_sigma(theta0)
% Authors:
% - qishengjie

% Date: Jan 6, 2024
Fs = 256;
Fmin = 0;
Fmax = Fs/2;
fre_central = 10;
deltaf=1/60;
tstudent_a   = [900,600];
tstudent_b   = [5,9];
tstudent_dof = [3.2,60];
[Nseed,~]     = size(theta0);
[U0,D]        = svd(theta0);
D             = sqrt(D);
U0            = U0*D;
Iq            = eye(Nseed);
K0            = Iq - U0';
pha0          = angle(K0);
F             = Fmin:deltaf:Fmax;
pha_rate      = F/fre_central;
pha           = bsxfun(@times,pha0,reshape(pha_rate,1,1,length(F)));
K             = repmat(abs(K0),1,1,length(F)).*exp(1i *(pha));
phi = tstudent_spectra(F, tstudent_a(2),tstudent_b(2),tstudent_dof(2),fre_central);
phi = phi/max(phi);%scaling to 0-1;
K = K./repmat(reshape(phi,1,1,length(F)),Nseed,Nseed,1);
U = Iq - K;
for count = 1:length(F)
    theta(:,:,count) = U(:,:,count)'*U(:,:,count);
    sigma(:,:,count) = inv(theta(:,:,count));
end
end