function g1 = static_g1(T, y, x, params, T_flag)
% function g1 = static_g1(T, y, x, params, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T         [#temp variables by 1]  double   vector of temporary terms to be filled by function
%   y         [M_.endo_nbr by 1]      double   vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1]       double   vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1]     double   vector of parameter values in declaration order
%                                              to evaluate the model
%   T_flag    boolean                 boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   g1
%

if T_flag
    T = Modelo_2.static_g1_tt(T, y, x, params);
end
g1 = zeros(13, 13);
g1(1,1)=(-((1-params(1))*1/y(5)));
g1(1,5)=getPowerDeriv(y(5),params(4)-1,1)-(1-params(1))*(-y(1))/(y(5)*y(5));
g1(2,1)=(-(T(2)*params(9)*params(1)*1/y(3)));
g1(2,2)=T(7)-T(3)*params(9)*T(7);
g1(2,3)=(-(T(2)*params(9)*params(1)*(-y(1))/(y(3)*y(3))));
g1(2,5)=T(8)-T(3)*params(9)*T(8);
g1(3,2)=T(7)-(1+y(13))*params(9)*T(7);
g1(3,5)=T(8)-(1+y(13))*params(9)*T(8);
g1(3,13)=(-(T(2)*params(9)));
g1(4,1)=(-1);
g1(4,2)=1;
g1(4,4)=1;
g1(4,9)=y(13);
g1(4,13)=y(9);
g1(5,1)=1;
g1(5,3)=(-(T(6)*y(6)*getPowerDeriv(y(3),params(1),1)));
g1(5,5)=(-(T(5)*getPowerDeriv(y(5),1-params(1),1)));
g1(5,6)=(-(T(4)*T(6)));
g1(6,9)=(-(params(11)*exp(y(9)-params(10))));
g1(6,12)=1;
g1(7,3)=1-(1-params(2));
g1(7,4)=(-1);
g1(8,6)=1/y(6)-params(6)*1/y(6);
g1(9,1)=(-100);
g1(9,2)=100;
g1(9,4)=100;
g1(9,10)=1;
g1(10,9)=y(13);
g1(10,10)=(-1);
g1(10,11)=1;
g1(10,13)=y(9);
g1(11,1)=(-(1/y(5)));
g1(11,5)=(-((-y(1))/(y(5)*y(5))));
g1(11,7)=1;
g1(12,12)=(-1);
g1(12,13)=1;
g1(13,1)=(-((1-params(1))*1/y(5)));
g1(13,5)=(-((1-params(1))*(-y(1))/(y(5)*y(5))));
g1(13,8)=1;

end
