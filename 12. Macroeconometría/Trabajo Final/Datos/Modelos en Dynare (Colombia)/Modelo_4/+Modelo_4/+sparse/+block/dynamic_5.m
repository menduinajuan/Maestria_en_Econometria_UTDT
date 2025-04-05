function [y, T, residual, g1] = dynamic_5(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=(T(5))-(T(7)*(1+y(22))/(1-params(11)*(y(24)-params(10))));
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=(-((-(T(7)*(1+y(22))*(-params(11))))/((1-params(11)*(y(24)-params(10)))*(1-params(11)*(y(24)-params(10))))));
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
