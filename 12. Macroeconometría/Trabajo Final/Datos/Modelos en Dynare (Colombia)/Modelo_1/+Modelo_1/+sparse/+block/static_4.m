function [y, T] = static_4(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(8)=(1-params(1))*y(1)/y(5);
end
