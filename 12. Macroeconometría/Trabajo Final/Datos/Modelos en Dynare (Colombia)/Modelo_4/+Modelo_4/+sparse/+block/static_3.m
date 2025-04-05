function [y, T, residual, g1] = static_3(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(8, 1);
  residual(1)=(y(14))-(y(13)/params(9));
  residual(2)=(y(2)+y(4)+y(13)*y(14))-(y(1)+y(14));
  T(2)=y(6)*y(3)^params(1);
  T(3)=y(5)^(1-params(1));
  residual(3)=(y(1))-(T(2)*T(3));
  residual(4)=(y(3))-(y(4)+y(3)*(1-params(2)));
  residual(5)=(y(5)^(params(4)-1))-((1-params(1))*y(1)/y(5));
  residual(6)=(y(11))-(100*(y(1)-y(2)-y(4)));
  residual(7)=(y(13))-(y(11)*params(9)/(params(9)-1));
  T(4)=y(2)-y(5)^params(4)/params(4);
  T(5)=T(4)^(-params(3));
  residual(8)=(T(5))-(T(5)*params(9)*(1+params(1)*y(1)/y(3)-params(2)));
  T(6)=getPowerDeriv(T(4),(-params(3)),1);
  T(7)=T(6)*(-(getPowerDeriv(y(5),params(4),1)/params(4)));
if nargout > 3
    g1_v = NaN(24, 1);
g1_v(1)=(-(1/params(9)));
g1_v(2)=y(14);
g1_v(3)=1;
g1_v(4)=1;
g1_v(5)=y(13)-1;
g1_v(6)=(-(T(2)*getPowerDeriv(y(5),1-params(1),1)));
g1_v(7)=getPowerDeriv(y(5),params(4)-1,1)-(1-params(1))*(-y(1))/(y(5)*y(5));
g1_v(8)=T(7)-(1+params(1)*y(1)/y(3)-params(2))*params(9)*T(7);
g1_v(9)=(-(T(3)*y(6)*getPowerDeriv(y(3),params(1),1)));
g1_v(10)=1-(1-params(2));
g1_v(11)=(-(T(5)*params(9)*params(1)*(-y(1))/(y(3)*y(3))));
g1_v(12)=(-1);
g1_v(13)=1;
g1_v(14)=(-((1-params(1))*1/y(5)));
g1_v(15)=(-100);
g1_v(16)=(-(T(5)*params(9)*params(1)*1/y(3)));
g1_v(17)=1;
g1_v(18)=(-1);
g1_v(19)=100;
g1_v(20)=1;
g1_v(21)=(-(params(9)/(params(9)-1)));
g1_v(22)=1;
g1_v(23)=100;
g1_v(24)=T(6)-(1+params(1)*y(1)/y(3)-params(2))*params(9)*T(6);
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 8, 8);
end
end
