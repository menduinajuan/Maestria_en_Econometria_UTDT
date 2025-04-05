function [y, T, residual, g1] = dynamic_7(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  T(15)=exp(y(9)-params(10));
  T(16)=1+y(26)+params(11)*(T(15)-1);
  residual(1)=(y(15)+y(17)+T(14)+y(9)*T(16))-(y(14)+y(22));
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=(-1);
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
