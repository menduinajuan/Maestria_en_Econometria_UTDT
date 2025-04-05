function T = static_resid_tt(T, y, x, params)
% function T = static_resid_tt(T, y, x, params)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T         [#temp variables by 1]  double   vector of temporary terms to be filled by function
%   y         [M_.endo_nbr by 1]      double   vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1]       double   vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1]     double   vector of parameter values in declaration order
%
% Output:
%   T         [#temp variables by 1]  double   vector of temporary terms
%

assert(length(T) >= 8);

T(1) = y(5)^params(4)/params(4);
T(2) = (y(2)-T(1))^(-params(3));
T(3) = 1+params(1)*y(1)/y(3)-params(2);
T(4) = (1+y(2)-T(1))^(-params(6));
T(5) = y(13)*((-params(6))*T(4)-1);
T(6) = y(3)^params(1);
T(7) = y(6)*T(6);
T(8) = y(5)^(1-params(1));

end
