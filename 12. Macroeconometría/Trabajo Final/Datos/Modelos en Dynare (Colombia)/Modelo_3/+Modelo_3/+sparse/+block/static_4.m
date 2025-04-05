function [y, T] = static_4(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(8)=(1-params(1))*y(1)/y(5);
  y(10)=100*(y(1)-y(2)-y(4));
  y(7)=y(1)/y(5);
  y(11)=y(10)-y(9)*(y(12)+params(11)*(exp(y(9)-params(10))-1));
end
