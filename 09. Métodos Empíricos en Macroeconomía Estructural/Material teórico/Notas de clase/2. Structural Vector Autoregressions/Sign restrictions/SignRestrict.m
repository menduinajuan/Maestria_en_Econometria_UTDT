% This program computes sign restrictions in a simple bivariate VAR with
% real GDP and inflation.
%
% Sign restrictions to identify demand shocks and supply shocks
% 
% 1. Demand shock: GDP growth>0; Inflation>0;
% 2. Supply shock: GDP growth>0; Inflation<0;
%
% Impose restriction for impulse responses at horizone ho=1,2,...,4 or the
% number that you consider reasonable.

% Clean up
clear; close all;

% --------------------------------------------------------------
% Load data and construct relevant data
[Y, labels] = xlsread('Data_SR.xlsx','Sheet1');
dates = Y(:,1);
Y = Y(:,2:end); % Data in last two columns
[nobs, nvars] = size(Y);

% Construct (log) GDP growth
GDP_gr = log(Y(2:nobs,1))-log(Y(1:nobs-1,1));   % Log GDP growth
Inflat = log(Y(2:nobs,2))-log(Y(1:nobs-1,2));   % Log Inflation

% Create array data in a way to be usable in my var_ls.m routine
data = 400*[GDP_gr Inflat]';    % Put in % and annual terms

figure;
plot(dates(2:end),data,'linewidth',2);
legend('GDP growth','Inflation');
grid on
% --------------------------------------------------------------
check_lag_length = 0;   %>0 if yes, =0 if no

if check_lag_length

    % Check lag length using standard criteria
    Lmax = 8; % Maximun number of lags to check for VAR order

    % To store information criteria
    AIC = zeros(Lmax,1);
    SIC = zeros(Lmax,1);
    HQC = zeros(Lmax,1);

    % Estimate for each lag to compute information criteria
    for ilag = 1:Lmax
        outputVAR = var_ls( data, ilag, Lmax );
        AIC(ilag) = outputVAR.AIC;  % Akaike
        SIC(ilag) = outputVAR.SIC;  % Schwarz
        HQC(ilag) = outputVAR.HQC;  % Hannan-Quinn
    end
    fprintf('\n Information Criteria \n\n')
    fprintf('Lag    AIC      SIC      HQC  \n');
    fprintf('============================= \n');
    for il = 1:Lmax
        fprintf(' %i  %6.3f   %6.3f   %6.3f \n',il,AIC(il),SIC(il),HQC(il));
    end
    return  % Esto me dice que corte el programa aca. Se ignora lo que sigue.
end

% --------------------------------------------------------------
% Parameters of the procedure
nlags = 3;         % number of lags of the VAR.
nimp  = 20;        % Horizon for impulse responses to be computed.
ho    = 2;         % number of periods over which sign restrictions are imposed.
maxdraws = 10000;  % maximum number of rotations tried

% --------------------------------------------------------------
% Estimate the reduced form VAR
outputVAR = var_ls( data, nlags );

% --------------------------------------------------------------
% Now construct key elements to compute impulse responses. Need to write
% system in companion form. Matrix Bc is the companion matrix.

D = zeros(nvars,nvars,nlags);
for il = 1:nlags
    D(:,:,il) = outputVAR.coef{il};
end

% Create companion matrix Birf:
Bc = zeros(nvars*nlags);
for i=1:nlags
    Bc(1:nvars,(i-1)*nvars+1:i*nvars) = D(:,:,i);
end

% Add big identity matrix below first set of rows
Bc( nvars+1:end,1:nvars*(nlags-1) ) = eye( nvars*(nlags-1) );

% --------------------------------------------------------------
% Now compute arbitrary Cholesky impulse response.

chol_irf = zeros(nvars,nvars,nimp);  % First dimension: variables
                                     % Second dimension: shocks
                                     % Third dimension:  periods

Bpowtm1 = eye( nvars*nlags );        % Initialize matrix Bc^(t-1);

Schol   = chol(outputVAR.Omega,'lower');    % Cholesky decomposition of variance covariance matrix
Qc       = zeros( nvars*nlags, nvars );     % Matrix Qc of companion form
Qc(1:nvars,:) = Schol;

for t=1:nimp
    % Compute all impulse responses at t at once and store result in Yimpt 
    % Yimpt(1:nvar,i) contains irf at t to shock i
    Yimpt = Bpowtm1*Qc;
    
    % Update Bpowtm1 matrix for next iteration
    Bpowtm1 = Bpowtm1*Bc;
    
    % Store impulse responses at t where they belong
    for ishock=1:nvars     % Iterate over shocks
        chol_irf(:,ishock,t) = Yimpt(1:nvars,ishock)';
    end
end

% --------------------------------------------------------------
% Draw standard random variables to test different orthogonalization
% matrices

% Array to store impulse responses
irf = zeros(nvars,nvars,nimp,maxdraws); 

dr=1;   % Index to store draws
gg=0;   % Index to store accepted models

while dr <= maxdraws

    % Draw matrix of normal (0,1) random variables
    L = randn(nvars);
    
    % Perform QR decomposition of the matrix L
    [Q,R] = qr(L);
    
    % If diagonal elements of R are <0, can switch the variable
    for ii=1:nvars
        if R(ii,ii)<0
            Q(:,ii) = -Q(:,ii);     % Reflection matrix
        end
    end
   
    Scheck = zeros(nvars,nvars,ho);
    % Compute impulse response until horizon ho
    for it = 1:ho
        Scheck(:,:,it) = chol_irf(:,:,it)*Q';
    end
    
    % Check if sign restriction is satisfied for shock 1: GDP growth>0; Inflation<0;
    z1=[squeeze(Scheck(1,1,1:ho))'>0 squeeze(Scheck(2,1,1:ho))'<0];   % If restrictions are satisfied all the elements are a 1
    zz1=sum(z1);
    if zz1==size(z1,2)      % If all sign restrictions are satisfied
        gg = gg+1;          % Accept this model
        for it = 1:nimp
            irf(:,:,it,gg) = chol_irf(:,:,it)*Q';
        end
    end
    dr = dr+1;
end
fprintf('\nNumber of draws = %i; Number of accepted draws = %i \n',dr-1,gg)

% Drop dimensions with no data in irf array
irf(:,:,:,gg+1:end)=[];

% All impulse responses of supply shock on real GDP growth 
irfmat11 = squeeze(irf(1,1,:,:));   

% All impulse responses of supply shock on inflation
irfmat21 = squeeze(irf(2,1,:,:));

figure

subplot(2,1,1)
plot(irfmat11)
axis tight
title('Supply shock -> GDP growth (all models)')

subplot(2,1,2)
plot(irfmat21)
axis tight
title('Supply shock -> Inflation (all models)')

% Percentiles of models (there are problems doing this. See literature)
prct = [5 50 95];
irf11_prct = prctile(irfmat11,prct,2);
irf21_prct = prctile(irfmat21,prct,2);

figure
subplot(2,1,1)
plot(irf11_prct,'Linewidth',2);
legend('5th','50th','95th','Location','Best')
legend boxoff
title('Supply shock -> GDP growth (percentiles)')
axis tight

subplot(2,1,2)
plot(irf21_prct,'Linewidth',2);
legend('5th','50th','95th','Location','Best')
legend boxoff
title('Supply shock -> Inflation (percentiles)')
axis tight