function [y, T] = static_8(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(7)=y(1)/y(5);
  y(11)=y(10)-y(9)*(y(13)+params(11)*(T(10)-1));
end
