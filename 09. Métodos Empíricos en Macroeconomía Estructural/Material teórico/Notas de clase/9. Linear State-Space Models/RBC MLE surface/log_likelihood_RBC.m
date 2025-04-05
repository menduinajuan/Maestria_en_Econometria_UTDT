function [ loglik, x_hat ] = log_likelihood_RBC( theta, sim_data, iobs)

% theta are the parameters
% data is the array with the simulated data
% iobs: integer 1 through 4 identifying the observable used to evaluate the likelihood

% Solve model given parameters
[FF,PP] = solve_model_RBC(theta);

% Now use kalman filter routine
Y = sim_data(:,iobs)';   

A = PP;             % Matrix in state equation
G = FF(iobs,:);     % Matrix (vector) in observation equation

sigma = theta(7);
Q = [0 0; 0 (sigma/100)^2];	% Covariance matrix shocks in state equation
R = 0;                      % Covariance matrix shocks in observation equation

x0 = zeros(2,1);            % Initial condition for the state (unconditional mean)

[x_hat, loglik ] = kalman_filter( A, G, Q, R, Y, x0 );

end