function output = var_ls(data, p, pmax)

% ------------------------------------------------------------------------%
%
% function output = var_ls(data, p, pmax)
%
% Estimates a (reduced form) vector autoregression with "p" lags VAR(p) using
% least squares.
%
% -------------------------------------------------------------------------
%
% MODEL:
%
%  Y[t] = C + B_1*Y[t-1] +...+ B_p*Y[t-p] + eps[t]
%
%  where (1) t = -p+1,-p+2,...,0,1,2,...,T, and T is the number of usable
%            observations.
%        (2) Y[t] is a k x 1 vector of endogenous variables.
%        (3) p is the number of lags in the endogenous variables.
%
% -------------------------------------------------------------------------
%
% INPUTS:
%
% data = Matrix with the data. Each row represents one times series and
%        the number of columns is the total number of observations.
% p    = number of lags in VAR.
% pmax = (optional) Input to fix sample size in order to perform correct 
%        order selection criteria or likelihood ratio tests. pmax is the 
%        maximum lag to be tested. This argument fixes the sample size to
%        be always the same irrespective of the number of lags actually
%        tested.
%
% -------------------------------------------------------------------------
%
% OUTPUTS:
%
% output         = Structure with output of estimation.
% output.lags    = p: Number of lags in endogenous variables.
% output.coef    = Cell with "p" elements containing estimated matrices
%                  on estimated coefficients on lagged variables. For
%                  example, output.coef{1} contains B[1], and so forth.
% output.const   = Contains the estimate of the constant term.
% output.resid   = Array with estimated residuals.
% output.Omega   = k times k matrix with estimated covariance matrix of
%                  residuals.
% output.loglike = Log-likelihood value.
% output.AIC     = Akaike information criterion.
% output.SIC     = Schwarz (Bayesian) information criterion.
% output.HQC     = Hannan-Quinn information criterion.
% output.sderr   = Standard errors of the coefficients.
% output.tval    = T-values of coefficients.
%
% -------------------------------------------------------------------------
%
% Written by Constantino Hevia, June 2011.
% Modified April 2016. Added asymptotic standard errors and t-values.
%
% ------------------------------------------------------------------------%


% ------------------------------------------------------------------------%
% CHECK INPUT pmax %
% ------------------------------------------------------------------------%


if (nargin<3)
    pmax = p; 
end

if (p>pmax)
    error('Error in var_ls.m: Argument p needs to be less than or equal to argument pmax.')
end

if (nargin<2)
    error('Error: Function var_ls requires at least two arguments.')
end


% ------------------------------------------------------------------------%
% PREPROCESSING THE DATA %
% ------------------------------------------------------------------------%


% Write data with series across rows and time observation in columns

if (size(data,1)>size(data,2))
    data = data';
end

maxlag = max(pmax,p);          % To determine the actual sample
nobs   = size(data,2)-maxlag;  % Total number of usable observations
k      = size(data,1);         % Number of endogenous variables

if (nobs<=1)
    error('Error: Too few observations given the lag structure.')
end

% Construct LHS and RHS variables. See Lutkepohl, page 70

% LHS variables
Y = data(:,maxlag+1:end);

% RHS variables
Z = zeros(k*p+1,nobs);
Z(1,:) = 1;                    % First row is the constant

% Now fill other rows using lagged values
for i=1:p
    Z(2+(i-1)*k:1+i*k,:) = data(:,maxlag+1-i:maxlag+nobs-i);
end


% ------------------------------------------------------------------------%
% END PREPROCESSING THE DATA %
% ------------------------------------------------------------------------%


% PERFORM COMPUTATIONS

% With these notation, the model can be written as Y = beta*Z. Thus
beta  = Y*Z'/(Z*Z');        % OLS coefficients (3.2.10 in Lutkepohl)
resid = Y-beta*Z;           % Estimated residuals
Omega = resid*resid'/nobs;  % Covariance matrix of residuals

% Standard errors of beta in vectorized form (formula 3.2.21 in Lutkepohl) 
sderr_beta_vec = sqrt(diag(kron(inv(Z*Z'),Omega)));

% Put in same format as beta (matrix form)
sderr_beta = reshape(sderr_beta_vec,size(beta,1),size(beta,2));

% T-values
tval_beta = beta./sderr_beta;

% Log-likelihood and Information criterias
nv      = k*(k*p+1);        % Total number of explanatory variables
loglike = -(nobs/2)*(k*log(2*pi)+k+log(det(Omega)));
AIC     = (-2*loglike+2*nv)/nobs;
SIC     = (-2*loglike+nv*log(nobs))/nobs;
HQIC    = (-2*loglike+2*nv*log(log(nobs)))/nobs;
%fprintf('Log-likelihood value = %f \n\n', loglike)
%fprintf('Akaike (AIC)         = %f \n',   AIC)
%fprintf('Schwarz (SIC)        = %f \n',   SIC)
%fprintf('Hannan-Quinn (HQIC)  = %f \n',   HQIC)


% ------------------------------------------------------------------------%
% CREATE OUTPUT STRUCTURE TO EXPORT STUFF %
% ------------------------------------------------------------------------%


output             = struct;
output.lags        = p;                 % Number of lags in endogenous variables
output.const       = beta(:,1);         % Constant term
output.resid       = resid;             % Estimated residuals
output.Omega       = Omega;             % Estimated covariance matrix of residuals
output.loglike     = loglike;           % Log-likelihood value
output.AIC         = AIC;               % Akaike information criterion
output.SIC         = SIC;               % Schwarz (Bayesian) information criterion
output.HQC         = HQIC;              % Hannan-Quinn information criterion
output.nobs        = nobs;              % Number of usable observations
output.npar        = nv;                % Number of estimated parameters
output.coef        = cell(p,1);         % Coefficients on lagged values
output.sderr.const = sderr_beta(:,1);   % Standard errors of coefficients
output.sderr.coef  = cell(p,1);
output.tval.const  = tval_beta(:,1);    % T-values of coefficients
output.tval.coef   = cell(p,1);

for i=1:p
    output.coef{i}       = beta(:,2+(i-1)*k:1+i*k);
    output.sderr.coef{i} = sderr_beta(:,2+(i-1)*k:1+i*k);
    output.tval.coef{i}  = tval_beta(:,2+(i-1)*k:1+i*k);
end