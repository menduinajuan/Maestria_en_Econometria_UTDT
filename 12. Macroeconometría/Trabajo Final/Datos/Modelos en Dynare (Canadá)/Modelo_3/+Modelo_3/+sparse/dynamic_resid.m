function [residual, T_order, T] = dynamic_resid(y, x, params, steady_state, T_order, T)
if nargin < 6
    T_order = -1;
    T = NaN(10, 1);
end
[T_order, T] = Modelo_3.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
residual = NaN(12, 1);
    residual(1) = (y(17)^(params(4)-1)) - ((1-params(1))*y(13)/y(17));
    residual(2) = (T(2)) - (T(6)/(1+params(5)*(y(15)-y(3))));
    residual(3) = (T(2)) - (T(4)*(1+y(24))/(1-params(11)*(y(21)-params(10))));
    residual(4) = (y(14)+y(16)+T(7)+(1+y(24))*y(9)+params(11)/2*(y(21)-params(10))^2) - (y(13)+y(21));
    residual(5) = (y(13)) - (T(9)*T(10));
    residual(6) = (y(15)) - (y(16)+y(3)*(1-params(2)));
    residual(7) = (log(y(18))) - (params(6)*log(y(6))+x(1));
    residual(8) = (y(22)) - (100*(y(13)-y(14)-y(16)-T(7)));
    residual(9) = (y(23)) - (y(22)-y(9)*(y(24)+params(11)*(exp(y(9)-params(10))-1)));
    residual(10) = (y(19)) - (y(13)/y(17));
    residual(11) = (y(24)) - (params(7));
    residual(12) = (y(20)) - ((1-params(1))*y(13)/y(17));
end
