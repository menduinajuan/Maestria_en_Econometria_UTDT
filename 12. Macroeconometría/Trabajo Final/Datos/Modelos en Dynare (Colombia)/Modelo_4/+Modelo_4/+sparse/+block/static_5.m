function [y, T, residual, g1] = static_5(y, x, params, sparse_rowval, sparse_colval, sparse_colptr, T)
residual=NaN(1, 1);
  residual(1)=(T(5))-(T(5)*params(9)*(1+y(8))/(1-params(11)*(y(10)-params(10))));
if nargout > 3
    g1_v = NaN(1, 1);
g1_v(1)=(-((-(T(5)*params(9)*(1+y(8))*(-params(11))))/((1-params(11)*(y(10)-params(10)))*(1-params(11)*(y(10)-params(10))))));
    if ~isoctave && matlab_ver_less_than('9.8')
        sparse_rowval = double(sparse_rowval);
        sparse_colval = double(sparse_colval);
    end
    g1 = sparse(sparse_rowval, sparse_colval, g1_v, 1, 1);
end
end
