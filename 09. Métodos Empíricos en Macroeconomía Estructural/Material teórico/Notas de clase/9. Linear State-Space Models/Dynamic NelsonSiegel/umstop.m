function [code,status,icscmx]=umstop(x,x0,f,f0,g,xtol,ftol,gtol,epsa,xsize, ...
                                     fsize,iter,maxits,iretcd,mxtake,icscmx)
code=0;
status=[0;0;0;0];

%-------------------------------------------------------------------
%              CHECK IF NORM OF GRADIENT WITHIN TOLERANCE
%-------------------------------------------------------------------

status(1)=( norm(g)< epsa );

if status(1);
  code=1;
  return
end;

%-------------------------------------------------------------------
%              CHECK IF RELATIVE GRADIENT WITHIN TOLERANCE
%-------------------------------------------------------------------

d=1+max(abs(f),fsize);
status(2)=( norm(g)< gtol*d );

%-------------------------------------------------------------------
%                CHECK IF CHANGE IN X WITHIN TOLERANCE
%-------------------------------------------------------------------

status(3)=( norm(x-x0) < xtol*(1+ max(norm(x),norm(xsize)) ) );

%-------------------------------------------------------------------
%                CHECK IF CHANGE IN F WITHIN TOLERANCE
%-------------------------------------------------------------------

status(4)=( f0-f< ftol*(1+d) );

if sum(status(2:4))>=3; 
  code=1; 
  return
end;

%-------------------------------------------------------------------
%          CHECK IF LAST STEP FAILED TO LOCATE LOWER POINT   
%-------------------------------------------------------------------

if iretcd==1;    
  code=2;   
  return
end;

%-------------------------------------------------------------------
%                       CHECK ITERATION LIMIT
%-------------------------------------------------------------------

if iter>=maxits;
  code=3;
  return
end;

%-------------------------------------------------------------------
%                 CHECK NUMBER OF CONSECUTIVE STEPS 
%-------------------------------------------------------------------
if mxtake;
  icscmx=icscmx+1;
  if icscmx>=5; code=4; end;
else
  icscmx=0;
end;
