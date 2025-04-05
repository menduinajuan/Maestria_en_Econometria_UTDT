function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = Modelo_2.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 14
    T = [T; NaN(14 - size(T, 1), 1)];
end
T(11) = getPowerDeriv(T(1),(-params(3)),1);
T(12) = getPowerDeriv(T(3),(-params(3)),1);
T(13) = T(11)*(-(getPowerDeriv(y(18),params(4),1)/params(4)));
T(14) = params(9)*T(12)*(-(getPowerDeriv(y(31),params(4),1)/params(4)));
end
