%% This program estimates the BVAR with the Jeffreys prior
%  p(beta,OMEGA) \propto |OMEGA|^(-(n+1)/2)

clearvars
close all

% MY COLORS FOR THE PLOTS:
color1 = [55  140 190]/255;     % Blue
color2 = [250 140 100]/255;     % Orange
color3 = [100 190 165]/255;     % Green
color4 = [240  60  50]/255;     % Red
color5 = [140 110 180]/255;     % Purple
color6 = [230 195 150]/255;     % Beige
color7 = [166 215 85]/255;      % Other green

%% LOAD DATA FROM FRED
%   Load quarterly US data on inflation, unemployment, and interest rates,
%   1953:Q1 - 2006:Q6

load Yraw.dat;
% 'Yraw' is a matrix with T rows by N columns,
% where T is the number of time series observations (usually months or
% quarters), while N is the number of VAR dependent macro variables.

time = (1953.125:.25:2006.625)';

subplot(3,1,1)
plot(time,Yraw(:,1),'linestyle','-','linewidth',2)
grid on
ylim([0 16])
title('Inflation')

subplot(3,1,2)
plot(time,Yraw(:,2),'linestyle','-','linewidth',2)
grid on
ylim([0 16])
title('Unemployment')

subplot(3,1,3)
plot(time,Yraw(:,3),'linestyle','-','linewidth',2)
grid on
ylim([0 16])
title('Interest rate')


%% ----------------------------PRELIMINARIES-------------------------------

% Specification of the VAR model
constant = 1;               % =1 if VAR includes a constant, =0 otherwise
p_lags   = 4;               % Number of lags in the VAR
do_impulse_response = 1;    % =1 compute impulse responses of Cholesky factorization, =0 do not
impulse_horizon = 25;       % Horizon to cumpute impulse response

% Specify number of draws for posterior
ndraws = 20000;                 % Number of effective draws
nburn  = 0*ndraws;              % Number of draws to burn
ndraws_total = ndraws + nburn;  % Total number of draws
iteration_print = 2000;         % Print info on the screen every "iteration_print" iterations

%% PREPROCESSING THE DATA FOR ESTIMATION

% Get dimensions of the data without the initial p_lags observations
Traw = size(Yraw,1);        % Total number observations
n    = size(Yraw,2);        % Number of endogenous variables
T = Traw-p_lags;            % Total number of usable observations


% LHS variables:
YY = Yraw(p_lags+1:end,:);

% RHS variables:
if constant
    XX  = zeros( T, n*p_lags + 1 ); 
else
    XX  = zeros( T, n*p_lags  ); %#ok<UNRCH>
end

% Fill rows using lagged values:
for i = 1 : p_lags
    XX( :, 1+(i-1)*n : i*n ) = Yraw( p_lags + 1-i :  Traw - i, :);
end

%   Now check if there is a constant and add it if yes
if constant
    % Last column is the constant if there is a constant in the VAR
    XX(:,n*p_lags + 1) = 1;
end
k = size(XX,2);     % Number of columns in XX


%% ESTIMATE VAR WITH OLS (SAME AS MLE)

BETA_OLS  = ( XX'*XX )\(XX'*YY);

beta_OLS = BETA_OLS(:);     % Vectorize OLS coefficients

%   Covariance matrix using OLS
resid = YY - XX*BETA_OLS;
SSE = resid'*resid;
OMEGA_OLS = SSE/(T - k + 1 );

%% SET STUFF FOR DRAWINGS

% Wishart stuff
degrees_freedom = T - k;
SSinv = inv(SSE);           % Inverse of sum of squared residuals
XXpXXm1 = inv(XX'*XX);

%% START SAMPLING FROM THE POSTERIOR

% Initialize Bayesian posterior parameters using OLS values
beta = beta_OLS;     % This is the single draw from the posterior of beta
BETA = BETA_OLS;     % This is the single draw from the posterior of BETA
SSE_Gibbs = SSE;     % This is the SSE based on each draw of BETA
OMEGA = OMEGA_OLS;   % This is the single draw from the posterior of OMEGA

% Storage space for posterior draws
beta_draws  = zeros(ndraws,k*n);    % save draws of beta
BETA_draws  = zeros(ndraws,k,n);    % save draws of BETA
OMEGA_draws = zeros(ndraws,n,n);    % save draws of OMEGA


% TO STORE IMPULSE RESPONSES
irf_draw = zeros(impulse_horizon,n,n,ndraws);   % First dimension:  horizon
                                                % Second dimension: variables
                                                % Third dimension: shocks
                                                % Fourth dimension: draw

disp('Number of iterations');
tic;

for irep = 1:ndraws_total
    
    % Check if display number of iterations
    if mod(irep,iteration_print) == 0
        disp(irep)
    end
    
    % Draw OMEGA from inverse wishart
    OMEGA = inv( wish(SSinv,degrees_freedom) ); % Draw OMEGA
    
    
    % --------------------------------------------------
    % Draw beta from conditional probability
    
    beta = beta_OLS + chol( kron(OMEGA,XXpXXm1) )'*randn(k*n,1);
    BETA = reshape(beta,k,n); % Create draw in terms of BETA
    
    % ---------------------------------------------------
    % STORE PARAMETERS AND COMPUTE IMPULSE RESPONSE OF EACH DRAW IF ASKED
        
    if irep > nburn          
        
        %----- Save draws of the parameters
        beta_draws(irep-nburn,:)   = beta;
        BETA_draws(irep-nburn,:,:) = BETA; 
        OMEGA_draws(irep-nburn,:,:) = OMEGA;
        
        
        % -------------------------------------------------------
        % COMPUTE IMPULSE RESPONSE TO INTEREST RATE SHOCK USING CHOLESKY
        % Will write the identified VAR in companion form:
        %
        % Z[t] = Bc * Z[t-1] + Q*eps[t]  (2)
        %
        % where   _       _       _                     _       _   _
        %        |  Y[t]   |    |   D1  D2 ...   Dp-1 Dp |     |  S  |
        %        | Y[t-1]  |    |   I   0         0   0  |     |  0  |
        % Z[t] = | Y[t-2]  | Bc=|   0   I         0   0  | Q = |  0  |
        %        |  :      |    |   :   :         :   :  |     |  :  |
        %        | Y[t-p+1]|    |   0   0  ...    I   0  |     |  0  |
        %         -       -      -                      -       -   -
        % 
        % --------------------------------------------------------------
        % I) COMPUTE COMPANION MATRIX "Bc" and Q TO COMPUTE IMPULSE RESPONSE
        
        %   Create companion matrix Bc:
        Bc = zeros(n*p_lags);
        Bc( 1:n,1:n*p_lags ) = BETA(1:n*p_lags,:)';
        % Add big identity matrix below first set of rows
        Bc( n+1:end,1:n*(p_lags-1) ) = eye( n*(p_lags-1) );
        
        % Create matrix Q:
        Q = zeros( n*p_lags, n );
        Q(1:n,:) = chol(OMEGA,'lower');
        
        % ---------------------------------------------------------------
        % II) COMPUTE IMPULSE RESPONSE FUNCTION DUE TO EACH SHOCK

        BcPowtm1 = eye( n*p_lags );   % Initialize matrix Bc^(t-1);

        for it = 1:impulse_horizon
            Yimpt = BcPowtm1*Q;
            BcPowtm1 = BcPowtm1*Bc;
            for ishock=1:n     % Iterate over shocks
                irf_draw(it,:,ishock,irep-nburn) = Yimpt(1:n,ishock)';
            end
        end

    end 
end     % End main loop
toc

% COMPUTE MOMENTS FROM THE POSTERIOR OF BETA
%Posterior mean of parameters:
BETA_mean = squeeze(mean(BETA_draws,1)); % posterior mean of BETA

%Posterior standard deviations of parameters:
BETA_std = squeeze(std(BETA_draws,1));   % posterior std of BETA

% SET PERCENTILES FROM THE POSTERIOR DENSITY OF THE IMPULSE RESPONSES
pctg = 80;
pctg_inf = (100-pctg)/2; 
pctg_sup = 100 - (100-pctg)/2;

INF(:,:,:) = prctile(irf_draw(:,:,:,:),pctg_inf,4);
MED(:,:,:) = prctile(irf_draw(:,:,:,:),50,4);
SUP(:,:,:) = prctile(irf_draw(:,:,:,:),pctg_sup,4);

%% Make plots
colorplots = color2;
%colorplots = [0.3 0.3 0.3];

figure;
plot(0:impulse_horizon-1, MED(:,1,3),'Linestyle','-','color',colorplots,'Linewidth',3)
hold on
plot(0:impulse_horizon-1, INF(:,1,3),'Linestyle','--','color',colorplots,'Linewidth',3)
plot(0:impulse_horizon-1, SUP(:,1,3),'Linestyle','--','color',colorplots,'Linewidth',3)
ylim([-0.3 0.1])
hold off
grid on
title('IR interest rate => inflation','Fontsize',12)
tightfig;
print(gcf,'Figure_us_DiffusePriors_IR_inflation','-dpdf');


figure;
plot(0:impulse_horizon-1, MED(:,2,3),'Linestyle','-','color',colorplots,'Linewidth',3)
hold on
plot(0:impulse_horizon-1, INF(:,2,3),'Linestyle','--','color',colorplots,'Linewidth',3)
plot(0:impulse_horizon-1, SUP(:,2,3),'Linestyle','--','color',colorplots,'Linewidth',3)
ylim([-0.1 0.15])
hold off
grid on
title('IR interest rate => unemployment','Fontsize',12)
tightfig;
print(gcf,'Figure_us_DiffusePriors_IR_unemployment','-dpdf');


figure;
plot(0:impulse_horizon-1, MED(:,3,3),'Linestyle','-','color',colorplots,'Linewidth',3)
hold on
plot(0:impulse_horizon-1, INF(:,3,3),'Linestyle','--','color',colorplots,'Linewidth',3)
plot(0:impulse_horizon-1, SUP(:,3,3),'Linestyle','--','color',colorplots,'Linewidth',3)
ylim([-0.1 0.8])
hold off
grid on
title('IR interest rate => interest rate','Fontsize',12)
tightfig;
print(gcf,'Figure_us_DiffusePriors_IR_irate','-dpdf');



