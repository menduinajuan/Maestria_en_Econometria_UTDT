function param_tran = transform_dns( param_in )
% This function transforms the "unconstrained" parameters in param_in into
% constrained parameters in param_tran.

    param_tran = param_in;
        
    % 1. Unconstrained parameter is log(lambda): recover lambda:
    param_tran(1) = exp(param_in(1));
    
    % 2. Unconstrained parameter is Cholesky decomposition of covariance of
    % state equation: recover the actual covariance matrix:
    Qc = zeros(3);                      
    Qc(1,1)  = param_in(14);
    Qc(2,1:2)= param_in(15:16);
    Qc(3,1:3)= param_in(17:19);
        
    Q = Qc*Qc';     % Variance covariance matrix
    
    % Export lower diagonal part of covariance matrix
    param_tran(14)    = Q(1,1);
    param_tran(15:16) = Q(2,1:2);
    param_tran(17:19) = Q(3,1:3);

    % 3. Elements of the covariance matrix of measurement errors. The
    % unconstrained parameters is abs(sqrt(var)). Recover actual parameters
    % by taking squares
    param_tran(20:36) = param_in(20:36).*param_in(20:36);   %square terms

end