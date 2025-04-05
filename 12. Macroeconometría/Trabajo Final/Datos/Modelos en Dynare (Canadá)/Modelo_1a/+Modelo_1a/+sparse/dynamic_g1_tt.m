function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = Modelo_1a.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 17
    T = [T; NaN(17 - size(T, 1), 1)];
end
T(12) = getPowerDeriv(y(15)-T(1),(-params(3)),1);
T(13) = getPowerDeriv(1+y(15)-T(1),(-params(6)),1);
T(14) = getPowerDeriv(T(3),(-params(3)),1);
T(15) = (-(getPowerDeriv(y(18),params(4),1)/params(4)));
T(16) = T(12)*T(15);
T(17) = y(25)*T(14)*(-(getPowerDeriv(y(31),params(4),1)/params(4)));
end
