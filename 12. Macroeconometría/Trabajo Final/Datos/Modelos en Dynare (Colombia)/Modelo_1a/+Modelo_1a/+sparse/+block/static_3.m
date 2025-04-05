function [y, T, residual, g1] = static_3(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(5, 1);
  T(2)=y(5)^params(4)/params(4);
  T(3)=(y(2)-T(2))^(-params(3));
  residual(1)=(T(3))-(T(3)*y(12)*(1+y(13)));
  residual(2)=(T(3))-(T(3)*y(12)*(1+params(1)*y(1)/y(3)-params(2)));
  T(4)=y(6)*y(3)^params(1);
  T(5)=y(5)^(1-params(1));
  residual(3)=(y(1))-(T(4)*T(5));
  residual(4)=(y(12))-((1+y(2)-T(2))^(-params(6)));
  residual(5)=(y(5)^(params(4)-1))-((1-params(1))*y(1)/y(5));
  T(6)=getPowerDeriv(y(2)-T(2),(-params(3)),1);
  T(7)=getPowerDeriv(1+y(2)-T(2),(-params(6)),1);
  T(8)=(-(getPowerDeriv(y(5),params(4),1)/params(4)));
  T(9)=T(6)*T(8);
if nargout > 3
    g1_v = NaN(16, 1);
g1_v(1)=(-(T(3)*(1+y(13))));
g1_v(2)=(-(T(3)*(1+params(1)*y(1)/y(3)-params(2))));
g1_v(3)=1;
g1_v(4)=T(6)-(1+y(13))*y(12)*T(6);
g1_v(5)=T(6)-(1+params(1)*y(1)/y(3)-params(2))*y(12)*T(6);
g1_v(6)=(-T(7));
g1_v(7)=(-(T(3)*y(12)*params(1)*(-y(1))/(y(3)*y(3))));
g1_v(8)=(-(T(5)*y(6)*getPowerDeriv(y(3),params(1),1)));
g1_v(9)=T(9)-(1+y(13))*y(12)*T(9);
g1_v(10)=T(9)-(1+params(1)*y(1)/y(3)-params(2))*y(12)*T(9);
g1_v(11)=(-(T(4)*getPowerDeriv(y(5),1-params(1),1)));
g1_v(12)=(-(T(7)*T(8)));
g1_v(13)=getPowerDeriv(y(5),params(4)-1,1)-(1-params(1))*(-y(1))/(y(5)*y(5));
g1_v(14)=(-(T(3)*y(12)*params(1)*1/y(3)));
g1_v(15)=1;
g1_v(16)=(-((1-params(1))*1/y(5)));
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 5, 5);
end
end
