% 
%%
% Code to replicate Blanchard and Quah with newer data

% Clean up
clear; close all;

% Inputs for impulse responses and confidence bandas:
nper_irf = 21;   % Number of periods to compute IRFs
ndraws   = 1000; % Number of bootstrap draws to compute confidence bands
pctg     = 90;   % To compute pcgt% (e.g. 90%) confidence bands

% --------------------------------------------------------------
% Load data
%[Y, labels] = xlsread('Data_BQ.xlsx','Sheet1');
[Y, labels] = xlsread('Data_BQ_new.xlsx','Sheet1');
time = Y(:,1);
Y = Y(:,2:end); % Data in last two columns
[nobs, nvars] = size(Y);


% --------------------------------------------------------------
% Construct (log) GDP growth
GDP_growth = log(Y(2:nobs,1))-log(Y(1:nobs-1,1));   % GDP growth
unemp = Y(2:nobs,2)/100;                            % Unemployment rate

% Create array data in a way to be usable in my var_ls.m routine
data = [GDP_growth unemp]';

figure;
plot(time(2:end),data','linewidth',2);
title('GDP growth and unemployment rate','fontsize',14)
hleg=legend('GDP growth','Unemployment rate','location','best');
legend('boxoff');
set(hleg,'fontsize',12);
grid on
xlim([1946 2018])

% --------------------------------------------------------------
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

% Will choose model with 3 lags, consistent with info criteria
% ------------------------------------------------------------
% ESTIMATE REDUCED FORM MODEL
nlags = 3;  % This number of lags in the VAR
fprintf('\n Estimating Reduced form Model with %i lags \n',nlags);

outputVAR = var_ls( data, nlags );

% --------------------------------------------------------------
% IMPOSE LONG-RUN IDENTIFYING ASSUMPTION:
%   Only supply shock (first shock) has a long-run impact on the level of GDP

% Construct main matrices, following the slides

% Write (demeand) VAR as Y(t) = D1*Y(t-1)+...+Dp*Y(t-p) + v(t)

% Grab D matrices:
D = zeros(2,2,nlags);
for il = 1:nlags
    D(:,:,il) = outputVAR.coef{il};
end

% Compute D1+D2+...+Dp
Dsum = sum(D,3);    % Sum along third dimension (matrices on lagged values indexed by third dimension)

% Compute Cbar = ( I - Dsum )^(-1)
Cbar = inv(eye(2)-Dsum);

% Compute Matrix W:
W = Cbar*outputVAR.Omega*Cbar'; %#ok<MINV>

% Find elements of matrix F
f11 = sqrt(W(1,1));
f21 = W(2,1)/f11;
f22 = sqrt(W(2,2)-f21^2);
F =[ f11   0  ;
     f21  f22];

% Identification matrix S:
S = (eye(2)-Dsum)*F;
fprintf('\n Identification matrix S using long-run restriction\n');
disp(S);

% -------------------------------------------------------
% COMPUTE IMPULSE RESPONSE TO IDENTIFIED TECHNOLOGY SHOCK
% Will write the identified VAR in companion form:
%
% Z[t] = B * Z[t-1] + Q*eps[t]                                      (2)
%
% where   _       _       _                     _       _   _
%        |  Y[t]   |    |   D1  D2 ...   Dp-1 Dp |     |  S  |
%        | Y[t-1]  |    |   I   0         0   0  |     |  0  |
% Z[t] = | Y[t-2]  | B =|   0   I         0   0  | Q = |  0  |
%        |  :      |    |   :   :         :   :  |     |  :  |
%        | Y[t-p+1]|    |   0   0  ...    I   0  |     |  0  |
%         -       -      -                      -       -   -
% 
% --------------------------------------------------------------
% I) COMPUTE COMPANION MATRIX "Bc" and Q TO COMPUTE IMPULSE RESPONSE

% Create companion matrix Birf:
Bc = zeros(nvars*nlags);
for i=1:nlags
    Bc(1:nvars,(i-1)*nvars+1:i*nvars) = D(:,:,i);
end

% Add big identity matrix below first set of rows
Bc( nvars+1:end,1:nvars*(nlags-1) ) = eye( nvars*(nlags-1) );    

% Create matrix Q:
Q = zeros( nvars*nlags, nvars );
Q(1:nvars,:) = S;
% ---------------------------------------------------------------
% II) COMPUTE IMPULSE RESPONSE FUNCTION DUE TO EACH SHOCK

% Initialize arrays to compute impulse responses
irf = zeros(nper_irf,nvars,nvars);  % First dimension:  periods
                                    % Second dimension: variables
                                    % Third dimension: shocks

Bpowtm1 = eye( nvars*nlags );   % Initialize matrix Bc^(t-1);

for t=1:nper_irf
    % Compute all impulse responses at t at once and store result in Yimpt 
    % Yimpt(1:nvar,i) contains irf at t to shock i
    Yimpt = Bpowtm1*Q;
    
    % Update Bpowtm1 matrix for next iteration
    Bpowtm1 = Bpowtm1*Bc;
    
    % Store impulse responses at t where they belong
    for ishock=1:nvars     % Iterate over shocks
        irf(t,:,ishock) = Yimpt(1:nvars,ishock)';
    end
end

%% COMPUTE BOOTSTRAPPED CONFIDENCE BANDS
resid = outputVAR.resid;    % Array with residuals
nnobs = size(resid,2);      % Number of residuals
irf_draw = zeros(nper_irf,nvars,nvars,ndraws);  % To store bootstrapped IRFs

for tt=1:ndraws

    % I. Bootstrap residuals
    %indexdraw = ceil(nnobs*rand(1,nnobs));  % Compute random integers between 1 and nnobs
    indexdraw = randi(nnobs,1,nnobs);  % Compute nnobs random integers between 1 and nnobs
    u = resid(:,indexdraw);   % Bootstrap residuals

    %       -------------------------
    % II. Generate Artificial data
    %   II.1 Initial values for artificial data
    y_artificial = zeros(size(data));
    y_artificial(:,1:nlags) = data(:,1:nlags);  % First nlags observations    
    
    for jj=nlags+1:nlags+nnobs
        RHS = outputVAR.const;
        for ilag=1:nlags
            RHS = RHS + D(:,:,ilag)*y_artificial(:,jj-ilag);
        end
        y_artificial(:,jj) = RHS + u(:,jj-nlags);
    end
    
    %       -------------------------
    % III. Estimate VAR on artificial data
    outputBS = var_ls( y_artificial, nlags );
    
    %       -------------------------
    % IV. Impose long-run identifying assumption
    
    Dbs = zeros(2,2,nlags);
    for il = 1:nlags
        Dbs(:,:,il) = outputBS.coef{il};
    end
    % Compute D1+D2+...+Dp
    Dsum = sum(Dbs,3);    % Sum along third dimension, which are the different matrices

    % Compute Cbar = ( I - Dsum )^(-1)
    Cbar = inv(eye(2)-Dsum);

    % Compute Matrix W:
    W = Cbar*outputBS.Omega*Cbar'; %#ok<MINV>

    % Find elements of matrix F
    f11 = sqrt(W(1,1));
    f21 = W(2,1)/f11;
    f22 = sqrt(W(2,2)-f21^2);
    F =[ f11   0  ;
         f21  f22];

    % Identification matrix S:
    Sbs = (eye(2)-Dsum)*F;
    
    %       -------------------------
    % V.  COMPUTE COMPANION MATRIX "Bc" and Q TO COMPUTE IMPULSE RESPONSE

    % Create companion matrix Birf:
    Bc = zeros(nvars*nlags);
    for il=1:nlags
        Bc(1:nvars,(il-1)*nvars+1:il*nvars) = Dbs(:,:,il);
    end
    % Add big identity matrix below first set of rows
    Bc( nvars+1:end,1:nvars*(nlags-1) ) = eye( nvars*(nlags-1) );    

    % Create matrix Q:
    Q = zeros( nvars*nlags, nvars );
    Q(1:nvars,:) = Sbs;

    %       -------------------------
    % VI.  COMPUTE COMPANION MATRIX "Bc" and Q TO COMPUTE IMPULSE RESPONSE
    Bpowtm1 = eye( nvars*nlags );   % Initialize matrix Bc^(t-1);

    for it=1:nper_irf
        Yimpt = Bpowtm1*Q;
        Bpowtm1 = Bpowtm1*Bc;
        for ishock=1:nvars     % Iterate over shocks
            irf_draw(it,:,ishock,tt) = Yimpt(1:nvars,ishock)';
        end
    end
    
end

% Compute error bands
pctg_inf = (100-pctg)/2; 
pctg_sup = 100 - (100-pctg)/2;

INF(:,:,:) = prctile(irf_draw(:,:,:,:),pctg_inf,4);
SUP(:,:,:) = prctile(irf_draw(:,:,:,:),pctg_sup,4);
MED(:,:,:) = prctile(irf_draw(:,:,:,:),50,4);

% -----------------------------------------------

% Plot impulse responses
figure;
 
subplot(2,2,1)
plot(0:nper_irf-1,100*irf(:,1,1),...
     0:nper_irf-1,100*INF(:,1,1),'--k',...
     0:nper_irf-1,100*SUP(:,1,1),'--k','Linewidth',1.5);
grid on
title('Response of GDP growth to supply shock','Fontsize',12)

subplot(2,2,3)
plot(0:nper_irf-1,100*irf(:,2,1),...
     0:nper_irf-1,100*INF(:,2,1),'--k',...
     0:nper_irf-1,100*SUP(:,2,1),'--k','Linewidth',1.5);
title('Response of unemployment to supply shock','Fontsize',12)
grid on

subplot(2,2,2)
plot(0:nper_irf-1,100*irf(:,1,2),...
     0:nper_irf-1,100*INF(:,1,2),'--k',...
     0:nper_irf-1,100*SUP(:,1,2),'--k','Linewidth',1.5);
grid on
title('Response of GDP growth to demand shock','Fontsize',12)

subplot(2,2,4)
plot(0:nper_irf-1,100*irf(:,2,2),...
     0:nper_irf-1,100*INF(:,2,2),'--k',...
     0:nper_irf-1,100*SUP(:,2,2),'--k','Linewidth',1.5);
grid on
title('Response of unemployment to demand shock','Fontsize',12)
