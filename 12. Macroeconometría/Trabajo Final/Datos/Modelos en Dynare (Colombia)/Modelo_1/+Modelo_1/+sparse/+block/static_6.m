function [y, T] = static_6(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(10)=100*(y(1)-y(2)-y(4));
end
