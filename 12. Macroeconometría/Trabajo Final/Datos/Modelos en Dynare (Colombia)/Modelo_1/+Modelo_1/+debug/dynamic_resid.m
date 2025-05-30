function [lhs, rhs] = dynamic_resid(y, x, params, steady_state)
T = NaN(13, 1);
lhs = NaN(14, 1);
rhs = NaN(14, 1);
T(1) = y(19)^params(4)/params(4);
T(2) = (y(16)-T(1))^(-params(3));
T(3) = y(33)^params(4)/params(4);
T(4) = (y(30)-T(3))^(-params(3));
T(5) = 1+params(1)*y(29)/y(17)-params(2)+params(5)*(y(31)-y(17));
T(6) = y(26)*T(4)*T(5);
T(7) = (-params(6))*(1+y(30)-T(3))^(-params(6))-1;
T(8) = T(4)-y(41)*T(7);
T(9) = (1+y(16)-T(1))^(-params(6));
T(10) = params(5)/2*(y(17)-y(3))^2;
T(11) = y(3)^params(1);
T(12) = y(20)*T(11);
T(13) = y(19)^(1-params(1));
lhs(1) = y(19)^(params(4)-1);
rhs(1) = (1-params(1))*y(15)/y(19);
lhs(2) = T(2);
rhs(2) = T(6)/(1+params(5)*(y(17)-y(3)));
lhs(3) = T(2);
rhs(3) = y(26)*T(8)*(1+params(8))+y(27)*((-params(6))*T(9)-1);
lhs(4) = y(16)+y(18)+T(10)+(1+params(8))*y(9);
rhs(4) = y(15)+y(23);
lhs(5) = y(15);
rhs(5) = T(12)*T(13);
lhs(6) = y(26);
rhs(6) = T(9);
lhs(7) = y(17);
rhs(7) = y(18)+y(3)*(1-params(2));
lhs(8) = y(27);
rhs(8) = (-(T(2)/(1-params(3))))/(1-y(26));
lhs(9) = log(y(20));
rhs(9) = params(7)*log(y(6))+x(1);
lhs(10) = y(24);
rhs(10) = 100*(y(15)-y(16)-y(18)-T(10));
lhs(11) = y(25);
rhs(11) = y(24)-y(9)*y(28);
lhs(12) = y(21);
rhs(12) = y(15)/y(19);
lhs(13) = y(28);
rhs(13) = params(8);
lhs(14) = y(22);
rhs(14) = (1-params(1))*y(15)/y(19);
end
