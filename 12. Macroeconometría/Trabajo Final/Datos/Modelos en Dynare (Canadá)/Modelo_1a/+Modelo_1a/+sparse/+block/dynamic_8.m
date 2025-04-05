function [y, T] = dynamic_8(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(20)=y(14)/y(18);
  y(24)=y(23)-y(9)*(y(26)+params(11)*(T(15)-1));
end
