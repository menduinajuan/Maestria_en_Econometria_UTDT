function [g1, T_order, T] = static_g1(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T_order, T)
if nargin < 8
    T_order = -1;
    T = NaN(8, 1);
end
[T_order, T] = Modelo_2.sparse.static_g1_tt(y, x, params, T_order, T);
g1_v = NaN(39, 1);
g1_v(1)=(-((1-params(1))*1/y(5)));
g1_v(2)=(-(T(2)*params(9)*params(1)*1/y(3)));
g1_v(3)=(-1);
g1_v(4)=1;
g1_v(5)=(-100);
g1_v(6)=(-(1/y(5)));
g1_v(7)=(-((1-params(1))*1/y(5)));
g1_v(8)=T(7)-T(3)*params(9)*T(7);
g1_v(9)=T(7)-(1+y(13))*params(9)*T(7);
g1_v(10)=1;
g1_v(11)=100;
g1_v(12)=(-(T(2)*params(9)*params(1)*(-y(1))/(y(3)*y(3))));
g1_v(13)=(-(T(6)*y(6)*getPowerDeriv(y(3),params(1),1)));
g1_v(14)=1-(1-params(2));
g1_v(15)=1;
g1_v(16)=(-1);
g1_v(17)=100;
g1_v(18)=getPowerDeriv(y(5),params(4)-1,1)-(1-params(1))*(-y(1))/(y(5)*y(5));
g1_v(19)=T(8)-T(3)*params(9)*T(8);
g1_v(20)=T(8)-(1+y(13))*params(9)*T(8);
g1_v(21)=(-(T(5)*getPowerDeriv(y(5),1-params(1),1)));
g1_v(22)=(-((-y(1))/(y(5)*y(5))));
g1_v(23)=(-((1-params(1))*(-y(1))/(y(5)*y(5))));
g1_v(24)=(-(T(4)*T(6)));
g1_v(25)=1/y(6)-params(6)*1/y(6);
g1_v(26)=1;
g1_v(27)=1;
g1_v(28)=y(13);
g1_v(29)=(-(params(11)*exp(y(9)-params(10))));
g1_v(30)=y(13);
g1_v(31)=1;
g1_v(32)=(-1);
g1_v(33)=1;
g1_v(34)=1;
g1_v(35)=(-1);
g1_v(36)=(-(T(2)*params(9)));
g1_v(37)=y(9);
g1_v(38)=y(9);
g1_v(39)=1;
if ~isoctave && matlab_ver_less_than('9.8')
    sparse_rowval = double(sparse_rowval);
    sparse_colval = double(sparse_colval);
end
g1 = sparse(sparse_rowval, sparse_colval, g1_v, 13, 13);
end
