function [y, T] = dynamic_6(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  T(14)=params(5)/2*(y(16)-y(3))^2;
  y(23)=100*(y(14)-y(15)-y(17)-T(14));
end
