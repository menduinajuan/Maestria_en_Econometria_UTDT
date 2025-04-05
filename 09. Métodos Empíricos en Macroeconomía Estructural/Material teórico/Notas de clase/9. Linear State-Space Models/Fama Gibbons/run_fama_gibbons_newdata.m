% This program estimates the ex-ante real interest rate using the
% Fama-Gibbons approach.

% Clean up
clear; close all;

% --------------------------------------------------------------
% Load data and construct relevant data
Y= xlsread('Data_Irates_new.xlsx','Data','A2:C872');
time = Y(:,1);          % Date (monthly)
Rf   = Y(:,2)/12/100;   % Interest rate monthly frequency
CPI  = Y(:,3);          % CPI;

clear Y;

i0   = find(time>=1950,1);              % Start in 1950
infl = CPI(i0+1:end)./CPI(i0:end-1)-1;  % Monthly inflation rate
ir   = Rf(i0:end-1);                    % Nominal interest rate
time = time(i0:end-1);                  % Time index


figure
plot(time,1200*[infl ir],'Linewidth',2)
tit = title('CPI inflation and 3-month nominal T-bill');
ylabel('Percent (annualized)')
grid on
leg = legend('Inflation','Interest rate','location','northeast');
set([leg tit],'Fontsize',12);
saveas(gcf,'fama_gibbons_1','epsc');



% Ex-post real interest rate
RR = ir - infl;

%% --------------------------------------------------------------
% Perform MLE of model:
%    x[t+1] - mu = phi*( x[t]-mu ) + w[t+1];   w ~ N( 0, sigx^2 )
%    y[t]   - mu = x[t]            + v[t];     v ~ N( 0, sigy^2 )
% 
% where,
%
% x[t] : demeaned expected real interest rate
% y[t] = i[t] - infl[t] - mu: demeaned ex-post real interest rate
% i[t] : nominal interest rate
% infl[t]: ex-post inflation rate between t and t+1
% mu: long-run average of real interest rate

% Initialize vector of parameters:
param_in = [  mean(RR);...       % mu
              3      ;...        % ome: transformation of phi so that phi belongs to [0 1] => phi = 1 / (1+exp(-ome))
              0.001   ;...       % parameter sigx
              0.001 ] ;          % parameter sigy
data = RR;

% Perform estimation:
[ loglik_out, param_out, unobserved ] = mle_fama_gibbons( param_in, data );

xhat = unobserved(1:end-1)';

mu  = param_out(1);
phi = 1/(1+exp(-param_out(2)));

ERR = xhat + mu;

fprintf('\nEstimated parameters: \n\n');
fprintf('   mu  =  %g \n',mu);
fprintf('   phi =  %g \n',phi);
fprintf('   sigx=  %g \n',sqrt(param_out(3)^2));
fprintf('   sigy=  %g \n',sqrt(param_out(4)^2));


figure
plot(time,1200*[RR ERR],'Linewidth',1.5)
tit = title('Ex-post and ex-ante real interest rate');
leg = legend('Ex-post','Ex-ante','location','northwest');
set([leg tit],'Fontsize',12);
ylabel('Percent (annualized)')
grid on
saveas(gcf,'fama_gibbons_2','epsc');

% Expectational errors RR-ERR
figure
plot(time,1200*(RR-ERR),'Linewidth',1.5)
tit = title('Expectational errors');
ylabel('Percent (annualized)')
grid on
saveas(gcf,'fama_gibbons_3','epsc');


figure
autocorr(RR-ERR)
title('Autocorrelation of expectational errors')
