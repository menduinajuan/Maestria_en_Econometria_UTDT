% Estimation of GMM asset pricing model
clear; close all
clc
% Pricing equation in terms of excess returns:
%
%         E_t[  (c(t+1)/c(t))^(-gamma) * Re(t+1) ] = 0
%
% where c(t+1)/c(t) is gross consumption growth, Re(t+1) is an excess
% return, and gamma is the coefficient of relative risk aversion

load cochrane_data.txt

% Choose dates
t0 = 1;
t1 = size(cochrane_data,1);

data = cochrane_data(t0:t1,:);

time = data(:,1);  % Year
dc   = data(:,2);  % Consumption growth (gross)
rmrf = data(:,3);  % Fama French return 1: Rm-Rf (market - risk free)
smb  = data(:,4);  % Fama French return 2: Small minus Big
hml  = data(:,5);  % Fama French return 3: high minus low (Value - growth)
rf   = data(:,6);  % Risk free rate (gross)

% 1) Find Mean and correlation matrix of consumption growth and the three
% excess returns (rmrf, smb, hml)

fprintf(' Mean of consumption growth and excess returns rmrf, smb, hml: \n');
disp(mean(data(:,2:5)));

fprintf('\n Correlation matrix consumption growth and excess returns: \n');
disp(corrcoef(data(:,2:5)));
fprintf(' ----------------------------------------------------------- \n');


% 2) Plot unconditional pricing equation using sample means as a function
% of gamma in [0,100]
%     E[  (c(t+1)/c(t))^(-gamma) * Re(t+1) ] = 0
%   
ngrid = 1000;
gamma = linspace(0,100,ngrid);

Err1 = zeros(ngrid,1);
Err2 = zeros(ngrid,1);
Err3 = zeros(ngrid,1);

for i=1:ngrid
    Err1(i) = mean( dc.^(-gamma(i)) .* rmrf );
    Err2(i) = mean( dc.^(-gamma(i)) .* hml );
    Err3(i) = mean( dc.^(-gamma(i)) .* smb  );
end

figure
plot(gamma,[Err1 Err2 Err3],'linewidth',2)
grid on
title('Unconditional mean of pricing conditions')
legend('rmrf','hml','smb')
xlabel('\gamma');
saveas(gcf,'AssetPricing_GMM','epsc');

% Note: Condition for SMB looks "wrong": there is no value of gamma that 
% makes the error equal to zero

% ------------------------------------------------------------------------
% Do GMM. Will use a version of the minimizer written by John Cochrane

% Some options for the optimizer
gamtol = 0.001;         % Tolerance gamma
tester = 0;             % If show intermediate results

T = length(dc);

% --------------------------------
% REGRESSION 1: MARKET EXCESS RETURN RMRF ALONE

% Step 1: Identity weigthing matrix. Since there is only one moment
% condition and one parameter, any weigthing matrix gives the same result.
W = 1;
xt = rmrf;
pt = zeros(size(xt));
[gam_rmrf,Jt_rmrf,gTl_rmrf,ut_rmrf] = min2(W,xt,pt,gamtol,tester,dc);

%   Standard errors.

%       Jacobian d (in this case is simple)
ut = ut_rmrf;
gam = gam_rmrf;
dcbig = dc*ones(1,size(xt,2));
ldcbig = log(dcbig);
d = -mean( ldcbig.*dc.^(-gam).*xt - pt)';

%       Long run covariance matrix S: Under the null hypothesis, u(t) is
%       uncorrelated, so it is easy to construct the long-run covariance
%       matrix: it is just the contemporaneous term. All autocorrelations
%       drop out (see Cochrane's Asset pricing book, page 223). No need to
%       do any Newey West weigthing in this case.
ut = ut - mean(ut);     % Subtract mean
Shat = ut'*ut / T;

% Standard error of estimate
aT = d'*W;
se_gam_rmrf = sqrt( (inv(aT*d)*(aT*Shat*aT')*inv(aT*d)')/T ); %#ok<MINV> % Standard error of inefficient GMM estimation

fprintf(' GMM using only RMRF, gamma = %g (%g)\n\n',gam_rmrf,se_gam_rmrf);
fprintf(' ----------------------------------------------------------------- \n');


% -----------------------------
% REGRESSION 2: HML alone

% Step 1: Identity weigthing matrix. Since there is only one moment
% condition, any weigthing matrix works.

W = 1;
xt = hml;
pt = zeros(size(xt));
[gam_hml,Jt_hml,gTl_hml,ut_hml] = min2(W,xt,pt,gamtol,tester,dc);

%   Standard errors. 

%       Jacobian d (in this case is simple)
ut = ut_hml;
gam = gam_hml;
dcbig = dc*ones(1,size(xt,2));
ldcbig = log(dcbig);

d = -mean( ldcbig.*dc.^(-gam).*xt - pt)';

%       Long run covariance matrix S under the null 
ut = ut - mean(ut);     % Subtract mean
Shat = ut'*ut / T;

% Standard error of estimate
aT = d'*W;
se_gam_hml = sqrt( (inv(aT*d)*(aT*Shat*aT')*inv(aT*d)')/T ); %#ok<MINV> % Standard error of inefficient GMM estimation

fprintf(' GMM using only HML , gamma = %g (%g)\n\n',gam_hml,se_gam_hml);
fprintf(' ----------------------------------------------------------------- \n');

% -----------------------------
% REGRESSION 3: SMB ALONE
W = 1;
xt = smb;
pt = zeros(size(xt));
[gam_smb,Jt_smb,gTl_smb,ut_smb] = min2(W,xt,pt,gamtol,tester,dc);

%   Standard errors. 

%       Jacobian d (in this case is simple)
ut = ut_smb;
gam = gam_smb;
dcbig = dc*ones(1,size(xt,2));
ldcbig = log(dcbig);

d = -mean( ldcbig.*dc.^(-gam).*xt - pt)';

%       Long run covariance matrix S under the null 
ut = ut - mean(ut);     % Subtract mean
Shat = ut'*ut / T;

% Standard error of estimate
aT = d'*W;
se_gam_smb = sqrt( (inv(aT*d)*(aT*Shat*aT')*inv(aT*d)')/T ); %#ok<MINV> % Standard error of inefficient GMM estimation

fprintf(' GMM using only SMB , gamma = %g (%g)\n\n',gam_smb,se_gam_smb);
fprintf(' ----------------------------------------------------------------- \n');

% -----------------------------
% REGRESSION 4: RMRF AND HML
% Step 1:
W = eye(2);
xt = [rmrf hml];
pt = zeros(size(xt));
[gam_4_step1,Jt_4_step1,gTl_4_step1,ut_4_step1] = min2(W,xt,pt,gamtol,tester,dc);

% Standard errors of step 1 and long-run covariance matrix for step 2
ut = ut_4_step1;
gam = gam_4_step1;
dcbig = dc*ones(1,size(xt,2));
ldcbig = log(dcbig);

d = -mean( ldcbig.*dcbig.^(-gam).*xt - pt)';

%       Long run covariance matrix S under the null 
ut = bsxfun(@minus,ut,mean(ut));     % Subtract mean
Shat = ut'*ut / T;

%       Standard errors of step 1:
aT = d'*W;
se_gam_4_step1 = sqrt( (inv(aT*d)*(aT*Shat*aT')*inv(aT*d)')/T ); %#ok<MINV> % Standard error of inefficient GMM estimation


%   d. Step 2, using optimal weithing matrix
W = inv(Shat);
[gam_4_opt,Jt_4_opt,gTl_4_opt,ut_4_opt] = min2(W,xt,pt,gamtol,tester,dc);

%   Standard errors. 
gam = gam_4_opt;
dcbig = dc*ones(1,size(xt,2));
ldcbig = log(dcbig);

d = -mean( ldcbig.*dcbig.^(-gam).*xt - pt)';

% Standard error of estimate
se_gam_4_opt = sqrt((inv(d'*inv(Shat)*d))/T); %#ok<MINV>
fprintf(' GMM using RMRF and HML. STEP 1: gamma = %g (%g)\n',gam_4_step1,se_gam_4_step1);
fprintf(' GMM using RMRF and HML. OPTIMAL: gamma = %g (%g)\n\n',gam_4_opt,se_gam_4_opt);


% Test of overidentifying restrictions:
Jstat = T*Jt_4_opt;                     % Value of J-test
npar = 1;                               % Number of parameters
nmom = length(gTl_4_opt);               % Number of moments
degfree = nmom-npar;                    % Degrees of freedom;

fprintf(' J-test of overidentifying restrictions\n');
fprintf(' --------------------------------------\n');
fprintf(' Number of moments   : %i\n',nmom);
fprintf(' Number of parameters: %i\n',npar);
fprintf(' Degrees of freedom  : %i\n',degfree);
fprintf(' Null hypothesis: Moments are zero \n');
fprintf(' J statistic: %g \n'  , Jstat);
fprintf(' p-value    : %g \n\n', 1-chi2cdf(Jstat,degfree));
fprintf(' ----------------------------------------------------------------- \n');

% -----------------------------
% REGRESSION 5: RMRF AND SMB
% Step 1:
W = eye(2);
xt = [rmrf smb];
pt = zeros(size(xt));
[gam_5_step1,Jt_5_step1,gTl_5_step1,ut_5_step1] = min2(W,xt,pt,gamtol,tester,dc);

% Standard errors of step 1 and long-run covariance matrix for step 2
ut = ut_5_step1;
gam = gam_5_step1;
dcbig = dc*ones(1,size(xt,2));
ldcbig = log(dcbig);

d = -mean( ldcbig.*dcbig.^(-gam).*xt - pt)';

%       Long run covariance matrix S under the null 
ut = bsxfun(@minus,ut,mean(ut));     % Subtract mean
Shat = ut'*ut / T;

%       Standard errors of step 1:
aT = d'*W;
se_gam_5_step1 = sqrt( (inv(aT*d)*(aT*Shat*aT')*inv(aT*d)')/T ); %#ok<MINV> % Standard error of inefficient GMM estimation


%   d. Step 2, using optimal weithing matrix
W = inv(Shat);
[gam_5_opt,Jt_5_opt,gTl_5_opt,ut_5_opt] = min2(W,xt,pt,gamtol,tester,dc);

%   Standard errors. 
gam = gam_5_opt;
dcbig = dc*ones(1,size(xt,2));
ldcbig = log(dcbig);

d = -mean( ldcbig.*dcbig.^(-gam).*xt - pt)';

% Standard error of estimate
se_gam_5_opt = sqrt((inv(d'*inv(Shat)*d))/T); %#ok<MINV>
fprintf(' GMM using RMRF and SMB. STEP 1: gamma = %g (%g)\n',gam_5_step1,se_gam_5_step1);
fprintf(' GMM using RMRF and SMB. OPTIMAL: gamma = %g (%g)\n\n',gam_5_opt,se_gam_5_opt);

% Test of overidentifying restrictions:
Jstat = T*Jt_5_opt;                     % Value of J-test
npar = 1;                               % Number of parameters
nmom = length(gTl_5_opt);               % Number of moments
degfree = nmom-npar;                    % Degrees of freedom;

fprintf(' J-test of overidentifying restrictions\n');
fprintf(' --------------------------------------\n');
fprintf(' Number of moments   : %i\n',nmom);
fprintf(' Number of parameters: %i\n',npar);
fprintf(' Degrees of freedom  : %i\n',degfree);
fprintf(' Null hypothesis: Moments are zero \n');
fprintf(' J statistic: %g \n'  , Jstat);
fprintf(' p-value    : %g \n\n', 1-chi2cdf(Jstat,degfree));

fprintf(' ----------------------------------------------------------------- \n');

% -----------------------------
% REGRESSION 6: RMRF, HML, AND SMB
% Step 1:
W = eye(3);
xt = [rmrf hml smb];
pt = zeros(size(xt));
[gam_6_step1,Jt_6_step1,gTl_6_step1,ut_6_step1] = min2(W,xt,pt,gamtol,tester,dc);

% Standard errors of step 1 and long-run covariance matrix for step 2
ut = ut_6_step1;
gam = gam_6_step1;
dcbig = dc*ones(1,size(xt,2));
ldcbig = log(dcbig);

d = -mean( ldcbig.*dcbig.^(-gam).*xt - pt)';

%       Long run covariance matrix S under the null 
ut = bsxfun(@minus,ut,mean(ut));     % Subtract mean
Shat = ut'*ut / T;

%       Standard errors of step 1:
aT = d'*W;
se_gam_6_step1 = sqrt( (inv(aT*d)*(aT*Shat*aT')*inv(aT*d)')/T ); %#ok<MINV> % Standard error of inefficient GMM estimation


%   d. Step 2, using optimal weithing matrix
W = inv(Shat);
[gam_6_opt,Jt_6_opt,gTl_6_opt,ut_6_opt] = min2(W,xt,pt,gamtol,tester,dc);

%   Standard errors. 
ut = ut_6_opt;
gam = gam_6_opt;
dcbig = dc*ones(1,size(xt,2));
ldcbig = log(dcbig);

d = -mean( ldcbig.*dcbig.^(-gam).*xt - pt)';

% Standard error of estimate
se_gam_6_opt = sqrt((inv(d'*inv(Shat)*d))/T); %#ok<MINV>
fprintf(' GMM using RMRF, HML, and SMB. STEP 1: gamma = %g (%g)\n',gam_6_step1,se_gam_6_step1);
fprintf(' GMM using RMRF, HML, and SMB. OPTIMAL: gamma = %g (%g)\n\n',gam_6_opt,se_gam_6_opt);

% Test of overidentifying restrictions:
Jstat = T*Jt_6_opt;                     % Value of J-test
npar = 1;                               % Number of parameters
nmom = length(gTl_6_opt);               % Number of moments
degfree = nmom-npar;                    % Degrees of freedom;

fprintf(' J-test of overidentifying restrictions\n');
fprintf(' --------------------------------------\n');
fprintf(' Number of moments   : %i\n',nmom);
fprintf(' Number of parameters: %i\n',npar);
fprintf(' Degrees of freedom  : %i\n',degfree);
fprintf(' Null hypothesis: Moments are zero \n');
fprintf(' J statistic: %g \n'  , Jstat);
fprintf(' p-value        : %g \n\n', 1-chi2cdf(Jstat,degfree));

fprintf(' ----------------------------------------------------------------- \n');


