%EDEIR_RUN.M
%Compute numerically a first-order approximation, second moments, and impulse responses  implied by  the Small Open Economy Model With An External Debt-Elastic Interest Rate as presented in chapter 4 of ``Open Economy Macroeconomics,'' by Martin Uribe, 2013.

clear all

edeir_ss

edeir_num_eval %this .m script was created by running edeir_model.m 


%The linearized equilibrium system is of the form
%y_t=gx x_t
%x_t+1 = hx x_t + ETASHOCK epsilon_t+1
[gx, hx, exitflag] = gx_hx(nfy, nfx, nfyp, nfxp);

varshock = nETASHOCK*nETASHOCK';

%Position of variables in the control vector
noutput = 3; %output
nc = 1; %consumption
nivv = 2; %investment
nh = 4; %hours
ntb = 8; %trade balance
ntby = 9; %trade-balance-to-output ratio
nca = 10; %current account
ncay = 11; %current-account-to-output ratio
ntfp = 7; %TFP

%standard deviations
 [sigy0,sigx0]=mom(gx,hx,varshock);
stds = sqrt(diag(sigy0));

%correlations with output
corr_xy = sigy0(:,noutput)./stds(noutput)./stds;

%serial correlations
 [sigy1,sigx1]=mom(gx,hx,varshock,1);
scorr = diag(sigy1)./diag(sigy0);

%make a table containing second moments
num_table = [stds corr_xy scorr];

%From this table, select variables of interest (output, c, ivv, h, tby, cay)
disp('In This table:');
disp('Rows: y,c,i,tb/y,ca/y');
disp('Columns: std, corr with y, serial corr.');
num_table1 = num_table([noutput nc nivv ntby  ncay],:);
disp(num_table1);

%Compute Impulse Responses
nx = size(hx,1);
T = 11; %number of periods for impulse responses
%Give a unit innovation to TFP
x0 = zeros(nx,1);
x0(end) = 1;
%Compute Impulse Response
IR=ir(gx,hx,x0,T);

%Plot Impulse responses
t=(0:T-1)';

subplot(3,2,1)
plot(t,IR(:,noutput))
title('Output')

subplot(3,2,2)
plot(t,IR(:,nc))
title('Consumption')

subplot(3,2,3)
plot(t,IR(:,nivv))
title('Investment')

subplot(3,2,4)
plot(t,IR(:,nh))
title('Hours')

subplot(3,2,5)
plot(t,IR(:,ntby))
title('Trade Balance / Output')

subplot(3,2,6)
plot(t,IR(:,ntfp))
title('TFP Shock')
shg