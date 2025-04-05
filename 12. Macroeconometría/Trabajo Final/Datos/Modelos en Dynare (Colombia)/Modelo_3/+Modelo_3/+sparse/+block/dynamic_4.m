function [y, T] = dynamic_4(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(20)=(1-params(1))*y(13)/y(17);
  y(22)=100*(y(13)-y(14)-y(16)-T(1));
  y(19)=y(13)/y(17);
  y(23)=y(22)-y(9)*(y(24)+params(11)*(exp(y(9)-params(10))-1));
end
