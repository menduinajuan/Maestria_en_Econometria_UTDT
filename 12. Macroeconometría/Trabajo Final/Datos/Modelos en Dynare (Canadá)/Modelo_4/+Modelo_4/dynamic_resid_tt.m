function T = dynamic_resid_tt(T, y, x, params, steady_state, it_)
% function T = dynamic_resid_tt(T, y, x, params, steady_state, it_)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double  vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double  vector of endogenous variables in the order stored
%                                                    in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double  matrix of exogenous variables (in declaration order)
%                                                    for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double  vector of steady state values
%   params        [M_.param_nbr by 1]        double  vector of parameter values in declaration order
%   it_           scalar                     double  time period for exogenous variables for which
%                                                    to evaluate the model
%
% Output:
%   T           [#temp variables by 1]       double  vector of temporary terms
%

assert(length(T) >= 10);

T(1) = y(5)-y(8)^params(4)/params(4);
T(2) = T(1)^(-params(3));
T(3) = y(19)-y(21)^params(4)/params(4);
T(4) = params(9)*T(3)^(-params(3));
T(5) = 1+params(1)*y(18)/y(6)-params(2)+params(5)*(y(20)-y(6));
T(6) = T(4)*T(5);
T(7) = params(5)/2*(y(6)-y(1))^2;
T(8) = y(1)^params(1);
T(9) = y(9)*T(8);
T(10) = y(8)^(1-params(1));

end
