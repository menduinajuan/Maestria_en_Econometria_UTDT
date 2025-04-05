function [x,f,g,code,status]=uncmin(x0,func,varargin)
%UNCMIN  Unconstrained minimization.
%        [x,f,g,code,status]=uncmin(x0,func,varargin) solves:
%                          min  f(x,varargin)              (*)
%                           x
%        where x0 is the initial guess for the optimal vector x and
%        where  func is a string giving the name of the .m file con-
%        taining code for the function f in (*).
%
%        In addition to returning the optimal x vector, f(x,varargin), and 
%        g(x)=df(x,varargin)/dx, UNCMIN returns "code" and "status", where:
%
%        code      =  1   if status(1)=1 or status(j)=1, j=2, 3, and 4
%        code      =  2   if a lower point could not be found
%        code      =  3   if the iteration limit is reached
%        code      =  4   if too many large steps are taken
%
%        status(1) =  1   if norm(g)               < epsa (0 otherwise)
%        status(2) =  1   if norm(g)/(1+f(x))      < gtol (0 otherwise)
%        status(3) =  1   if norm(dx)/(1+norm(x))  < xtol (0 otherwise)
%        status(4) =  1   if df/(1+f(x))           < ftol (0 otherwise)
%        (Note: the user can specify tolerances and other parameters
%         by editing this file.)

%        References:
% 
%        [1] Gill, Philip E., Murray, Walter, and Wright, Margaret H., 
%            PRACTICAL OPTIMIZATION, (New York: Academic Press), 1981.
%        [2] Kahaner, David, Moler, Cleve, and Nash, Stephen, NUMERICAL 
%            METHODS AND SOFTWARE, (Englewood Cliffs, N.J.: Prentice
%            Hall), 
%              

%        Ellen McGrattan,  3-6-89
%        Revised  6-790-


%-----------------------------------------------------------------------
%                      USER-DEFINED PARAMETERS
%-----------------------------------------------------------------------

x0=x0(:);                              % we assume that x0 is column 
n=length(x0);                          % vector of length n -- make
                                       % the <func>.m argument  n x 1

%--------------------------default values-------------------------------
epsa=1e-10;                            % tolerance for norm of gradient
epsm=eps;                              % machine epsilon (=sqrt(2)^2/2-1)
tol=1e-8;
xtol=sqrt(tol);                        % tolerance for change in x
ftol=tol;                              % tolerance for change in f
gtol=tol^(1/3);                        % tolerance for relative gradient
steptl=1e-3*sqrt(epsm);                % tolerance for step length
xsize=max(abs(x0),ones(n,1));          % typical x size
fsize=1.0;                             % typical function size
maxits=800;                            % maximum iterations
iagflg=0;                              % iagflg=1 if analytic gradient 
                                       %   provided (0 otherwise)
iahflg=0;                              % iahflg=1 if analytic hessian
                                       %   provided (0 otherwise)
                                       %   NOTE: analytic hessian not
                                       %   yet coded; set iahflg=0
prt=1;                                 % prt=1 if printing to be done at
                                       %   at intermediate steps

%--------------------------user's values--------------------------------

gtol=1e-5;      % This was set before at 1e-7.

%-----------------------------------------------------------------------




%-----------------------------------------------------------------------
%                         INITIALIZATIONS
%-----------------------------------------------------------------------

if min(xsize)<0; xsize=abs(xsize); end;
if fsize<0; fsize=abs(fsize); end;
p=zeros(n,1);
iter=0;
iretcd=-1;
sx=ones(n,1)./xsize;
stpsiz=sqrt(sum((x0.^2).*(sx.^2)));
stepmx=max(1e+3*stpsiz,1e+3);
stepmx=10;
ndigit=fix(-log10(epsm));
rnf=max(10^(-ndigit),epsm);
fddev=max(abs(x0),xsize);
cddev=rnf^(.33)*fddev;
fddev=sqrt(rnf)*fddev;

%fddev=.00001*fddev;
L=diag(sx);

if iagflg==1;                            % initialize gradient
    [f0,g0] = feval(func,x0,varargin{:});
else
    f0 = feval(func,x0,varargin{:});
    xh = x0 + fddev; h = xh-x0;
    for i=1:n
        xx = x0; xx(i)=xh(i);
        g0(i,1) = ( feval(func,xx,varargin{:}) - f0 )/h(i);
    end
end

%-----------------------------------------------------------------------
%                    INITIAL CONVERGENCE CHECK
%-----------------------------------------------------------------------

[code,status,icscmx]=umstop(x0,x0,f0,f0,g0,xtol,ftol,gtol,epsa,xsize, ...
                            fsize,iter,maxits,iretcd,0,0);
if code;
  x=x0;
  f=f0;
  g=g0;
  return;
end;      

%-----------------------------------------------------------------------
%                           MAIN LOOP
%-----------------------------------------------------------------------

while ~code;
  iter=iter+1;

  %
  % solve for search direction, p=- (LL')\g 
  %

  invl=inv(L);
  p=-invl'*invl*g0;

  [x,f,p,mxtake,iretcd]=umlnmin(x0,f0,g0,p,func,stepmx,steptl,xsize,varargin{:});

  %  
  % use central differences to compute gradient if a lower point is
  %   not found and forward differences had been used
  %

  if (iretcd==1 && iagflg==0);
    iagflg=-1;
    xh1=x0+cddev; xh0=x0-cddev; h = xh1-xh0;
    for i=1:n
        xx = x0; 
        xx(i)=xh1(i); fev1=feval(func,xx,varargin{:});
        xx(i)=xh0(i); fev0=feval(func,xx,varargin{:});
        g0(i,1) = (fev1-fev0)/h(i);
    end
    invl=inv(L);
    p=-invl'*invl*g0;
    [x,f,p,mxtake,iretcd]=umlnmin(x0,f0,g0,p,func,stepmx,steptl,xsize,varargin{:});
  end;

  %
  % compute new gradient vector, g
  %

  if iagflg==-1;        % central difference numerical gradient
    xh1=x+cddev; xh0=x-cddev; h = xh1-xh0;
    for i=1:n
        xx = x; 
        xx(i)=xh1(i); fev1=feval(func,xx,varargin{:});
        xx(i)=xh0(i); fev0=feval(func,xx,varargin{:});
        g(i,1) = (fev1-fev0)/h(i);
    end
  elseif iagflg==0;     % forward difference numerical gradient
    xh = x+fddev; h = xh-x;
    for i=1:n
        xx = x; xx(i)=xh(i);
        g(i,1) = ( feval(func,xx,varargin{:}) - f )/h(i);
    end
  else                  % analitic gradient
    [tem,g] = feval(func,x,varargin{:});
  end;

  %
  % check convergence
  %

  [code,status,icscmx]=umstop(x,x0,f,f0,g,xtol,ftol,gtol,epsa,xsize,fsize, ...
                              iter,maxits,iretcd,mxtake,icscmx);
  %
  % update Hessian = L*L'
  %

  if ~code;

    s=x-x0;
    y=g-g0;
    sy=s'*y;

    if iter==1; 
      L=sqrt(sy/(s'*s))*L; 
      invl=sqrt(s'*s/sy)*invl;
    end;

    if sy>0;
      ls=L'*s;
      tem=L*( eye(n)-(ls*ls')/(ls'*ls)+(invl*y)*(invl*y)'/sy)*L';
      tem=triu(tem)+triu(tem,1)';
      if any(eig(tem) <= -eps)||(norm(tem'-tem,1)/norm(tem,1) > eps)|| ...
                                 any(any(imag(tem)))
        if prt; 
          disp('L*S*L not positive definite, eigs are')
          eig(tem)
        end;
      else 
        [Ltem,cholerr] = chol(tem);
        if cholerr~=0;
          if prt; 
            disp('L*S*L not positive definite, eigs are')
            eig(tem)
          end;
        else
          L = Ltem';
        end;
      end;
    end;

    f0=f;
    x0=x;
    g0=g;
  end;

  if prt;    % & rem(iter,50)==0)
    %clc
    %home
    fprintf('Iteration  %g\n',iter)
    disp('   parameter # -- estimate -- gradient')
    disp(sprintf('   %3g %20.8f %20.8f \n',[(1:n)',x,g]'))
    disp(' ')
    disp('   function value (f) -- norm(gradient)/(1+f)')
    disp(sprintf('       %20.8f %20.8f \n',[f,norm(g)/(1+f)]))
    disp(' ')
    disp(' ')
  end
end;
