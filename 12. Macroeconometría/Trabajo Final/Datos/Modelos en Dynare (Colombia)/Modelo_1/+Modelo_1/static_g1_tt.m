function T = static_g1_tt(T, y, x, params)
% function T = static_g1_tt(T, y, x, params)
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

assert(length(T) >= 13);

T = Modelo_1.static_resid_tt(T, y, x, params);

T(9) = getPowerDeriv(y(2)-T(1),(-params(3)),1);
T(10) = getPowerDeriv(1+y(2)-T(1),(-params(6)),1);
T(11) = y(13)*(-params(6))*T(10);
T(12) = (-(getPowerDeriv(y(5),params(4),1)/params(4)));
T(13) = T(9)*T(12);

end
