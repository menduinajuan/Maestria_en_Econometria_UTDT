
clear; close all;
fprintf(' LIKELIHOOD SURFACE BASIC RBC MODEL \n')
fprintf(' ================================== \n\n')

T = 200;    % Number of periods to simulate the model

%% STEP 1: calibrate and simulate the model

%----------
% CALIBRATION

% Frisch elasticity of labor supply
nu    = 1;          % This is usually taken from other studies

% Target values to match steady state quantities
Rbar  = 1.01;       % One percent real interest per quarter
Lbar  = 1/3;        % Steady state labor: a third of total available time
XYbar = 0.21;       % Average (broad) investment / output ratio

% Calibrated parameter values and steady state quantities
alpha  = 1/3;                           % Capital share in output
beta   = 1/Rbar;                        % Discount factor
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
sigma = 1.019;  % standard deviation technology shock. Units: Percent (chosen to match volatility of output in data approx 1.76% from McCallum

% DISPLAY CALIBRATED PARAMETERS
disp(' CALIBRATED PARAMETERS')
disp(' ---------------------')
fprintf(' beta  = %4.3f \n',beta);
fprintf(' eta   = %4.3f \n',eta);
fprintf(' nu    = %4.3f \n',nu);
fprintf(' delta = %4.3f \n',delta);
fprintf(' alpha = %4.3f \n',alpha);
fprintf(' rho   = %4.3f \n',rho);
fprintf(' sigma = %4.3f \n\n',sigma);

disp(' STEADY STATE VALUES')
disp(' -------------------')
fprintf(' Output       = %4.3f \n',Ybar);
fprintf(' Capital      = %4.3f \n',Kbar);
fprintf(' Investment   = %4.3f \n',Xbar);
fprintf(' Labor        = %4.3f \n',Lbar);
fprintf(' Consumption  = %4.3f \n',Cbar);
fprintf(' Lambda       = %4.3f \n\n',Lambdabar);

% STORE PARAMETERS IN VECTOR THETA
theta = [beta;eta;nu;delta;alpha;rho;sigma];

% Solve model given calibrated parameters and simulate data
[F,P] = solve_model_RBC(theta);

% Simulate data from this model

k_sim = zeros(T+1,1); % capital
a_sim = zeros(T+1,1); % technology
y_sim = zeros(T,1);   % output
c_sim = zeros(T,1);   % consumption
l_sim = zeros(T,1);   % labor
x_sim = zeros(T,1);   % investment

% Set always same realization for random number generator
rng(1);

% Shocks to technology:
eps = (sigma/100)*randn(T,1);

% Simulate economy
for t=1:T
    k_sim(t+1) = k_sim(t)*P(1,1) + a_sim(t)*P(1,2);
    a_sim(t+1) = k_sim(t)*P(2,1) + a_sim(t)*P(2,2) + eps(t);
    y_sim(t)   = k_sim(t)*F(1,1) + a_sim(t)*F(1,2);
    c_sim(t)   = k_sim(t)*F(2,1) + a_sim(t)*F(2,2);
    l_sim(t)   = k_sim(t)*F(3,1) + a_sim(t)*F(3,2);
    x_sim(t)   = k_sim(t)*F(4,1) + a_sim(t)*F(4,2);
end

% simulated data
sim_data = [y_sim c_sim l_sim x_sim k_sim(1:T) a_sim(1:T)];

%% STEP 2: Plot likelihood surface using different observables to evaluate the likelihood

% Model has 1 shock, so we can evaluate likelihood using only 1 observable!
% We try different possibilities and plot the likelihood surface

% Plot likelihood surface varying parameters beta and delta

igrid= 20;
beta_grid  = linspace(0.98, 0.999,igrid);
delta_grid = linspace(0.005, 0.04,igrid);

loglik_surface_y = zeros(igrid,igrid);
loglik_surface_c = zeros(igrid,igrid);
loglik_surface_l = zeros(igrid,igrid);
loglik_surface_x = zeros(igrid,igrid);

for ix = 1:igrid;
    for iz = 1:igrid;
        theta_new = [beta_grid(ix);eta;nu;delta_grid(iz);alpha;rho;sigma];
        
        iobs = 1;   % Use output
        [ loglik_surface_y(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);

        iobs = 2;   % Use consumption
        [ loglik_surface_c(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);

        iobs = 3;   % Use labor
        [ loglik_surface_l(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);

        iobs = 4;   % Use investment
        [ loglik_surface_x(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);
    end
end

 
%This is for the size of the figure
sz = [680 1000];
screensize = get(0,'ScreenSize');
xpos = ceil((screensize(3)-sz(2))/2); % Center figure on screen horizontally
ypos = ceil((screensize(4)-sz(1))/2); % Center figure on screen vertically

% Plot surface
[XX,YY] = meshgrid(beta_grid,delta_grid);

fig0 = figure('Color','white','PaperUnits','Inches','PaperOrientation','Landscape','Position',[xpos, ypos, sz(2), sz(1)]);

subplot(2,2,1)
surf(XX,YY,loglik_surface_y);
title('Likelihood surface using output');
xlabel('\beta');
ylabel('\delta');

subplot(2,2,2)
surf(XX,YY,loglik_surface_c);
title('Likelihood surface using consumption');
xlabel('\beta');
ylabel('\delta');

subplot(2,2,3)
surf(XX,YY,loglik_surface_l);
title('Likelihood surface using labor');
xlabel('\beta');
ylabel('\delta');

subplot(2,2,4)
surf(XX,YY,loglik_surface_x);
title('Likelihood surface using investment');
xlabel('\beta');
ylabel('\delta');

colormap(winter)

saveas(gcf,'loglike_surface_rbc_1','epsc');

%% PLOT CHANGING THE PARAMETERS nu and rho

igrid= 20;
nu_grid  = linspace(0.75,1.5,igrid);
rho_grid = linspace(0.90,0.99,igrid);

loglik_surface_y_2=zeros(igrid,igrid);
loglik_surface_c_2=zeros(igrid,igrid);
loglik_surface_l_2=zeros(igrid,igrid);
loglik_surface_x_2=zeros(igrid,igrid);

for ix = 1:igrid;
    for iz = 1:igrid;
        theta_new = [beta;eta;nu_grid(ix);delta;alpha;rho_grid(iz);sigma];
        
        iobs = 1;   % Use output
        [ loglik_surface_y_2(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs); 

        iobs = 2;   % Use consumption
        [ loglik_surface_c_2(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);

        iobs = 3;   % Use labor
        [ loglik_surface_l_2(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);

        iobs = 4;   % Use investment
        [ loglik_surface_x_2(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);
    end
end

% Plot surface
[XX,YY] = meshgrid(nu_grid,rho_grid);

figure('Color','white','PaperUnits','Inches','PaperOrientation','Landscape','Position',[xpos, ypos, sz(2), sz(1)]);

subplot(2,2,1)
surf(XX,YY,loglik_surface_y_2);
title('Likelihood surface using output');
xlabel('\nu');
ylabel('\rho');

subplot(2,2,2)
surf(XX,YY,loglik_surface_c_2);
title('Likelihood surface using consumption');
xlabel('\nu');
ylabel('\rho');

subplot(2,2,3)
surf(XX,YY,loglik_surface_l_2);
title('Likelihood surface using labor');
xlabel('\nu');
ylabel('\rho');

subplot(2,2,4)
surf(XX,YY,loglik_surface_x_2);
title('Likelihood surface using investment');
xlabel('\nu');
ylabel('\rho');

colormap(winter)

saveas(gcf,'loglike_surface_rbc_2','epsc');

%% CHANGE PARAMETERS alpha and sigma

igrid= 20;
alpha_grid = linspace(0.25,0.40,igrid);
sigma_grid = linspace(0.70,1.5 ,igrid);

loglik_surface_y_3=zeros(igrid,igrid);
loglik_surface_c_3=zeros(igrid,igrid);
loglik_surface_l_3=zeros(igrid,igrid);
loglik_surface_x_3=zeros(igrid,igrid);

for ix = 1:igrid;
    for iz = 1:igrid;
        theta_new = [beta;eta;nu;delta;alpha_grid(ix);rho;sigma_grid(iz)];
        
        iobs = 1;   % Use output
        [ loglik_surface_y_3(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs); 

        iobs = 2;   % Use consumption
        [ loglik_surface_c_3(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);

        iobs = 3;   % Use labor
        [ loglik_surface_l_3(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);

        iobs = 4;   % Use investment
        [ loglik_surface_x_3(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);
    end
end

% Plot surface
[XX,YY] = meshgrid(alpha_grid,sigma_grid );

figure('Color','white','PaperUnits','Inches','PaperOrientation','Landscape','Position',[xpos, ypos, sz(2), sz(1)]);

subplot(2,2,1)
surf(XX,YY,loglik_surface_y_3);
title('Likelihood surface using output');
xlabel('\alpha');
ylabel('\sigma');

subplot(2,2,2)
surf(XX,YY,loglik_surface_c_3);
title('Likelihood surface using consumption');
xlabel('\alpha');
ylabel('\sigma');

subplot(2,2,3)
surf(XX,YY,loglik_surface_l_3);
title('Likelihood surface using labor');
xlabel('\alpha');
ylabel('\sigma');

subplot(2,2,4)
surf(XX,YY,loglik_surface_x_3);
title('Likelihood surface using investment');
xlabel('\alpha');
ylabel('\sigma');

colormap(winter)

saveas(gcf,'loglike_surface_rbc_3','epsc');


%% CHANGE PARAMETERS nu and eta

igrid= 20;
nu_grid  = linspace(0.1,2.5,igrid);
eta_grid = linspace(7,9,igrid);

loglik_surface_y_4=zeros(igrid,igrid);
loglik_surface_c_4=zeros(igrid,igrid);
loglik_surface_l_4=zeros(igrid,igrid);
loglik_surface_x_4=zeros(igrid,igrid);

for ix = 1:igrid;
    for iz = 1:igrid;
        theta_new = [beta;eta_grid(iz);nu_grid(ix);delta;alpha;rho;sigma];
        
        iobs = 1;   % Use output
        [ loglik_surface_y_4(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs); 

        iobs = 2;   % Use consumption
        [ loglik_surface_c_4(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);

        iobs = 3;   % Use labor
        [ loglik_surface_l_4(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);

        iobs = 4;   % Use investment
        [ loglik_surface_x_4(ix,iz) ] = log_likelihood_RBC( theta_new, sim_data, iobs);
    end
end

% Plot surface
[XX,YY] = meshgrid(nu_grid,eta_grid );

figure('Color','white','PaperUnits','Inches','PaperOrientation','Landscape','Position',[xpos, ypos, sz(2), sz(1)]);

subplot(2,2,1)
surf(XX,YY,loglik_surface_y_4);
title('Likelihood surface using output');
xlabel('\nu');
ylabel('\eta');

subplot(2,2,2)
surf(XX,YY,loglik_surface_c_4);
title('Likelihood surface using consumption');
xlabel('\nu');
ylabel('\eta');

subplot(2,2,3)
surf(XX,YY,loglik_surface_l_4);
title('Likelihood surface using labor');
xlabel('\nu');
ylabel('\eta');

subplot(2,2,4)
surf(XX,YY,loglik_surface_x_4);
title('Likelihood surface using investment');
xlabel('\nu');
ylabel('\eta');

colormap(winter)

saveas(gcf,'loglike_surface_rbc_4','epsc');

