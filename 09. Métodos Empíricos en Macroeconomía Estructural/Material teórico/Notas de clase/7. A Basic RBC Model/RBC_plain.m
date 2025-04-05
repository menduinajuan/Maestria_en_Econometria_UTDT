% The program solves the stochastic growth model with variable labor
% supply and separable utility using the QZ decomposition

clear; close all;
fprintf(' SOLVING THE BASIC RBC MODEL \n')
fprintf(' =========================== \n\n')

% -------------------------------------------------------------------------
% CALIBRATION AND STEADY STATE VALUES

% Frisch elasticity of labor supply
nu    = 1;          % This is usually taken from other studies

% Target values to match steady state quantities
Rbar  = 1.01;       % One percent real interest rate per quarter
Lbar  = 1/3;        % Steady state labor: a third of total available time
XYbar = 0.21;       % Average investment / output ratio

% Calibrated parameter values and steady state quantities
alpha  = 1/3;       % Capital share in output
beta   = 1/Rbar;    % Discount factor
delta  = (Rbar-1)*XYbar/(alpha-XYbar);  % Depreciation rate;

Kbar   = Lbar*( alpha/(Rbar-(1-delta)) )^(1/(1-alpha)); % Steady state capital
Ybar   = Kbar^alpha * Lbar^(1-alpha);                   % Steady state output
Cbar   = Ybar*(1-XYbar);                                % Steady state consumption
Xbar   = delta*Kbar;                                    % Steady state investment
Lambdabar = 1/Cbar;                                     % Steady state lambda

% Preference parameter eta: But this one disappears from the log-linearized equations!
eta    = (1-alpha)*(Ybar/Cbar)/Lbar^(1+1/nu);

% Coefficients of technology shock: calibrated using Solow residual
rho   = 0.95;
%sigma = 0.712;  % standard deviation technology shock. Units: Percent
sigma = 1.019;  % standard deviation technology shock. Units: Percent (chosen to match volatility of output in data approx 1.76% from McCallum

% DISPLAY CALIBRATED PARAMETERS
disp(' PARAMETROS CALIBRADOS')
disp(' ---------------------')
fprintf(' beta  = %4.3f \n',beta);
fprintf(' eta   = %4.3f \n',eta);
fprintf(' nu    = %4.3f \n',nu);
fprintf(' delta = %4.3f \n',delta);
fprintf(' alpha = %4.3f \n',alpha);
fprintf(' rho   = %4.3f \n',rho);
fprintf(' sigma = %4.3f \n\n',sigma);

disp(' VALORES DE ESTADO ESTACIONARIO')
disp(' ---------------------------')
fprintf(' Output       = %4.3f \n',Ybar);
fprintf(' Capital      = %4.3f \n',Kbar);
fprintf(' Investment   = %4.3f \n',Xbar);
fprintf(' Labor        = %4.3f \n',Lbar);
fprintf(' Consumption  = %4.3f \n',Cbar);
fprintf(' Lambda       = %4.3f \n\n',Lambdabar);

% SOLVE MODEL WRITING SOLUTION AS LINEAR FIRST ORDER DIFFERENCE EQUATIONS
%    A E_t[Z(t+1)] = B * Z(t), where Z(t)=(kt,at,yt,ct,lt,xt,lambdat)
% All variables here should be interpreted as "hats" in the notation of
% the notes. That is, as percentage deviations from their steady state
% values.
%
% Linearized equations
% 1)           0 = c(t) + lambda(t)
% 2)           0 = (1+1/nu)*l(t) - lambda(t) - y(t)
% 3)           0 = y(t) - A(t) - alpha*k(t) - (1-alpha)*l(t)
% 4)           0 = Ybar*y(t) - Cbar*c(t) - Xbar*x(t)
% 5) E_t[k(t+1)] = (1-delta) k(t) + delta x(t)
% 6) E_t[lambda(t+1) + beta*alpha*(Ybar/Kbar)*(y(t+1)-k(t+1))] = lambda(t)
% 7) E_t[A(t+1)] = rho*A(t)

%     -------------------
% Matrix A (called AA)
AA = zeros(7,7);

% Equation 5:
AA(5,1) = 1;                        % k(t+1)

% Equation 6:
AA(6,1) = -beta*alpha*Ybar/Kbar;    % k(t+1)
AA(6,3) =  beta*alpha*Ybar/Kbar;    % y(t+1)
AA(6,7) = 1;                        % lambda(t+1)

% Equation 7:
AA(7,2) = 1;    % A(t+1)

%     -------------------
% Matrix B (called BB)
BB = zeros(7,7);

% Equation 1:
BB(1,4) = 1;    % c(t)
BB(1,7) = 1;    % lambda(t)

% Equation 2:
BB(2,3) = -1;       % y(t)
BB(2,5) = 1+1/nu;   % l(t)
BB(2,7) = -1;       % lambda(t)

% Equation 3:
BB(3,1) = -alpha;       % k(t)
BB(3,2) = -1;           % A(t)
BB(3,3) = 1;            % y(t)
BB(3,5) = -(1-alpha);   % l(t)

% Equation 4:
BB(4,3) = Ybar;     % y(t)
BB(4,4) = -Cbar;    % c(t)
BB(4,6) = -Xbar;    % x(t)

% Equation 5:
BB(5,1) = 1-delta;  % k(t)
BB(5,6) = delta;    % x(t)

% Equation 6:
BB(6,7) = 1;        % lambda(t)

% Equation 7:
BB(7,2) = rho;      % A(t)

% Solve for policy functions using the QZ decomposition
[F,P] = solab(AA,BB,2);     % The "2" here means that there are "2" state variables: k(t) and A(t)

% Display the solution
fprintf( 'Policy functions of the calibrated RBC model \n' )
fprintf( '-------------------------------------------- \n\n' )

fprintf('Control variables policy functions. Matrix F \n')
disp(F)

fprintf('\n State variables policy functions. Matrix P \n')
disp(P)

VARNAMES = {'Capital '   ;
            'TFP'        ;...
            'Output'     ;...
            'Consumption';...
            'Labor'      ;...
            'Investment' ;...
            '\lambda'   };
       
% ------------------------------------------------------------------------
% COMPUTE IMPULSE RESPONSES
% There is more than one way of doing this. What follows is an easy one,
% but not the most general.

T = 40;     % T periods for impulse response

% -------------------------------------
% IMPULSE RESPONSE 1% DEVIATION TO PRODUCTIVITY
IRk_a = zeros(T+1,1); % IR for capital
IRa_a = zeros(T+1,1); % IR for technology
IRy_a = zeros(T,1);   % IR for output
IRc_a = zeros(T,1);   % IR for consumption
IRl_a = zeros(T,1);   % IR for labor
IRx_a = zeros(T,1);   % IR for investment

% Shocks to technology:
eps = zeros(T,1);
eps(1) = sigma;

% Compute impulse responses using simulation
for t=1:T
    IRk_a(t+1) = IRk_a(t)*P(1,1) + IRa_a(t)*P(1,2);
    IRa_a(t+1) = IRk_a(t)*P(2,1) + IRa_a(t)*P(2,2) + eps(t);
    IRy_a(t)   = IRk_a(t)*F(1,1) + IRa_a(t)*F(1,2);
    IRc_a(t)   = IRk_a(t)*F(2,1) + IRa_a(t)*F(2,2);
    IRl_a(t)   = IRk_a(t)*F(3,1) + IRa_a(t)*F(3,2);
    IRx_a(t)   = IRk_a(t)*F(4,1) + IRa_a(t)*F(4,2);
end

% Plot impulse response to 1 std deviation increase in productivity
figure
plot(0:T-1,[IRk_a(1:T) IRa_a(1:T) IRy_a(1:T) IRc_a(1:T) IRl_a(1:T) IRx_a(1:T)],'Linewidth',2);
legend(VARNAMES(1:6))
legend boxoff
title('Impulse responses to 1 std deviation increase in productiviy','Fontsize',12)
grid on

% --------------------------------------
% IMPULSE RESPONSE TO 1% DEVIATION INCREASE IN CAPITAL
IRk_k = zeros(T+1,1); % IR for capital
IRa_k = zeros(T+1,1); % IR for technology
IRy_k = zeros(T,1);   % IR for output
IRc_k = zeros(T,1);   % IR for consumption
IRl_k = zeros(T,1);   % IR for labor
IRx_k = zeros(T,1);   % IR for investment

% Shock to capital:
shock_capital    = zeros(T,1);
shock_capital(1) = 1;
eps = zeros(T,1);   % No shocks to technology

% Compute impulse responses using iteration
for t=1:T
    IRk_k(t+1) = IRk_k(t)*P(1,1) + IRa_k(t)*P(1,2) + shock_capital(t);
    IRa_k(t+1) = IRk_k(t)*P(2,1) + IRa_k(t)*P(2,2) + eps(t);
    IRy_k(t)   = IRk_k(t)*F(1,1) + IRa_k(t)*F(1,2);
    IRc_k(t)   = IRk_k(t)*F(2,1) + IRa_k(t)*F(2,2);
    IRl_k(t)   = IRk_k(t)*F(3,1) + IRa_k(t)*F(3,2);
    IRx_k(t)   = IRk_k(t)*F(4,1) + IRa_k(t)*F(4,2);
end
figure
plot(0:T-1,[IRk_k(1:T) IRa_k(1:T) IRy_k(1:T) IRc_k(1:T) IRl_k(1:T) IRx_k(1:T)],'Linewidth',2);
legend(VARNAMES(1:6))
legend boxoff
title('Impulse responses to 1 percent increase in stock of capital','Fontsize',12)
grid on

% -------------------------------------------------------------------------
% NOW PERFORM A SIMULATION OF THE MODEL DRAWING RANDOM SHOCKS
T  = 100000;     % Very long time series
Tp = 150;        % Periods to plot

% TO STORE TIME SERIES
k_sim = zeros(T+1,1); % capital
a_sim = zeros(T+1,1); % technology
y_sim = zeros(T,1);   % output
c_sim = zeros(T,1);   % consumption
l_sim = zeros(T,1);   % labor
x_sim = zeros(T,1);   % investment

% Set always same realization for random number generator
rng(1);

% Shocks to technology:
eps = (sigma/100)*randn(T,1);   %Multiplico por sigma/100 porque sigma esta en porcentaje y porque randn() da shocks normales con media 0 y varianza 1.

% Compute impulse responses using iteration
for t=1:T
    k_sim(t+1) = k_sim(t)*P(1,1) + a_sim(t)*P(1,2);
    a_sim(t+1) = k_sim(t)*P(2,1) + a_sim(t)*P(2,2) + eps(t);
    y_sim(t)   = k_sim(t)*F(1,1) + a_sim(t)*F(1,2);
    c_sim(t)   = k_sim(t)*F(2,1) + a_sim(t)*F(2,2);
    l_sim(t)   = k_sim(t)*F(3,1) + a_sim(t)*F(3,2);
    x_sim(t)   = k_sim(t)*F(4,1) + a_sim(t)*F(4,2);
end

% All simulated series together (including average labor productivity)
series = [k_sim(1:T) a_sim(1:T) y_sim c_sim l_sim x_sim y_sim-l_sim];

NAMES = [VARNAMES(1:6);{'Labor Prod.'}];

% Plot raw series delivered by the model
figure
plot(1:Tp,series(1:Tp,:),'Linewidth',2);
legend(NAMES,'Location','Best')
legend boxoff
title('Simulation of RBC model','Fontsize',12)
grid on

series_hp = hpfilter(series,1600);
figure
plot(1:Tp,series_hp(1:Tp,:),'Linewidth',2);
legend(NAMES,'Location','Best')
legend boxoff
title('Simulation of RBC model: HP-filtered series','Fontsize',12)
grid on

% Compute summary statistics of simulated data
volatility   = std(series_hp);       % Standard deviation series
correlations = corrcoef(series_hp);  % Contemporaneous correlation all series

fprintf('\n Standard deviation of percentage departure from trend (HP-filtered) \n')
fprintf(' ------------------------------------------------------------------\n')
fprintf(' Output            : %5.3f \n',100*volatility(3));
fprintf(' Consumption       : %5.3f \n',100*volatility(4));
fprintf(' Investment        : %5.3f \n',100*volatility(6));
fprintf(' Capital stock     : %5.3f \n',100*volatility(1));
fprintf(' Hours             : %5.3f \n',100*volatility(5));
fprintf(' Labor productivity: %5.3f \n',100*volatility(7));
fprintf(' \n\n ')
fprintf(' Contemporaneous correlation with output (HP-filtered) \n')
fprintf(' ------------------------------------------------------\n')
fprintf(' Consumption       : %5.2f \n',correlations(3,4));
fprintf(' Investment        : %5.2f \n',correlations(3,6));
fprintf(' Capital stock     : %5.2f \n',correlations(3,1));
fprintf(' Hours             : %5.2f \n',correlations(3,5));
fprintf(' Labor productivity: %5.2f \n\n',correlations(3,7));

% -------------------------------------------------------------------------
% COMPUTE POPULATION MOMENTS USING THE FORMULAS IN THE NOTES

% State variables X = [K(t) A(t)]

% 1. Compute covariance matrix of X (log-deviation from steady state)

% Method 1: Using kronecker product:
ETA = [0 ; sigma/100];
SigEps = ETA*ETA';

disp('Unconditional variance-covariance matrx of the state vector [k(t) a(t)]:');
SigXVec = (eye(4)-kron(P,P))\reshape(SigEps,numel(SigEps),1);
SigX = reshape(SigXVec,2,2);
disp('Using Kronecker product:')
disp(SigX)

% Method 2: iterative algorithm
Sig0 = eye(2);
error = 1;
while error > 1e-7;
    Sig1 = P*Sig0*P' + SigEps;
    error = norm(Sig1-Sig0);
    Sig0=Sig1;
end
disp('Using iterative procedure:')
disp(Sig1)

% 2. Autocovariances of X
nTau = 200;
SigX_tau = zeros(size(SigX,1),size(SigX,2),nTau+1);
SigX_tau(:,:,1) = SigX;
for j=1:nTau
    SigX_tau(:,:,j+1) = P*SigX_tau(:,:,j);
end

% 3. Autocorrelation of capital (divido autocovarianzas del capital x
% varianza)
autocorr_k = squeeze(SigX_tau(1,1,:))/SigX_tau(1,1,1);  
% Para ver que hace el comando squeeze, luego de correr el programa pongan
% en matlab el comando SigX_tau(1,1,:) y luego squeeze(SigX_tau(1,1,:)).
figure
plot(0:nTau,autocorr_k,'Linewidth',2);
title('Autocorrelation function of capital','Fontsize',14)
xlabel('Lag-length \tau')
ylabel('Autocorrelation function')
grid on

% 4. Second moments of the control variables
SigY_tau = zeros(size(F,1),size(F,1),nTau+1);
for j=1:nTau+1
    SigY_tau(:,:,j) = F*SigX_tau(:,:,j)*F';
end

% 5. Autocorrelations of some control variables
autocorr_y = squeeze(SigY_tau(1,1,:))/SigY_tau(1,1,1);   % Output
autocorr_c = squeeze(SigY_tau(2,2,:))/SigY_tau(2,2,1);   % Consumption
autocorr_l = squeeze(SigY_tau(3,3,:))/SigY_tau(3,3,1);   % Labor
autocorr_x = squeeze(SigY_tau(4,4,:))/SigY_tau(4,4,1);   % Investment

figure
plot(0:nTau,autocorr_y,0:nTau,autocorr_c,0:nTau,autocorr_l,0:nTau,autocorr_x,'Linewidth',2)
title('Autocorrelation function of key variables','Fontsize',14)
xlabel('Lag-length \tau')
ylabel('Autocorrelation function')
legend('Output','Consumption','Labor','Investment');
legend boxoff
grid on

% -------------------------------------------
% SPECTRAL DENSITIES
% Spectral density of state variables X(t)

ngrid_ome = 100;    % Number of grid points between 0 and pi
Ip = eye(size(P));

ome = linspace(0,pi/2,ngrid_ome);
Spectral_X = zeros(size(SigX,1),size(SigX,1),ngrid_ome);  % Tercera dimension es el valor de omega donde evaluamos la spectral density
for j=1:ngrid_ome;
    Spectral_X(:,:,j) =  inv( Ip - P*exp(-1i*ome(j))) * SigEps * inv( Ip - P'*exp(1i*ome(j)));
end

spectral_k = real(squeeze(Spectral_X(1,1,:)));
spectral_a = real(squeeze(Spectral_X(2,2,:)));

figure
plot(ome,spectral_k,'Linewidth',2)
title('Spectral density of capital','Fontsize',12);
xlabel('\omega');
axis([0 ome(end) -inf +inf])
grid on

% Spectral density control variables Y
Spectral_Y = zeros(size(F,1),size(F,1),ngrid_ome);
for j=1:ngrid_ome
    Spectral_Y(:,:,j) = F*Spectral_X(:,:,j)*F';
end

spectral_y = real(squeeze(Spectral_Y(1,1,:)));
spectral_c = real(squeeze(Spectral_Y(2,2,:)));
spectral_l = real(squeeze(Spectral_Y(3,3,:)));
spectral_x = real(squeeze(Spectral_Y(4,4,:)));

figure
subplot(2,2,1)
plot(ome,spectral_y,'Linewidth',1.5);
title('Spectral density of output','Fontsize',12);
xlabel('\omega');
axis([0 ome(end) -inf +inf])
grid on

subplot(2,2,2)
plot(ome,spectral_c,'Linewidth',1.5);
title('Spectral density of consumption','Fontsize',12);
xlabel('\omega');
axis([0 ome(end) -inf +inf])
grid on

subplot(2,2,3)
plot(ome,spectral_l,'Linewidth',1.5);
title('Spectral density of labor','Fontsize',12);
xlabel('\omega');
axis([0 ome(end) -inf +inf])
grid on

subplot(2,2,4)
plot(ome,spectral_x,'Linewidth',1.5);
title('Spectral density of investment','Fontsize',12);
xlabel('\omega');
axis([0 ome(end) -inf +inf])
grid on

