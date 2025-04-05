function [ loglik, param_out, unobserved ] = mle_fama_gibbons( param_in, data )

T          = length(data);

option_fmu = optimset('Largescale','off','Display','iter','MaxFunEvals',15000,...
                       'Maxiter',100,'TolX',1e-12,'Tolfun',1e-8);

fprintf('\n Optimizing using Quasi-Newton Method: fminunc \n')
[ param_out, loglik ] = fminunc( @log_likelihood, param_in, option_fmu );
        
loglik = -loglik;   % Put it back in right units

fprintf('Done. \n ')

% NESTED FUNCTION: Likelihood function.
    function loglik = log_likelihood( param )
        
        % Parameters:
        mu  = param(1);
        ome = param(2);
        sx  = param(3);
        sy  = param(4);
        
        % Transform ome to phi:
        phi = 1/(1+exp(-ome));
        
        % Transform data
        Y = data' - mu;      % Demeaned ex-post real rates (time series in rows)
        
        [unobserved, loglik ] = kalman_filter( phi, 1, sx^2, sy^2, Y, 0 );
        
        loglik = -loglik;   % Because we are minimizing
        
    end

end