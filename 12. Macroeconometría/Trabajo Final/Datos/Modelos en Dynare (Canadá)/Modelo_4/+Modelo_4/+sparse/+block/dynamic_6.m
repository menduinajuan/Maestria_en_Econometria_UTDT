function [y, T] = dynamic_6(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(21)=y(15)/y(19);
  y(26)=y(25)-y(10)*(y(22)+params(11)*(exp(y(10)-params(10))-1));
end
