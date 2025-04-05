function [hpcycle, hptrend] = hpfilter( y, lambda )
% Function [hpcycle, hptrend] = hpfilter(y,lambda) computes the
% Hodrick-Prescott trend and cycle filter given data "y" (y can contain 
% multiple time series), and the smoothing parameter "lambda".
% Recommended values for lambda: 
%   for quarterly series, lambda=1600;
%   for monthly series, lambda=14400; and
%   for annual series, lambda=100.
%
% Inputs:
% y     : T x n array, where T denotes time observations, and n denotes
%         different series. Array "y" must have series over columns and
%         observations over rows.
% lambda: smoothing parameter
%
% Output:
% hpcycle: Cycle component of HP filter
% hptrend: Trend component of HP filter
% 
% Constantino Hevia, July 2008.
% Modified:
%  1. September 2012: added cycle component to output and imposed specific
%  structure to input array y.
%  2. June 2013: change order of output, with program delivering first the
%  cycle component

T = size(y,1); 
P = spdiags( repmat([1 -2 1], T-2, 1), 0:2, T-2 , T );
hptrend = ( speye(T)+lambda*(P'*P) )\y;
hpcycle = y - hptrend;