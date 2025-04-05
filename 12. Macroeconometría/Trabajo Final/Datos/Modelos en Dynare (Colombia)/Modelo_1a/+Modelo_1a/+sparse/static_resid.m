function [residual, T_order, T] = static_resid(y, x, params, T_order, T)
if nargin < 5
    T_order = -1;
    T = NaN(6, 1);
end
[T_order, T] = Modelo_1a.sparse.static_resid_tt(y, x, params, T_order, T);
residual = NaN(13, 1);
    residual(1) = (y(5)^(params(4)-1)) - ((1-params(1))*y(1)/y(5));
    residual(2) = (T(2)) - (T(2)*y(12)*T(3));
    residual(3) = (T(2)) - (T(2)*y(12)*(1+y(13)));
    residual(4) = (y(2)+y(4)+y(9)*(1+y(13)+params(11)*(exp(y(9)-params(10))-1))) - (y(1)+y(9));
    residual(5) = (y(1)) - (T(5)*T(6));
    residual(6) = (y(12)) - ((1+y(2)-T(1))^(-params(6)));
    residual(7) = (y(3)) - (y(4)+y(3)*(1-params(2)));
    residual(8) = (log(y(6))) - (log(y(6))*params(7)+x(1));
    residual(9) = (y(10)) - (100*(y(1)-y(2)-y(4)));
    residual(10) = (y(11)) - (y(10)-y(9)*(y(13)+params(11)*(exp(y(9)-params(10))-1)));
    residual(11) = (y(7)) - (y(1)/y(5));
    residual(12) = (y(13)) - (params(8));
    residual(13) = (y(8)) - ((1-params(1))*y(1)/y(5));
end
