function [T_order, T] = static_resid_tt(y, x, params, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 6
    T = [T; NaN(6 - size(T, 1), 1)];
end
T(1) = y(5)^params(4)/params(4);
T(2) = (y(2)-T(1))^(-params(3));
T(3) = 1+params(1)*y(1)/y(3)-params(2);
T(4) = y(3)^params(1);
T(5) = y(6)*T(4);
T(6) = y(5)^(1-params(1));
end
