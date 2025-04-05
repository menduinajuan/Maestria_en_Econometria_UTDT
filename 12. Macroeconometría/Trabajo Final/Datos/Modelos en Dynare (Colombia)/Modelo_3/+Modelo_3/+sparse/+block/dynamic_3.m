function [y, T, residual, g1] = dynamic_3(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(6, 1);
  residual(1)=(y(15))-(y(16)+y(3)*(1-params(2)));
  T(1)=params(5)/2*(y(15)-y(3))^2;
  residual(2)=(y(14)+y(16)+T(1)+(1+y(24))*y(9)+params(11)/2*(y(21)-params(10))^2)-(y(13)+y(21));
  T(2)=y(14)-y(17)^params(4)/params(4);
  T(3)=T(2)^(-params(3));
  T(4)=y(26)-y(29)^params(4)/params(4);
  T(5)=params(9)*T(4)^(-params(3));
  residual(3)=(T(3))-(T(5)*(1+params(1)*y(25)/y(15)-params(2)+params(5)*(y(27)-y(15)))/(1+params(5)*(y(15)-y(3))));
  residual(4)=(T(3))-(T(5)*(1+y(24))/(1-params(11)*(y(21)-params(10))));
  T(6)=y(18)*y(3)^params(1);
  T(7)=y(17)^(1-params(1));
  residual(5)=(y(13))-(T(6)*T(7));
  residual(6)=(y(17)^(params(4)-1))-((1-params(1))*y(13)/y(17));
  T(8)=getPowerDeriv(T(2),(-params(3)),1);
  T(9)=getPowerDeriv(T(4),(-params(3)),1);
  T(10)=T(8)*(-(getPowerDeriv(y(17),params(4),1)/params(4)));
  T(11)=params(9)*T(9)*(-(getPowerDeriv(y(29),params(4),1)/params(4)));
if nargout > 3
    g1_v = NaN(28, 1);
g1_v(1)=1+y(24);
g1_v(2)=(-(1-params(2)));
g1_v(3)=params(5)/2*(-(2*(y(15)-y(3))));
g1_v(4)=(-((-(T(5)*(1+params(1)*y(25)/y(15)-params(2)+params(5)*(y(27)-y(15)))*(-params(5))))/((1+params(5)*(y(15)-y(3)))*(1+params(5)*(y(15)-y(3))))));
g1_v(5)=(-(T(7)*y(18)*getPowerDeriv(y(3),params(1),1)));
g1_v(6)=(-1);
g1_v(7)=1;
g1_v(8)=params(11)/2*2*(y(21)-params(10))-1;
g1_v(9)=(-((-(T(5)*(1+y(24))*(-params(11))))/((1-params(11)*(y(21)-params(10)))*(1-params(11)*(y(21)-params(10))))));
g1_v(10)=1;
g1_v(11)=params(5)/2*2*(y(15)-y(3));
g1_v(12)=(-(((1+params(5)*(y(15)-y(3)))*T(5)*(params(1)*(-y(25))/(y(15)*y(15))-params(5))-params(5)*T(5)*(1+params(1)*y(25)/y(15)-params(2)+params(5)*(y(27)-y(15))))/((1+params(5)*(y(15)-y(3)))*(1+params(5)*(y(15)-y(3))))));
g1_v(13)=1;
g1_v(14)=T(8);
g1_v(15)=T(8);
g1_v(16)=(-1);
g1_v(17)=1;
g1_v(18)=(-((1-params(1))*1/y(17)));
g1_v(19)=T(10);
g1_v(20)=T(10);
g1_v(21)=(-(T(6)*getPowerDeriv(y(17),1-params(1),1)));
g1_v(22)=getPowerDeriv(y(17),params(4)-1,1)-(1-params(1))*(-y(13))/(y(17)*y(17));
g1_v(23)=(-(T(5)*params(5)/(1+params(5)*(y(15)-y(3)))));
g1_v(24)=(-((1+params(1)*y(25)/y(15)-params(2)+params(5)*(y(27)-y(15)))*params(9)*T(9)/(1+params(5)*(y(15)-y(3)))));
g1_v(25)=(-((1+y(24))*params(9)*T(9)/(1-params(11)*(y(21)-params(10)))));
g1_v(26)=(-(T(5)*params(1)*1/y(15)/(1+params(5)*(y(15)-y(3)))));
g1_v(27)=(-((1+params(1)*y(25)/y(15)-params(2)+params(5)*(y(27)-y(15)))*T(11)/(1+params(5)*(y(15)-y(3)))));
g1_v(28)=(-((1+y(24))*T(11)/(1-params(11)*(y(21)-params(10)))));
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 6, 18);
end
end
