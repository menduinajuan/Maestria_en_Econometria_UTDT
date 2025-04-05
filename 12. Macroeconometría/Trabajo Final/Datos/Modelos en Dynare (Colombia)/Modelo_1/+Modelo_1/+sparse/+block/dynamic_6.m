function [y, T] = dynamic_6(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  T(18)=params(5)/2*(y(17)-y(3))^2;
  y(24)=100*(y(15)-y(16)-y(18)-T(18));
end
