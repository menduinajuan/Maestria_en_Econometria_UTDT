function [residual, T_order, T] = dynamic_resid(y, x, params, steady_state, T_order, T)
if nargin < 6
    T_order = -1;
    T = NaN(11, 1);
end
[T_order, T] = Modelo_1a.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
residual = NaN(13, 1);
    residual(1) = (y(18)^(params(4)-1)) - ((1-params(1))*y(14)/y(18));
    residual(2) = (T(2)) - (T(7)/(1+params(5)*(y(16)-y(3))));
    residual(3) = (T(2)) - (T(5)*(1+y(26)));
    residual(4) = (y(15)+y(17)+T(8)+y(9)*(1+y(26)+params(11)*(exp(y(9)-params(10))-1))) - (y(14)+y(22));
    residual(5) = (y(14)) - (T(10)*T(11));
    residual(6) = (y(25)) - ((1+y(15)-T(1))^(-params(6)));
    residual(7) = (y(16)) - (y(17)+y(3)*(1-params(2)));
    residual(8) = (log(y(19))) - (params(7)*log(y(6))+x(1));
    residual(9) = (y(23)) - (100*(y(14)-y(15)-y(17)-T(8)));
    residual(10) = (y(24)) - (y(23)-y(9)*(y(26)+params(11)*(exp(y(9)-params(10))-1)));
    residual(11) = (y(20)) - (y(14)/y(18));
    residual(12) = (y(26)) - (params(8));
    residual(13) = (y(21)) - ((1-params(1))*y(14)/y(18));
end
