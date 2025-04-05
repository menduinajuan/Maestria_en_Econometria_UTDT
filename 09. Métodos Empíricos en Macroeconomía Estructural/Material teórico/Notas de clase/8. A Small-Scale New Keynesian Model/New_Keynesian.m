clear; close all;
clc;
fprintf(' SOLVING NEW KEYNESIAN MODEL WITH ROTEMBERG PRICE ADJUSTMENT COSTS \n')
fprintf(' ================================================================= \n\n')

% ------------------------------------------------------------------------
% PARAMETER VALUES
% ================

% PREFERENCES
beta  = 0.95;   % Discount factor
nu    = 1;      % Reciprocal of Frisch elasticity of labor supply
eta   = 1;      % Constant multiplying labor disutility
sigma = 2;      % Risk aversion coefficient
psi   = 0.01;   % Constant multiplying money in preferences
xsi   = 2;      % Parameter in exponent of money demand

% -------------------------
% PRODUCTION SIDE OF ECONOMY:
theta = 6;      % Elasticity of substitution / Demand elasticity of intermediate inputs
omega = 25;     % Parameter of quadratic price adjustment cost in intermediate good firms

% -------------------------
% MONETARY POLICY RULE
inflbar = 1;     % Steady state inflation rate
rho_R   = 0.5;   % Smoothing parameter Taylor rule

% Reaction of target rate to inflation and output
phi_infl = 1.5;  % Reaction to inflation
phi_y    = 0.25;   % Reaction to output

% -------------------------
% SHOCKS
rho_A  = 0.95;  % Persistence technology shock
sig_A  = 0.01;  % Standard deviation technology shock

rho_v  = 0.95;   % Persistence interest rate shock
sig_v  = 0.01; % Standard deviation monetary policy shock


kappa = (theta-1)/(inflbar^2*omega);  % Parameter Phillips curve

% ------------------------------------------------------------------------
% STEADY STATE
% ============
Rbar = inflbar/beta;
ybar = ((1/eta)*((theta-1)/theta) )^(1/(sigma+nu));
mbar = (psi*ybar^sigma * Rbar/(Rbar-1) )^( 1/xsi );
Abar = 1;
vbar = 0;

% DISPLAY CALIBRATED PARAMETERS
disp(' CALIBRATED PARAMETERS')
disp(' ---------------------')
fprintf(' beta     = %4.3f \n',beta);
fprintf(' eta      = %4.3f \n',eta);
fprintf(' nu       = %4.3f \n',nu);
fprintf(' sigma    = %4.3f \n',sigma);
fprintf(' psi      = %4.3f \n',psi);
fprintf(' xsi      = %4.3f \n',xsi);
fprintf(' theta    = %4.3f \n',theta);
fprintf(' phi      = %4.3f \n',omega);
fprintf(' rho_R    = %4.3f \n',rho_R);
fprintf(' phi_infl = %4.3f \n',phi_infl);
fprintf(' phi_y    = %4.3f \n',phi_y);
fprintf(' rho_A    = %4.3f \n',rho_A);
fprintf(' sig_A    = %4.3f \n',sig_A);
fprintf(' rho_v    = %4.3f \n',rho_v);
fprintf(' sig_v    = %4.3f \n',sig_v);
fprintf(' infl_bar = %4.3f \n\n',inflbar);


disp(' STEADY STATE VALUES')
disp(' -------------------')
fprintf(' Output       = %4.3f \n',ybar);
fprintf(' Interest rate= %4.3f \n',Rbar);
fprintf(' M/P          = %4.3f \n\n',mbar);


% SOLVE MODEL USING PAUL KLEIN'S SOLAB FUNCTION 
%    A E_t S(t+1) = B * S(t), where S(t)=(R(t-1),A(t),eps_R(t),y(t),infl(t))
% All variables here should be interpreted as "hats" in the notation of
% the note. That is, as percentage deviations from their steady states
%
% Linearized equations
% 1) E_t[ y(t+1)+(1/sigma)*(infl(t+1)-R(t)) ] = y(t)
% 2) beta*E_t[ infl(t+1) ] = infl(t) - kappa*[(sigma+nu)*y(t)-(1+nu)*A(t)]
% 3) E_t[ R(t) ] = (1-rho_R)*(phi_infl*infl(t) + phi_y*y(t)] + rho_R*R(t-1) + v(t)
% 4) E_t[A(t+1)] = rho_A*A(t)
% 5) E_t[v(t+1)] = rho_v*v(t)

%     -------------------
% Matrix A (called AA)
AA = zeros(5,5);

% Equation 1:
AA(1,1) = -1/sigma;    % R(t)
AA(1,4) = 1;           % y(t)
AA(1,5) = 1/sigma;     % infl(t+1)

% Equation 2:
AA(2,5) = beta;        % infl(t+1)

% Equation 3:
AA(3,1) = 1;           % R(t)

% Equation 4:
AA(4,2) = 1;           % A(t+1)

% Equation 5:
AA(5,3) = 1;           % v(t+1)

%     -------------------
% Matrix B (called BB)
BB = zeros(5,5);

% Equation 1:
BB(1,4) = 1;    % y(t)

% Equation 2:
BB(2,2) =  kappa*(1+nu);        % A(t)       
BB(2,4) = -kappa*(nu+sigma);    % y(t)
BB(2,5) = 1;                    % infl(t)

% Equation 3:
BB(3,1) = rho_R;                % R(t)
BB(3,3) = 1;                    % v(t)
BB(3,4) = (1-rho_R)*phi_y;      % y(t)   
BB(3,5) = (1-rho_R)*phi_infl;   % infl(t)

% Equation 4:
BB(4,2) = rho_A;                % A(t)

% Equation 5:
BB(5,3) = rho_v;                % v(t)

% Solve for policy functions using Paul Klein's solab.m function:
[F,P] = solab_ch(AA,BB,3);     % The "3" here means that there are "3" state variables: R(t-1), A(t), and v(t)
%[F,P] = solab(AA,BB,3);

% Display the solution
fprintf( 'Policy functions of the New Keynesian model \n' )
fprintf( '------------------------------------------- \n\n' )

fprintf('Control variables policy functions. Matrix F \n')
disp(F)

fprintf('\n State variables policy functions. Matrix P \n')
disp(P)

VARNAMES = ['R         '
            'A         '
            'v         '
            'Output    '
            'Inflation '];
        
% ------------------------------------------------------------------------
% COMPUTE IMPULSE RESPONSES
% There is more than one way of doing this. What follows is the easiest
% one.

T = 40;     % T periods for impulse response

% -------------------------------------
% IMPULSE RESPONSE 1% DEVIATION TO PRODUCTIVITY
IRR_a    = zeros(T+1,1); % IR for interest rate
IRA_a    = zeros(T+1,1); % IR for technology
IRV_a    = zeros(T+1,1); % IR for monetary policy shock
IRY_a    = zeros(T,1);   % IR for output
IRINFL_a = zeros(T,1);   % IR for inflation

% Shocks to technology:
eps = zeros(T,1);
eps(1) = 100*sig_A;

% Compute impulse responses using iteration
for t=1:T
    % Evolution of states:
    IRR_a(t+1) = IRR_a(t)*P(1,1) + IRA_a(t)*P(1,2) + IRV_a(t)*P(1,3);
    IRA_a(t+1) = IRR_a(t)*P(2,1) + IRA_a(t)*P(2,2) + IRV_a(t)*P(2,3) + eps(t);
    IRV_a(t+1) = IRR_a(t)*P(3,1) + IRA_a(t)*P(3,2) + IRV_a(t)*P(3,3);
    % Evolution of controls:
    IRY_a(t)   = IRR_a(t)*F(1,1) + IRA_a(t)*F(1,2) + IRV_a(t)*F(1,3);
    IRINFL_a(t)= IRR_a(t)*F(2,1) + IRA_a(t)*F(2,2) + IRV_a(t)*F(2,3);
end

% Plot impulse response to 1 std deviation increase in productivity
figure
plot(0:T-1,[IRR_a(1:T) IRA_a(1:T) IRV_a(1:T) IRY_a(1:T) IRINFL_a(1:T)],'Linewidth',2);
legend(VARNAMES(1:5,:))
legend boxoff
title('Impulse responses to 1 std deviation increase in productiviy','Fontsize',12)
grid on

% --------------------------------------
% IMPULSE RESPONSE 1% IN MONETARY POLICY SHOCK
IRR_v    = zeros(T+1,1); % IR for interst rate
IRA_v    = zeros(T+1,1); % IR for technology
IRV_v    = zeros(T+1,1); % IR for monetary policy shock
IRY_v    = zeros(T,1);   % IR for output
IRINFL_v = zeros(T,1);   % IR for inflation

% Shocks to policy rule:
eps = zeros(T,1);
eps(1) = sig_v;

% Compute impulse responses using iteration
for t=1:T
    IRR_v(t+1) = IRR_v(t)*P(1,1) + IRA_v(t)*P(1,2) + IRV_v(t)*P(1,3);
    IRA_v(t+1) = IRR_v(t)*P(2,1) + IRA_v(t)*P(2,2) + IRV_v(t)*P(2,3);
    IRV_v(t+1) = IRR_v(t)*P(3,1) + IRA_v(t)*P(3,2) + IRV_v(t)*P(3,3) + eps(t);
    IRY_v(t)   = IRR_v(t)*F(1,1) + IRA_v(t)*F(1,2) + IRV_v(t)*F(1,3);
    IRINFL_v(t)= IRR_v(t)*F(2,1) + IRA_v(t)*F(2,2) + IRV_v(t)*F(2,3);
end

% Plot impulse response to 1% increase in productivity
figure
plot(0:T-1,[IRR_v(1:T) IRA_v(1:T) IRV_v(1:T) IRY_v(1:T) IRINFL_v(1:T)],'Linewidth',2);
legend(VARNAMES(1:5,:))
legend boxoff
title('Impulse responses to 1 std deviation increase in monetary policy shock','Fontsize',12)
grid on
