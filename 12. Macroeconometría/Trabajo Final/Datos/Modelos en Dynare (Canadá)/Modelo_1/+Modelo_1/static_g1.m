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
    T = Modelo_1.static_g1_tt(T, y, x, params);
end
g1 = zeros(14, 14);
g1(1,1)=(-((1-params(1))*1/y(5)));
g1(1,5)=getPowerDeriv(y(5),params(4)-1,1)-(1-params(1))*(-y(1))/(y(5)*y(5));
g1(2,1)=(-(T(2)*y(12)*params(1)*1/y(3)));
g1(2,2)=T(9)-T(3)*y(12)*T(9);
g1(2,3)=(-(T(2)*y(12)*params(1)*(-y(1))/(y(3)*y(3))));
g1(2,5)=T(13)-T(3)*y(12)*T(13);
g1(2,12)=(-(T(2)*T(3)));
g1(3,2)=T(9)-(T(11)+(1+params(8))*y(12)*(T(9)-T(11)));
g1(3,5)=T(13)-(y(13)*(-params(6))*T(10)*T(12)+(1+params(8))*y(12)*(T(13)-y(13)*(-params(6))*T(10)*T(12)));
g1(3,12)=(-((T(2)-T(5))*(1+params(8))));
g1(3,13)=(-((-params(6))*T(4)-1+(1+params(8))*y(12)*(-((-params(6))*T(4)-1))));
g1(4,1)=(-1);
g1(4,2)=1;
g1(4,4)=1;
g1(4,9)=params(8);
g1(5,1)=1;
g1(5,3)=(-(T(8)*y(6)*getPowerDeriv(y(3),params(1),1)));
g1(5,5)=(-(T(7)*getPowerDeriv(y(5),1-params(1),1)));
g1(5,6)=(-(T(6)*T(8)));
g1(6,2)=(-T(10));
g1(6,5)=(-(T(10)*T(12)));
g1(6,12)=1;
g1(7,3)=1-(1-params(2));
g1(7,4)=(-1);
g1(8,2)=(-((-(T(9)/(1-params(3))))/(1-y(12))));
g1(8,5)=(-((-(T(13)/(1-params(3))))/(1-y(12))));
g1(8,12)=(-((-(T(2)/(1-params(3))))/((1-y(12))*(1-y(12)))));
g1(8,13)=1;
g1(9,6)=1/y(6)-params(7)*1/y(6);
g1(10,1)=(-100);
g1(10,2)=100;
g1(10,4)=100;
g1(10,10)=1;
g1(11,9)=y(14);
g1(11,10)=(-1);
g1(11,11)=1;
g1(11,14)=y(9);
g1(12,1)=(-(1/y(5)));
g1(12,5)=(-((-y(1))/(y(5)*y(5))));
g1(12,7)=1;
g1(13,14)=1;
g1(14,1)=(-((1-params(1))*1/y(5)));
g1(14,5)=(-((1-params(1))*(-y(1))/(y(5)*y(5))));
g1(14,8)=1;

end
