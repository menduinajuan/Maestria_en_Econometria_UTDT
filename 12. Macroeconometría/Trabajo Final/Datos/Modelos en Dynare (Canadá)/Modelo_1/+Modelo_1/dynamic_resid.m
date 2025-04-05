function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
% function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double   vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double   vector of endogenous variables in the order stored
%                                                     in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double   matrix of exogenous variables (in declaration order)
%                                                     for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double   vector of steady state values
%   params        [M_.param_nbr by 1]        double   vector of parameter values in declaration order
%   it_           scalar                     double   time period for exogenous variables for which
%                                                     to evaluate the model
%   T_flag        boolean                    boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = Modelo_1.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(14, 1);
    residual(1) = (y(8)^(params(4)-1)) - ((1-params(1))*y(4)/y(8));
    residual(2) = (T(2)) - (T(6)/(1+params(5)*(y(6)-y(1))));
    residual(3) = (T(2)) - (y(15)*T(8)*(1+params(8))+y(16)*((-params(6))*T(9)-1));
    residual(4) = (y(5)+y(7)+T(10)+(1+params(8))*y(3)) - (y(4)+y(12));
    residual(5) = (y(4)) - (T(12)*T(13));
    residual(6) = (y(15)) - (T(9));
    residual(7) = (y(6)) - (y(7)+y(1)*(1-params(2)));
    residual(8) = (y(16)) - ((-(T(2)/(1-params(3))))/(1-y(15)));
    residual(9) = (log(y(9))) - (params(7)*log(y(2))+x(it_, 1));
    residual(10) = (y(13)) - (100*(y(4)-y(5)-y(7)-T(10)));
    residual(11) = (y(14)) - (y(13)-y(3)*y(17));
    residual(12) = (y(10)) - (y(4)/y(8));
    residual(13) = (y(17)) - (params(8));
    residual(14) = (y(11)) - ((1-params(1))*y(4)/y(8));

end
