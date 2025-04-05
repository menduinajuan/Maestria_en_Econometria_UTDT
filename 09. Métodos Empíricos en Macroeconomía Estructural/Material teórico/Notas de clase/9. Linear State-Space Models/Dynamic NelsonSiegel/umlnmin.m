function [x,f,p,mxtake,iretcd]=umlnmin(x0,f0,g,p,func,stepmx,steptl,xsize,varargin)
mxtake=0;
iretcd=2;
sln=sqrt(sum(p./xsize.*p./xsize));
if sln>stepmx;
  p=stepmx*p/sln;
  sln=stepmx;
end;
gp=g'*p;
gps=gp*1e-12;                              % alter gps if a more stringent
rln=max(abs(p)./max(abs(x0),xsize));       % line search is required
rmnlmb=1e-10*steptl/rln;
lambda=1;

%----------------------------------------------------------------------
% CHECK IF STEP LAMBDA IS SATISFACTORY; OTHERWISE GENERATE NEW LAMBDA 
%----------------------------------------------------------------------

while (iretcd>=2);
  x=x0+lambda*p;
  f = feval( func, x, varargin{:} );
  if f<f0+gps*lambda;
    iretcd=0;
    if lambda==1.0 && sln>.99*stepmx;
      mxtake=1;
    end;
  else
    if lambda<rmnlmb;
      %fprintf('found %g=lambda<rmnlmb=%g',lambda,rmnlmb)
      iretcd=1;
    else
      if lambda==1.0;
        lmbda2=-gp/(2*(f-f0-gp));
      else
        t1=f-f0-lambda*gp;
        t2=f1-f0-lmbda1*gp;
        t3=1/(lambda-lmbda1);
        a=t3*(t1/(lambda*lambda)-t2/(lmbda1*lmbda1));
        b=t3*(t2*lambda/(lmbda1*lmbda1)-t1*lmbda1/(lambda*lambda));
        disc=b*b-3*a*gp;
        if disc>b*b;
          lmbda2=(-b+sign(a)*sqrt(disc))/(3*a);
        else
          lmbda2=(-b-sign(a)*sqrt(disc))/(3*a);
        end;
        lmbda2=min(lmbda2,.5*lambda);
      end;
      lmbda1=lambda;
      f1=f;
      lambda=max(lambda*.1,lmbda2);
    end;
  end;
end;
