function [T_order, T] = dynamic_resid_tt(y, x, params, steady_state, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 10
    T = [T; NaN(10 - size(T, 1), 1)];
end
T(1) = y(14)-y(17)^params(4)/params(4);
T(2) = T(1)^(-params(3));
T(3) = y(26)-y(29)^params(4)/params(4);
T(4) = params(9)*T(3)^(-params(3));
T(5) = 1+params(1)*y(25)/y(15)-params(2)+params(5)*(y(27)-y(15));
T(6) = T(4)*T(5);
T(7) = params(5)/2*(y(15)-y(3))^2;
T(8) = y(3)^params(1);
T(9) = y(18)*T(8);
T(10) = y(17)^(1-params(1));
end
