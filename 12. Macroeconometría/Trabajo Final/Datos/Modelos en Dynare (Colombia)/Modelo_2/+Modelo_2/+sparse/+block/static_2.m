function [y, T, residual, g1] = static_2(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(8, 1);
  T(2)=y(2)-y(5)^params(4)/params(4);
  T(3)=T(2)^(-params(3));
  residual(1)=(T(3))-(T(3)*params(9)*(1+params(1)*y(1)/y(3)-params(2)));
  residual(2)=(T(3))-(T(3)*params(9)*(1+y(13)));
  residual(3)=(y(2)+y(4)+(1+y(13))*y(9))-(y(1)+y(9));
  T(4)=y(6)*y(3)^params(1);
  T(5)=y(5)^(1-params(1));
  residual(4)=(y(1))-(T(4)*T(5));
  T(6)=exp(y(9)-params(10));
  residual(5)=(y(12))-(params(11)*(T(6)-1));
  residual(6)=(y(3))-(y(4)+y(3)*(1-params(2)));
  residual(7)=(y(5)^(params(4)-1))-((1-params(1))*y(1)/y(5));
  residual(8)=(y(13))-(y(12)+params(7));
  T(7)=getPowerDeriv(T(2),(-params(3)),1);
  T(8)=T(7)*(-(getPowerDeriv(y(5),params(4),1)/params(4)));
if nargout > 3
    g1_v = NaN(23, 1);
g1_v(1)=T(7)-(1+params(1)*y(1)/y(3)-params(2))*params(9)*T(7);
g1_v(2)=T(7)-(1+y(13))*params(9)*T(7);
g1_v(3)=1;
g1_v(4)=(-(T(3)*params(9)));
g1_v(5)=y(9);
g1_v(6)=1;
g1_v(7)=1;
g1_v(8)=(-1);
g1_v(9)=T(8)-(1+params(1)*y(1)/y(3)-params(2))*params(9)*T(8);
g1_v(10)=T(8)-(1+y(13))*params(9)*T(8);
g1_v(11)=(-(T(4)*getPowerDeriv(y(5),1-params(1),1)));
g1_v(12)=getPowerDeriv(y(5),params(4)-1,1)-(1-params(1))*(-y(1))/(y(5)*y(5));
g1_v(13)=y(13);
g1_v(14)=(-(params(11)*T(6)));
g1_v(15)=(-(T(3)*params(9)*params(1)*(-y(1))/(y(3)*y(3))));
g1_v(16)=(-(T(5)*y(6)*getPowerDeriv(y(3),params(1),1)));
g1_v(17)=1-(1-params(2));
g1_v(18)=(-(T(3)*params(9)*params(1)*1/y(3)));
g1_v(19)=(-1);
g1_v(20)=1;
g1_v(21)=(-((1-params(1))*1/y(5)));
g1_v(22)=1;
g1_v(23)=(-1);
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 8, 8);
end
end
