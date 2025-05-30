function g1 = dynamic_g1(T, y, x, params, steady_state, it_, T_flag)
% function g1 = dynamic_g1(T, y, x, params, steady_state, it_, T_flag)
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
%   g1
%

if T_flag
    T = Modelo_3.dynamic_g1_tt(T, y, x, params, steady_state, it_);
end
g1 = zeros(12, 20);
g1(1,4)=(-((1-params(1))*1/y(8)));
g1(1,8)=getPowerDeriv(y(8),params(4)-1,1)-(1-params(1))*(-y(4))/(y(8)*y(8));
g1(2,16)=(-(T(4)*params(1)*1/y(6)/(1+params(5)*(y(6)-y(1)))));
g1(2,5)=T(11);
g1(2,17)=(-(T(5)*params(9)*T(12)/(1+params(5)*(y(6)-y(1)))));
g1(2,1)=(-((-(T(6)*(-params(5))))/((1+params(5)*(y(6)-y(1)))*(1+params(5)*(y(6)-y(1))))));
g1(2,6)=(-(((1+params(5)*(y(6)-y(1)))*T(4)*(params(1)*(-y(16))/(y(6)*y(6))-params(5))-params(5)*T(6))/((1+params(5)*(y(6)-y(1)))*(1+params(5)*(y(6)-y(1))))));
g1(2,18)=(-(T(4)*params(5)/(1+params(5)*(y(6)-y(1)))));
g1(2,8)=T(13);
g1(2,19)=(-(T(5)*T(14)/(1+params(5)*(y(6)-y(1)))));
g1(3,5)=T(11);
g1(3,17)=(-((1+y(15))*params(9)*T(12)/(1-params(11)*(y(12)-params(10)))));
g1(3,8)=T(13);
g1(3,19)=(-((1+y(15))*T(14)/(1-params(11)*(y(12)-params(10)))));
g1(3,12)=(-((-(T(4)*(1+y(15))*(-params(11))))/((1-params(11)*(y(12)-params(10)))*(1-params(11)*(y(12)-params(10))))));
g1(3,15)=(-(T(4)/(1-params(11)*(y(12)-params(10)))));
g1(4,4)=(-1);
g1(4,5)=1;
g1(4,1)=params(5)/2*(-(2*(y(6)-y(1))));
g1(4,6)=params(5)/2*2*(y(6)-y(1));
g1(4,7)=1;
g1(4,3)=1+y(15);
g1(4,12)=params(11)/2*2*(y(12)-params(10))-1;
g1(4,15)=y(3);
g1(5,4)=1;
g1(5,1)=(-(T(10)*y(9)*getPowerDeriv(y(1),params(1),1)));
g1(5,8)=(-(T(9)*getPowerDeriv(y(8),1-params(1),1)));
g1(5,9)=(-(T(8)*T(10)));
g1(6,1)=(-(1-params(2)));
g1(6,6)=1;
g1(6,7)=(-1);
g1(7,2)=(-(params(6)*1/y(2)));
g1(7,9)=1/y(9);
g1(7,20)=(-1);
g1(8,4)=(-100);
g1(8,5)=100;
g1(8,1)=(-(100*(-(params(5)/2*(-(2*(y(6)-y(1))))))));
g1(8,6)=(-(100*(-(params(5)/2*2*(y(6)-y(1))))));
g1(8,7)=100;
g1(8,13)=1;
g1(9,3)=y(15)+params(11)*(exp(y(3)-params(10))-1)+y(3)*params(11)*exp(y(3)-params(10));
g1(9,13)=(-1);
g1(9,14)=1;
g1(9,15)=y(3);
g1(10,4)=(-(1/y(8)));
g1(10,8)=(-((-y(4))/(y(8)*y(8))));
g1(10,10)=1;
g1(11,15)=1;
g1(12,4)=(-((1-params(1))*1/y(8)));
g1(12,8)=(-((1-params(1))*(-y(4))/(y(8)*y(8))));
g1(12,11)=1;

end
