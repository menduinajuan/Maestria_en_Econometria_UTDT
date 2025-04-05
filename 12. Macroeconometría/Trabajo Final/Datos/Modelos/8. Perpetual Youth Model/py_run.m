%This program computes a log-linear approximation to the policy function of a small open economy with a debt-elastic interest-rate premium (see ``Closing Small Open Economy Models,'' by Stephanie Schmitt-Grohe and Martin Uribe). The reduced form of the model can be written as: %E_t[f(yp,y,xp,x)=0, 
%
%The solution is of the form
%
%xp = h(x,sigma) + sigma * eta * ep
%
%y = g(x,sigma)
% x is the state (no jump) vector and y is the control (jump) vector. 
% hx and gx are, respectively,  the derivatives of h and g wrt x evaluated at the non-stochastic steady state
%
%Calls: deir.m gx_hx.m mom.m and ir.m
% 
%(c) Stephanie Schmitt-Grohe and Martin Uribe
%Date November 8, 2001

[fx,fxp,fy,fyp] = py;

[gx,hx] = gx_hx(fy,fx,fyp,fxp); 

%MOMENTS

%Construct Variance/Covariance Matrix of Innovations to State Process
varshock = zeros(size(hx,1));
varshock(end,end)=0.0129^2; %Table 6 of Mendoza AER 1991. 

%Compute Variance/covariance matrix
[var_y,var_x] = mom(gx,hx,varshock,0);

%First-order autocovariance
[var_y1,var_x1] = mom(gx,hx,varshock,1);

%Construct a Table with 2nd Moments
table(1:6,1) = (diag(var_y(1:6,1:6)).^(1/2))*100;

table(1:6,2) = diag(var_y1(1:6,1:6)) ./ diag(var_y(1:6,1:6));

table(1:6,3) = var_y(1:6,1) ./ (diag(var_y(1:6,1:6)).^(1/2)) /var_y(1,1)^(1/2)

%Impulse responses
x0 = zeros(size(hx,1),1);
x0(end) = 1; 
IR=ir(gx,hx,x0,10);

t=(0:size(IR,1)-1)';
y = IR(:,1);
c = IR(:,2);
i = IR(:,3);
h = IR(:,4);
tby = IR(:,5);
cay = IR(:,6);

subplot(3,2,1)
plot(t,y)
title('Output')

subplot(3,2,2)
plot(t,c)
title('Consumption')

subplot(3,2,3)
plot(t,i)
title('Investment')

subplot(3,2,4)
plot(t,h)
title('Hours')

subplot(3,2,5)
plot(t,tby)
title('Trade Balance / GDP')

subplot(3,2,6)
plot(t,cay)
title('Current Account / GDP')

shg