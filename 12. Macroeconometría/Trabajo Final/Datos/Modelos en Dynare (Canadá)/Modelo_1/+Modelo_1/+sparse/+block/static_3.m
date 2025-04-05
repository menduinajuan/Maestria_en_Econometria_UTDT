function [y, T, residual, g1] = static_3(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(6, 1);
  T(2)=y(5)^params(4)/params(4);
  T(3)=(y(2)-T(2))^(-params(3));
  T(4)=(1+y(2)-T(2))^(-params(6));
  T(5)=y(13)*((-params(6))*T(4)-1);
  residual(1)=(T(3))-(T(5)+y(12)*(T(3)-T(5))*(1+params(8)));
  residual(2)=(T(3))-(T(3)*y(12)*(1+params(1)*y(1)/y(3)-params(2)));
  T(6)=y(6)*y(3)^params(1);
  T(7)=y(5)^(1-params(1));
  residual(3)=(y(1))-(T(6)*T(7));
  residual(4)=(y(12))-(T(4));
  residual(5)=(y(5)^(params(4)-1))-((1-params(1))*y(1)/y(5));
  residual(6)=(y(13))-((-(T(3)/(1-params(3))))/(1-y(12)));
  T(8)=getPowerDeriv(y(2)-T(2),(-params(3)),1);
  T(9)=getPowerDeriv(1+y(2)-T(2),(-params(6)),1);
  T(10)=y(13)*(-params(6))*T(9);
  T(11)=(-(getPowerDeriv(y(5),params(4),1)/params(4)));
if nargout > 3
    g1_v = NaN(21, 1);
g1_v(1)=(-((T(3)-T(5))*(1+params(8))));
g1_v(2)=(-(T(3)*(1+params(1)*y(1)/y(3)-params(2))));
g1_v(3)=1;
g1_v(4)=(-((-(T(3)/(1-params(3))))/((1-y(12))*(1-y(12)))));
g1_v(5)=(-(T(3)*y(12)*params(1)*1/y(3)));
g1_v(6)=1;
g1_v(7)=(-((1-params(1))*1/y(5)));
g1_v(8)=(-(T(3)*y(12)*params(1)*(-y(1))/(y(3)*y(3))));
g1_v(9)=(-(T(7)*y(6)*getPowerDeriv(y(3),params(1),1)));
g1_v(10)=T(8)-(T(10)+(1+params(8))*y(12)*(T(8)-T(10)));
g1_v(11)=T(8)-(1+params(1)*y(1)/y(3)-params(2))*y(12)*T(8);
g1_v(12)=(-T(9));
g1_v(13)=(-((-(T(8)/(1-params(3))))/(1-y(12))));
g1_v(14)=T(8)*T(11)-(y(13)*(-params(6))*T(9)*T(11)+(1+params(8))*y(12)*(T(8)*T(11)-y(13)*(-params(6))*T(9)*T(11)));
g1_v(15)=T(8)*T(11)-(1+params(1)*y(1)/y(3)-params(2))*y(12)*T(8)*T(11);
g1_v(16)=(-(T(6)*getPowerDeriv(y(5),1-params(1),1)));
g1_v(17)=(-(T(9)*T(11)));
g1_v(18)=getPowerDeriv(y(5),params(4)-1,1)-(1-params(1))*(-y(1))/(y(5)*y(5));
g1_v(19)=(-((-(T(8)*T(11)/(1-params(3))))/(1-y(12))));
g1_v(20)=(-((-params(6))*T(4)-1+(1+params(8))*y(12)*(-((-params(6))*T(4)-1))));
g1_v(21)=1;
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 6, 6);
end
end
