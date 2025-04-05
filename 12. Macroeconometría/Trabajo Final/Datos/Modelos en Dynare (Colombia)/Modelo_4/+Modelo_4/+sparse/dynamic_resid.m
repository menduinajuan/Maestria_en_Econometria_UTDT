function [residual, T_order, T] = dynamic_resid(y, x, params, steady_state, T_order, T)
if nargin < 6
    T_order = -1;
    T = NaN(10, 1);
end
[T_order, T] = Modelo_4.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
residual = NaN(14, 1);
    residual(1) = (y(19)^(params(4)-1)) - ((1-params(1))*y(15)/y(19));
    residual(2) = (T(2)) - (T(6)/(1+params(5)*(y(17)-y(3))));
    residual(3) = (T(2)) - (T(4)*(1+y(22))/(1-params(11)*(y(24)-params(10))));
    residual(4) = (y(16)+y(18)+T(7)+y(27)*y(42)) - (y(15)+y(28));
    residual(5) = (y(15)) - (T(9)*T(10));
    residual(6) = (y(17)) - (y(18)+y(3)*(1-params(2)));
    residual(7) = (log(y(20))) - (params(6)*log(y(6))+x(1));
    residual(8) = (y(25)) - (100*(y(15)-y(16)-y(18)-T(7)));
    residual(9) = (y(26)) - (y(25)-y(10)*(y(22)+params(11)*(exp(y(10)-params(10))-1)));
    residual(10) = (y(21)) - (y(15)/y(19));
    residual(11) = (y(27)) - (y(25)*params(9)/(params(9)-1));
    residual(12) = (y(28)) - (y(27)/params(9));
    residual(13) = (y(22)) - (params(7));
    residual(14) = (y(23)) - ((1-params(1))*y(15)/y(19));
end
