function  fjac = fdjacob( f, x, jactype, f0, varargin)
% FDJACOB: computes numerical Jacobian matrix of a function f: R^k -> R^n
%
% INPUTS: 
% f         = Handle or name for function that generates a n x 1 vector of
%             individual components.
% x         = k x 1 argument vector.
% jactype   = (optional) type of numerical Jacobian =0 forward difference;
%             =1 centered Jacobian. (Default value =0.)
% f0        = (optional) function FUN evaluated at argument x (if you want 
%             to pass additional arguments but do not provide f0, you need 
%             to pass it an empty component f0 = []. Note that passing this
%             argument is only useful if computing the forward difference
%             derivative.
% varargin  = Additional parameters needed to evaluate 'f' other than x.
%         
% OUTPUT:   
% fjac      = n x k numerical Jacobian
%
% Based on Fackler and Miranda fdjac.m algorithm but with more options.

% Check type of Jacobian approximation (forward difference vs centered
if nargin<3 || isempty(jactype)
    jactype = 0;
end

% Check if used provides f(x)
if nargin<4 || isempty( f0 )
  f0 = feval(f,x,varargin{:});
end

% Check dimension of function 'f' and preallocate memory
n    = length(f0);
k    = length(x);
fjac = zeros(n,k);

if jactype == 0;    % Perform forward difference
    
    % Compute "rule-of-thumb" stepsize (h)
    h  = sqrt(eps)*max(abs(x),1);
    xh = x+h;
    h  = xh-x;
    for j=1:k
        xx = x;
        xx(j) = xh(j); f1=feval(f,xx,varargin{:});
        fjac(:,j) = (f1-f0)/h(j);
    end
    
else   % Perform centered difference jacobian
    
    % Compute "rule-of-thumb" stepsize (h)
    h   = eps^(1/3)*max(abs(x),1);
    xh1 = x+h;
    xh0 = x-h;
    hh  = xh1-xh0;
    for j=1:k
        xx = x;
        xx(j) = xh1(j); f1 = feval(f,xx,varargin{:});
        xx(j) = xh0(j); f0 = feval(f,xx,varargin{:});
        fjac(:,j) = (f1-f0)/hh(j);
    end
    
end