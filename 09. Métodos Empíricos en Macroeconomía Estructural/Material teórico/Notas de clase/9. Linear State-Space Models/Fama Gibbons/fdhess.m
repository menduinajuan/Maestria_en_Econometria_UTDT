function H = fdhess( f, x, hesstype, fx, varargin )
% FDHESS Computes finite difference Hessian
% USAGE
%   H = fdhess(f , x, hesstype, fx, P1, P2,...);
% INPUTS
%   f         : name of function of form fval = f(x)
%   x         : evaluation point
%   hesstype  : type of numerical Hessian (=0 forward difference; =1
%               centered numerical Hessian. (default=0)
%   fx        : initial evaluation at x   (if empty or not present: no fx)
%   type      : 
%   P1,P2,... : additional arguments for f (optional)
% OUTPUT
%   H         : finite difference Hessian
%
% USER OPTIONS (SET WITH OPSET)
%   tol       : a factor used in setting the step size
%               increase if f is inaccurately computed
%   diagonly  : computes just the diagonal elements of the Hessian 

% Copyright (c) 1997-2002, Paul L. Fackler & Mario J. Miranda
% paul_fackler@ncsu.edu, miranda.4@osu.edu

% Modified by Constantino Hevia as follows:
%
% 1) Type of numerical hessian: hesstype=1 means forward difference only
% (faster but less accurate); hesstype=2 is for centered hessian (more accurate
% but slower)

% 2) Allow the user to input initial value f(x) to speed up computation.
% This is similar to what Fackler and Miranda do in fdjac1.m.
%
% Note: user can pass empty values for fx and/or hesstype. However, user
% must pass empty values for these variables if he/she wants to use default
% hessian and pass additional parameters P1, P2, ...

% Check type of hessian approximation:
if nargin<3 || isempty(hesstype)
    hesstype = 0;
end

% Check if user provides f(x)
if nargin<4 || isempty(fx)
    fx = feval(f,x,varargin{:});
end

k = size(x,1);

if hesstype == 0;   % If forward difference Hessian (faster but less accurate)
    
    % Compute stepsize (h)
    h  = sqrt(eps)*max(abs(x),1);
    xh = x+h;
    h  = xh-x;
    ee = sparse(1:k,1:k,h,k,k);
    
    % Compute forward step 
    g = zeros(k,1);
    for i=1:k
        g(i) = feval(f,x+ee(:,i),varargin{:});
    end
    
    H=h*h';
    % Compute "double" forward step 
    for i=1:k
        for j=i:k
          H(i,j) = (feval(f,x+ee(:,i)+ee(:,j),varargin{:})-g(i)-g(j)+fx)/H(i,j);
          H(j,i) = H(i,j);
        end
    end
    
else                % If centered Hessian (more accurate but slower)
    
    % Compute the stepsize (h)
    h  = eps^(1/3)*max(abs(x),1);
    xh = x+h;
    h = xh-x;    
    ee = sparse(1:k,1:k,h,k,k);
    
    % Compute forward and backward steps
    gplus = zeros(k,1);
    gminus = zeros(k,1);
    for i=1:k
        gplus(i) = feval(f,x+ee(:,i),varargin{:});
        gminus(i) = feval(f,x-ee(:,i),varargin{:});
    end
    
    H=h*h';
    % Compute double steps
    for i=1:k
      for j=1:k
        if i==j
          H(i,j) = (gplus(i)+gminus(j)-2*fx)/ H(i,j);
        else 
          fxx=feval(f,x+ee(:,i)-ee(:,j),varargin{:});
          H(i,j) = (gplus(i)+gminus(j)-fx-fxx)/ H(i,j);
        end
      end
    end
    H=(H+H')/2;
    
end
