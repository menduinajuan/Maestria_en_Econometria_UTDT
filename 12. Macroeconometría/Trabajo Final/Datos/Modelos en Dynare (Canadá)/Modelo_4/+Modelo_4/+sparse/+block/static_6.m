function [y, T] = static_6(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(7)=y(1)/y(5);
  y(12)=y(11)-y(10)*(y(8)+params(11)*(exp(y(10)-params(10))-1));
end
