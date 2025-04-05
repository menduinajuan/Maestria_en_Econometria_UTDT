function [W,L] = vcov_HAC( X, prewhiten )
% This program computes the heteroskedasticity and autocorrelation
% consistent long-run covariance matrix used in GMM estimation. The program
% allows for prewhitening the data running a VAR(1). The data has to be
% arranged so that observations are in rows, and variables in columns.
%
% Inputs:
% X: data (T x k) matrix
% prewhite: (>0 or 0): if >0, prewhiten the data, if =0 it doesn't. This is
% an optional argument: the default value is prewhite=0;
%
% Output:
% W: HAC covariance matrix
% L: Number of lags used in doing Newey-West.
%
if nargin<2; 
    prewhiten = 0; 
end

[T,k] = size(X);

if prewhiten > 0;    % Run VAR(1) (without constant) on the data
    rhv = X(1:T-1,:);
    lhv = X(2:T,:);
    AA = (rhv'*rhv)\(rhv'*lhv);
    uu = lhv-rhv*AA;        % VAR residuals
    T=T-1;                  % Lose 1 observation because of estimating the VAR
    AA = AA';               % To matrix of coefficients in usual form
else
    uu = X;                 % No adjustment to the data
    AA = zeros(k);
end

L = round(0.75*T^(1/3));    % Number of lags to use in Newey-West

% Construct long-run covariance matrix of the inner part (S_in)
S_inner = uu'*uu/T;     %Estimate of covariance matrix at lag 0

for j = 1:L
    Gamma = uu(1+j:T,:)'*uu(1:T-j,:)/T;
    S_inner = S_inner + ( 1 - j/(L+1) )*( Gamma + Gamma' );
end

% HAC covariance matrix (adjusting for prewhitening, if needed)
W = ( (eye(k)-AA) \ S_inner ) / (eye(k)-AA') ; % This is inv(I-A)*S*inv(I-A')


