function [y, T] = dynamic_3(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(21)=(1-params(1))*y(14)/y(18);
  y(23)=100*(y(14)-y(15)-y(17)-T(2));
  y(20)=y(14)/y(18);
  y(24)=y(23)-y(26)*y(9);
end
