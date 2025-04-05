function [T_order, T] = static_g1_tt(y, x, params, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = Modelo_1.sparse.static_resid_tt(y, x, params, T_order, T);
T_order = 1;
if size(T, 1) < 13
    T = [T; NaN(13 - size(T, 1), 1)];
end
T(9) = getPowerDeriv(y(2)-T(1),(-params(3)),1);
T(10) = getPowerDeriv(1+y(2)-T(1),(-params(6)),1);
T(11) = y(13)*(-params(6))*T(10);
T(12) = (-(getPowerDeriv(y(5),params(4),1)/params(4)));
T(13) = T(9)*T(12);
end
