function [F,P] =solve_model_RBC(theta)

% This function solve the RBC model using a vector of parameters in theta

beta = theta(1);
eta  = theta(2);
nu   = theta(3);
delta= theta(4);
alpha= theta(5);
rho  = theta(6);
sigma= theta(7);

% FIND STEADY STATE GIVEN PARAMETERS

% Steady state ratios
y_k = (1/beta-(1-delta))/alpha;
c_k = y_k-delta;
x_k = delta;
l_k = y_k^(1/(1-alpha));

% Steady state levels
Lbar = ((1-alpha)*y_k / (eta*c_k) )^(1/(1+1/nu));
Kbar = Lbar/l_k;
Cbar = c_k*Kbar;
Ybar = y_k*Kbar;
Xbar = x_k*Kbar;
Abar = 1;
Lambar = 1/Cbar;

% SOLVE MODEL WRITING SOLUTION AS LINEAR FIRST ORDER DIFFERENCE EQUATIONS
%    A E_t[Z(t+1)] = B * Z(t), where Z(t)=(kt,at,yt,ct,lt,xt,lambdat)
% All variables here should be interpreted as ''hats'' in the notation of
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

