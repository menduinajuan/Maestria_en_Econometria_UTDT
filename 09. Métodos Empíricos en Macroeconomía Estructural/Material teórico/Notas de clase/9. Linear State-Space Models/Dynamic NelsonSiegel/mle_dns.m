function [ loglik, param_out, unobserved, fcasterror, P_TT, StdErr ] = mle_dns( param_in, data, info )

tau   = info.tau;
nvar  = size(data,1);
T = info.nobs;
Id3 = eye(3);
unobserved = zeros(3,T);
fcasterror = zeros(nvar,T);

if info.estimate>0      % If do estimation:
      
    % If perform simulated annealing:
    if info.do_anneal > 0;
        fprintf('\n Optimizing using Simulated Annealing\n') 
        % Options for annealing program:
        options_sa.Verbosity  = 2;       % Show intermediate information
        options_sa.InitTemp   = 1;       % Initial temperature
        options_sa.StopTemp   = 1e-3;    % Stop temperature criterium
        [ param_out, loglik ] = anneal( @log_likelihood, param_in, options_sa );
        param_in = param_out;
    end
    
    % Check if do Nelder-Mead simplex method
    if info.do_simplex > 0
        fprintf('\n Optimizing using Nelder-Mead Simplex Method\n')
        % Options for fminsearch
        options_fms = optimset('Display','iter','MaxFunEvals',3000,'Maxiter',3000);
        [ param_out, loglik ] = fminsearch( @log_likelihood, param_in, options_fms );
        param_in = param_out;
    end

    % Check if do quasi-newton optimization
    if info.do_qnewton >0
        
        if info.qn_type == 1    % use matlab "fminunc"

            % Options for fminunc:
            option_fmu = optimset('Largescale','off','Display','iter','MaxFunEvals',15000, ...
                                  'Maxiter',400,'TolX',1e-6,'TolFun',1e-6);
            fprintf('\n Optimizing using Quasi-Newton Method: fminunc \n')
            [ param_out, loglik ] = fminunc( @log_likelihood, param_in, option_fmu );
        
        elseif info.qn_type==2   % use McGrattan's "uncmin"
        
            fprintf('\n Optimizing using Quasi-Newton Method: uncmin \n')
            [ param_out, loglik] = uncmin( param_in, @log_likelihood );
        
        else
            fprintf('\n Wrong input in info.qn_type: you must choose 1 or 2. \n')
            error(' ')
        end
    end
       
else  % Do not perform estimation (good for graphs, computing standard errors, etc)
   loglik    = log_likelihood( param_in ); 
   param_out = param_in;
end
        
% Compute asymptotic standard errors using the (numerical) hessian of the
% log-likelihood function:
if info.do_stderr > 0
    fprintf('\n Computing asymptotic standard errors. This takes some time... ')
    Hess = fdhess( @log_likelihood, param_out, 1, loglik );     % Hessian of the log-likelihood function
    IHess = inv(Hess);                                          % Inverse of hessian
    Jacob = fdjacob( @transform_dns, param_out, 1 );            % Jacobian of the transformation
    StdErr = sqrt( diag( Jacob*IHess*Jacob' ) ); %#ok<MINV>     % Standard errors of true parameters using the Delta Method
    fprintf('Done. \n ')
else
    StdErr = -99*ones(length(param_out),1);
end

% NESTED FUNCTION: Likelihood function.
    function loglik = log_likelihood( param )

        % System:
        % x[t] = mu + F*x[t-1] + w[t]   w ~ N( 0, Q )
        % y[t] = B*x[t] + v[t]          v ~ N( 0, R )
        
        % Transform parameters:
        param_t = transform_dns( param );
        
        lambda = param_t(1);
        mu     = param_t(2:4);
                
        F = zeros(3);
        F(1,1:3) = param_t(5:7);
        F(2,1:3) = param_t(8:10);
        F(3,1:3) = param_t(11:13);
        
        Q = zeros(3);
        Q(1,1)  = param_t(14);
        Q(2,1:2)= param_t(15:16);
        Q(3,1:3)= param_t(17:19);
        Q(1,2:3)= Q(2:3,1)';
        Q(2,3)  = Q(3,2);
        
        R = diag(param_t(20:36));
                
        % Create H, matrix on lagged values of state equation
        H      = ones(nvar,3);
        H(:,2) = ( 1 - exp(-lambda*tau) )./ (lambda*tau);
        H(:,3) = H(:,2) - exp(-lambda*tau);
        
        % Compute penalty term on matrices F (to force stationary if needed)
        lambdamax = max( abs( eig( F ) ) );
        penF = 10000 * max( (lambdamax - 0.995 ),0 ).^2;
        if lambdamax>1; 
            F = F/( lambdamax + 1e-3 ); 
        end
                
        % Initialize filter:
        X_LL = ( eye(3) - F ) \ mu;
        P_LL = reshape( (eye(9)-kron(F,F))\Q(:),3,3);
        
        loglik = 0;    % Initialize log-likelihood
        for t=1:T   % Kalman Recursion
            
            % Prediction step:
            X_TL = mu + F*X_LL;
            P_TL = F*P_LL*F'+Q;
            
            % Update step:
            a = data(:,t)-H*X_TL;                     % Forecast error
            S = H * P_TL*H' + R;                      % Covariance of y(t)-E(y(t)|x_hat(t),Y(t-1))
            K = P_TL*H'/S;                            % Kalman Gain
            X_TT = X_TL + K*a;                        % Update unobserved state
            
            ImKH = (Id3-K*H);
            P_TT = ImKH*P_TL;                         % Update covariance of X. This update sometimes has numerical problems. If so, use the update below:            
            %P_TT = ImKH*P_TL*ImKH'+K*R*K';           % Update covar of X with better numerical properties
            
            X_LL = X_TT;
            P_LL = P_TT;
            
            unobserved(:,t) = X_TT;
            fcasterror(:,t) = a;
            
            loglik = loglik + log(det(S)) + a'*(S\a);    %Update (negative) of log-likelihood
        end
        % Adjust (negative of) loglikelihood with the parameter and penalty
        % term
        loglik = 0.5*(loglik + T*nvar*log(2*pi)) + penF; %(minus) log-likelihood up to a constant plus penalty
    end

end