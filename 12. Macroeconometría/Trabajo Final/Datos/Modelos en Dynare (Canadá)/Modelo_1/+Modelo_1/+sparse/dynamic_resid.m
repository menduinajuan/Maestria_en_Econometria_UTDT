function [residual, T_order, T] = dynamic_resid(y, x, params, steady_state, T_order, T)
if nargin < 6
    T_order = -1;
    T = NaN(13, 1);
end
[T_order, T] = Modelo_1.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
residual = NaN(14, 1);
    residual(1) = (y(19)^(params(4)-1)) - ((1-params(1))*y(15)/y(19));
    residual(2) = (T(2)) - (T(6)/(1+params(5)*(y(17)-y(3))));
    residual(3) = (T(2)) - (y(26)*T(8)*(1+params(8))+y(27)*((-params(6))*T(9)-1));
    residual(4) = (y(16)+y(18)+T(10)+(1+params(8))*y(9)) - (y(15)+y(23));
    residual(5) = (y(15)) - (T(12)*T(13));
    residual(6) = (y(26)) - (T(9));
    residual(7) = (y(17)) - (y(18)+y(3)*(1-params(2)));
    residual(8) = (y(27)) - ((-(T(2)/(1-params(3))))/(1-y(26)));
    residual(9) = (log(y(20))) - (params(7)*log(y(6))+x(1));
    residual(10) = (y(24)) - (100*(y(15)-y(16)-y(18)-T(10)));
    residual(11) = (y(25)) - (y(24)-y(9)*y(28));
    residual(12) = (y(21)) - (y(15)/y(19));
    residual(13) = (y(28)) - (params(8));
    residual(14) = (y(22)) - ((1-params(1))*y(15)/y(19));
end
