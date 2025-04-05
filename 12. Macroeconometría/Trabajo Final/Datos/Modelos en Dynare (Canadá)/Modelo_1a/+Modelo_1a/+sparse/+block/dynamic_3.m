function [y, T, residual, g1] = dynamic_3(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(5, 1);
  T(1)=y(18)^params(4)/params(4);
  T(2)=(y(15)-T(1))^(-params(3));
  T(3)=y(28)-y(31)^params(4)/params(4);
  T(4)=T(3)^(-params(3));
  T(5)=y(25)*T(4);
  residual(1)=(T(2))-(T(5)*(1+y(26)));
  residual(2)=(T(2))-(T(5)*(1+params(1)*y(27)/y(16)-params(2)+params(5)*(y(29)-y(16)))/(1+params(5)*(y(16)-y(3))));
  T(6)=y(19)*y(3)^params(1);
  T(7)=y(18)^(1-params(1));
  residual(3)=(y(14))-(T(6)*T(7));
  residual(4)=(y(25))-((1+y(15)-T(1))^(-params(6)));
  residual(5)=(y(18)^(params(4)-1))-((1-params(1))*y(14)/y(18));
  T(8)=getPowerDeriv(y(15)-T(1),(-params(3)),1);
  T(9)=getPowerDeriv(1+y(15)-T(1),(-params(6)),1);
  T(10)=getPowerDeriv(T(3),(-params(3)),1);
  T(11)=(-(getPowerDeriv(y(18),params(4),1)/params(4)));
  T(12)=T(8)*T(11);
  T(13)=y(25)*T(10)*(-(getPowerDeriv(y(31),params(4),1)/params(4)));
if nargout > 3
    g1_v = NaN(22, 1);
g1_v(1)=(-((-(T(5)*(1+params(1)*y(27)/y(16)-params(2)+params(5)*(y(29)-y(16)))*(-params(5))))/((1+params(5)*(y(16)-y(3)))*(1+params(5)*(y(16)-y(3))))));
g1_v(2)=(-(T(7)*y(19)*getPowerDeriv(y(3),params(1),1)));
g1_v(3)=(-(T(4)*(1+y(26))));
g1_v(4)=(-(T(4)*(1+params(1)*y(27)/y(16)-params(2)+params(5)*(y(29)-y(16)))/(1+params(5)*(y(16)-y(3)))));
g1_v(5)=1;
g1_v(6)=(-(((1+params(5)*(y(16)-y(3)))*T(5)*(params(1)*(-y(27))/(y(16)*y(16))-params(5))-params(5)*T(5)*(1+params(1)*y(27)/y(16)-params(2)+params(5)*(y(29)-y(16))))/((1+params(5)*(y(16)-y(3)))*(1+params(5)*(y(16)-y(3))))));
g1_v(7)=1;
g1_v(8)=(-((1-params(1))*1/y(18)));
g1_v(9)=T(8);
g1_v(10)=T(8);
g1_v(11)=(-T(9));
g1_v(12)=T(12);
g1_v(13)=T(12);
g1_v(14)=(-(T(6)*getPowerDeriv(y(18),1-params(1),1)));
g1_v(15)=(-(T(9)*T(11)));
g1_v(16)=getPowerDeriv(y(18),params(4)-1,1)-(1-params(1))*(-y(14))/(y(18)*y(18));
g1_v(17)=(-(T(5)*params(5)/(1+params(5)*(y(16)-y(3)))));
g1_v(18)=(-(T(5)*params(1)*1/y(16)/(1+params(5)*(y(16)-y(3)))));
g1_v(19)=(-((1+y(26))*y(25)*T(10)));
g1_v(20)=(-((1+params(1)*y(27)/y(16)-params(2)+params(5)*(y(29)-y(16)))*y(25)*T(10)/(1+params(5)*(y(16)-y(3)))));
g1_v(21)=(-((1+y(26))*T(13)));
g1_v(22)=(-((1+params(1)*y(27)/y(16)-params(2)+params(5)*(y(29)-y(16)))*T(13)/(1+params(5)*(y(16)-y(3)))));
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 5, 15);
end
end
