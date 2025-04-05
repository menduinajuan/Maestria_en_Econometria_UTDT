function [x_hat,loglik] = kalman_filter( A, G, Q, R, Y, x0, Sigma0 )

% function [ x_hat, loglik ] = kalman_filter( A, G, Q, R, Y, x0, Sigma0 )
% 
% KALMAN_FILTER computes the Kalman filter and log-likelihood of the time
% invariant linear model in state space form:
%
%       x[t+1] = A x[t] + w[t+1]
%       y[t]   = G x[t] + v[t]
%
%       E[ w(t+1) w(t+1)' ] = Q
%       E[ v(t) v(t)' ]     = R
%       E[ w(t+1) w(s)' ]   = 0 for s ~= t+1 
%       E[ v(t) v(s)' ]     = 0 for s ~= t
%       E[ w(t+1) v(s)' ]   = 0 for all t,s.
% 
% where x[t] is the mx1 vector of states, y[t] is the px1 vector of
% observables, A is mxm, G is pxm, Q is mxm and R is pxp.
%
% INPUTS:
% 1) Matrices of state-space representation: A, G, Q, R.
% 2) Y  : Time series of the observables ( of dimension p x T )
% 3) x0 : Initial value of the state (typically, the unconditinoal mean)
% 4) Sigma0 : Initial Covariance matrix of the state (Optional Argument)
%
% OUTPUT:
% x_hat : Linear projection of x(t) on x(t-1), y(t), y(t-1),..., y(0)
% loglik: Loglikelihood of the model: sum_t log Prob(y_t)
%
% References:
% (1) Hamilton (1994) 'Time Series Analysis'
%
% Written By Constantino Hevia. November 2007.
% Modified March 4, 2008
% Modified August 10, 2011:
%   i. Do not use trace to compute log-likelihood)
%  ii. Add term p*log(2*pi) to likelihood value
% iii. Update covariance matrix in one step instead of two
% Modified October 2012:
%   i. Use reshape function to compute S0

% Compute dimensions
m     = size(A,1);      % Number of states
[p, T] = size(Y);        % p= number of observables, T=number of periods

if nargin<7     % Initialize Sigma0 to the unconditional covariance of x
    S0 = ( eye(m^2)-kron(A,A) ) \ Q(:);     % Vectorized Covariance
    Sigma0 = reshape(S0,m,m);               % Initial covariance matrix
end

x_hat = zeros(m,T+1);   % Initialize array for linear projections
x_hat(:,1) = x0;        % Initialize state
Sigma = Sigma0;         % Initialize covariance of x-x_hat
loglik = 0;             % Initialize log-likelihood 

for t=1:T   % Kalman Recursion
    Omega = G*Sigma*G'+R;                               % Covariance of y(t)-E(y(t)|x_hat(t),Y(t-1))
    K     = A*Sigma*G'/Omega;                           % Kalman Gain
    Sigma = (A-K*G)*Sigma*(A-K*G)' + Q + K*R*K';        % Update Covariance
    at = Y(:,t)-G*x_hat(:,t);                           % Innovation in Y(:,t)
    x_hat(:,t+1) = A*x_hat(:,t) + K * at;               % Projection of x(t+1)
    loglik = loglik + log(det(Omega)) + at'*(Omega\at); % Update log-likelihood
end
loglik = -0.5*( loglik + T*p*log(2*pi) ); % Log-likelihood value