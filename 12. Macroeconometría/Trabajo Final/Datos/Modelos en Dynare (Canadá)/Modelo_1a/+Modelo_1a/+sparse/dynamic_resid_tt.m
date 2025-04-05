function [T_order, T] = dynamic_resid_tt(y, x, params, steady_state, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 11
    T = [T; NaN(11 - size(T, 1), 1)];
end
T(1) = y(18)^params(4)/params(4);
T(2) = (y(15)-T(1))^(-params(3));
T(3) = y(28)-y(31)^params(4)/params(4);
T(4) = T(3)^(-params(3));
T(5) = y(25)*T(4);
T(6) = 1+params(1)*y(27)/y(16)-params(2)+params(5)*(y(29)-y(16));
T(7) = T(5)*T(6);
T(8) = params(5)/2*(y(16)-y(3))^2;
T(9) = y(3)^params(1);
T(10) = y(19)*T(9);
T(11) = y(18)^(1-params(1));
end
