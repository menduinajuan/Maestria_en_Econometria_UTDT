function [T_order, T] = dynamic_resid_tt(y, x, params, steady_state, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 13
    T = [T; NaN(13 - size(T, 1), 1)];
end
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
end
