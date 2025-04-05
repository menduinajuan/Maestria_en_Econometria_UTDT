%CAM_RUN.M
%Compute numerically a first-order approximation, second moments, and impulse responses  implied by  the Small Open Economy Model With An External Debt-Elastic Interest Rate as presented in chapter 4 of ``Open Economy Macroeconomics,'' by Martin Uribe, 2013.

clear all

cam_ss

cam_num_eval %this .m script was created by running cam_model.m 


%The linearized equilibrium system is of the form
%y_t=gx x_t
%x_t+1 = hx x_t + ETASHOCK epsilon_t+1
[gx, hx, exitflag] = gx_hx(nfy, nfx, nfyp, nfxp);


nx = size(hx,1); %number of states

%Variance/Covariance matrix of innovation to state vector x_t
varshock = nETASHOCK*nETASHOCK';

%Position of variables in the control vector
noutput = 3; %output
nc = 1; %consumption
nivv = 2; %investment
nh = 4; %hours
ntb = 11; %trade balance
ntby = 8; %trade-balance-to-output ratio
nca = 9; %current account
ncay = 10; %current-account-to-output ratio
%Position of variables in the state vector
ns = 1; %debt
nk = 2; %capital
na = 3; %TFP

%standard deviations
 [sigy0,sigx0]=mom(gx,hx,varshock);
stds = sqrt(diag(sigy0));

%correlations with output
corr_xy = sigy0(:,noutput)./stds(noutput)./stds;

%serial correlations
 [sigy1,sigx1]=mom(gx,hx,varshock,1);
scorr = diag(sigy1)./diag(sigy0);

%make a table containing second moments
num_table = [stds*100  scorr corr_xy];

%From this table, select variables of interest (output, c, ivv, h, tby, cay)
disp('In This table:');
disp('Rows: y,c,i,tb/y,ca/y');
disp('Columns: std, serial corr., corr with y');
num_table1 = num_table([noutput nc nivv ntby  ncay],:);
disp(num_table1);


%Compute Impulse Responses
T = 11; %number of periods for impulse responses
%Give a unit innovation to TFP
x0 = zeros(nx,1);
x0(end) = 0.01;
%Compute Impulse Response
[IR IRy IRx]=ir(gx,hx,x0,T);

%Plot Impulse responses
t=(0:T-1)';

subplot(3,2,1)
plot(t,IR(:,noutput)*100,'w')
title('Output')

subplot(3,2,2)
plot(t,IR(:,nc)*100,'w')
title('Consumption')

subplot(3,2,3)
plot(t,IR(:,nivv)*100,'w')
title('Investment')

subplot(3,2,4)
plot(t,IR(:,nh)*100,'w')
title('Hours')

subplot(3,2,5)
plot(t,IR(:,ntby)*100,'w')
title('Trade Balance / Output')

subplot(3,2,6)
plot(t,IR(:,nca)*100,'w')
title('Current Account / Output')
shg



