function [T_order, T] = static_g1_tt(y, x, params, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = Modelo_4.sparse.static_resid_tt(y, x, params, T_order, T);
T_order = 1;
if size(T, 1) < 8
    T = [T; NaN(8 - size(T, 1), 1)];
end
T(7) = getPowerDeriv(T(1),(-params(3)),1);
T(8) = T(7)*(-(getPowerDeriv(y(5),params(4),1)/params(4)));
end
