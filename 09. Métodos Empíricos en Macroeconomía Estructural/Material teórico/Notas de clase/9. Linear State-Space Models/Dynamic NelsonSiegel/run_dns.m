% This program replicates the basic estimation of Diebold, , Rudebusch,
% and Aruoba (2006) "The macroeconomy and the yield curve: a dynamic latent
% factor approach." Journal of Econometrics.

clear; close all;
tic

% CREATE A STRUCTURE "info" WITH THE INFORMATION THAT I WILL PASS TO THE 
% OPTIMIZERS, LIKELIHOOD FUNCTION, AND OTHER ISSUES.

%   Estimate parameters?
info.estimate    = 1;   % >0 yes; =0 no
info.initval     = 0;   % >0 if use old estimate as initial guess, =0 otherwise
info.log_results = 0;   % >0 if log results in a txt file; =0 if not.

%   Optimization methods:
info.do_anneal   = 1; % >0 if do simulated annealing; =0 if not
info.do_simplex  = 1; % Do Nelder_Meade algorithm? >0 if yes, =0 if no
info.do_qnewton  = 1; % >0 if does quasi-newton optimization; =0 if no
info.qn_type     = 1; % Type of quasi-newton algorithm: =1 uses fminunc; =2 uses uncmin
                      % Note: if your type of optimization is not available, the program crashes.

info.do_stderr   = 1; % >0 if do asymptotic standard errors; =0 if no

info.plotfigs    = 1; % >0 if plot figures, =0 if not.

if info.log_results>0
    diary(['Log_Dynamic_Nelson_Siegel_',datestr(now,30),'.txt']) %Log results in txt file with date
end

fprintf('\n Date and Hour: %s.\n ', datestr(now))
fprintf('\n ESTIMATING UNOBSERVED COMPONENT MODEL OF THE YIELD CURVE \n ')
fprintf('-------------------------------------------------------- \n ')

% Load yields data:
load datosinf;

% Name of file to save estimates and other useful stuff
namefile = 'estimates_dynamic_nelson_siegel.mat';

% Set initial and final dates of sample: (T=length(datosinf) is full sample:
T0 = 25;                % First observation to use
T  = length(datosinf);  % Last observation to use

% Put relevant data in matrix yy
yy = datosinf(T0:T,:);

% Create array with date indices for plotting:
t0 = 1970 + (1/12)*(T0-1);  % initial date
t1 = 1970 + (1/12)*(T-1);   % final date
time = ( t0 : 1/12 : t1 )'; % This is an array with the dates

%plot(time,[yy(:,2) yy(:,19)]);

% Create vector "tau" with the maturities of the different yields:
tau = [3 6 9 12 15 18 21 24 30 36 48 60 72 84 96 108 120]';
yy = yy(:,3:19)';   % Keep the relevant maturities (from 3 months to 120 months)

% More information to pass to the MLE function
info.nobs = T-T0+1;  % Number of observations
info.tau  = tau;     % Maturities
info.t0   = t0;      % Initial observation
info.t1   = t1;      % Last observation

fprintf('\n Information of this run: \n ')
disp(info)

% Initialize parameters and store it in vector "param":
if info.initval > 0   % check if initialize parameters using old run
    if exist(namefile,'file')==2   % Check if file exists
        load(namefile)
    else
        fprintf('\n File %s does not exist. Set info.initval = 0. \n',namefile);
        error(' ')
    end
else
    % Otherwise, use the following initial values:
    param  = [ -2.65 0 0 0 0.95 0 0 0 0.95 0 0 0 0.95 0.1 0 0.1 0 0 0.1 0.1*ones(1,17)]';
    loglik = 9999999;   % Initialize (negative of) loglikelihood value to bad number
end

if info.log_results>0
    diary off  % Here stop logging stuff
end

% Perform MLE estimation: the function mle_dns.m does the job
[ loglik_out, param_out, unobserved, fcasterror, P_LL, StdErr ] = mle_dns( param, yy, info );

if info.log_results>0
    diary on  % Start logging results again
end

% Check if new estimates are better than old estimates. 
% If yes, update parameters and save. Please remember that we are
% minimizing the negative of the log-likelihood. Therefore we check whether
% the optimized function is smaller:
if loglik_out   <= loglik       % criterion checks <= because we are in fact minimizing the negative of the log-likelihood
    loglik       = loglik_out;  % minus log-likelihood
    param        = param_out;
    info_est     = info;
    fitted_yield = yy-fcasterror;   % Fitted values: actual - forecast errors
    save(namefile,'param','StdErr','loglik','P_LL','unobserved','fitted_yield','time','info_est')
    disp(['I saved the updated estimates in the file ', namefile])
end

fprintf('\n Log-likelihood value : %.12g \n ', -loglik) %This is correct likelihood value (not its negative)

% -----------------------------------------------------
% PARAMETERS:
fprintf('\n Parameters and Standard errors. \n ')
fprintf('(Note: Std Err = -99 means that we did not compute them.) \n \n ')


% Report results of the estimation

% Transform estimated parameters to actual parameters:
paramt = transform_dns( param );    

lambda = paramt(1);                 % Lambda is first element of param vector
StdErrlambda = StdErr(1);
fprintf(['\n lambda = ', num2str(lambda),'  (', num2str(StdErrlambda),')\n'])

% Constant MU (and std error) of the unobserved process
MU   = paramt(2:4);
sdMU = StdErr(2:4);

fprintf('\n MU= \n'); disp(MU);
fprintf('\n StdErr(MU)= \n'); disp(sdMU);

% Matrix on lagged values of the unobserved process (and its Std Err)
F = zeros(3);
F(1,1:3) = paramt(5:7);
F(2,1:3) = paramt(8:10);
F(3,1:3) = paramt(11:13);

StdErrF(1,:) = StdErr(9:11);
StdErrF(2,:) = StdErr(12:14);
StdErrF(3,:) = StdErr(15:17);

fprintf('\n F= \n'); disp(F);
fprintf('\n StdErr(F)= \n'); disp(StdErrF);

% Covariance matrix of residuals of the unobserved process
Q = zeros(3);
Q(1,1)  = paramt(14);
Q(2,1:2)= paramt(15:16);
Q(3,1:3)= paramt(17:19);
Q(1,2:3)= Q(2:3,1)';
Q(2,3)  = Q(3,2);
        
StdErrQ = zeros(3);
StdErrQ(1,1)   = StdErr(14);
StdErrQ(2,1:2) = StdErr(15:16);
StdErrQ(3,1:3) = StdErr(17:19);
StdErrQ(1,2:3) = StdErrQ(2:3,1)';
StdErrQ(2,3)   = StdErrQ(3,2);

fprintf('\n Q= \n'); disp(Q);
fprintf('\n StdErr(Q)= \n'); disp(StdErrQ);

% NOTE: we are not reporting covariance matrix of measurement errors

if info.plotfigs>0
    figure
    plot(time,unobserved,'linewidth',1.5)
    title('Unobserved')
    legend('Level factor','Slope factor','Curvature factor');

    figure
    plot(time,fcasterror,'linewidth',1.5)
    title('Forecast errors')

    figure
    plot(time, (yy(1,:)+yy(8,:)+yy(17,:)) / 3, time, unobserved(1,:),'Linewidth',1.5 );
    title('Level')
    legend('data','unobserved component'); legend('boxoff')

    figure
    plot(time, yy(1,:)-yy(17,:), time, unobserved(2,:),'Linewidth',1.5 );
    title('Slope')
    legend('data','unobserved component'); legend('boxoff')

    figure
    plot(time, 2*yy(8,:)-yy(1,:)-yy(17,:), time, unobserved(3,:),'Linewidth',1.5 );
    title('Curvature')
    legend('data','unobserved component'); legend('boxoff')

    % Now plot factor loadings
    mtau  = 0:120;   % To plot factor loadings
    slope = (1 - exp(-lambda*mtau))./(lambda*mtau);
    curve = slope - exp(-lambda*mtau);

    figure
    plot(mtau,slope,'b-',mtau,curve,'b--','Linewidth',1.5)
    legend('Slope loading', 'Curvature loading')
    legend('boxoff')
    title('Factor loadings: slope and curvature')
    xlabel('Maturity \tau (in months)')
end

elapsed=toc;

hours   = floor( elapsed / 60^2 );
minutes = floor( (elapsed - 60^2*hours)/60 );
seconds = floor( elapsed - 60^2*hours - 60*minutes );

fprintf('\nTotal Elapsed time: %d hours, %d minutes, and %d seconds \n',hours,minutes,seconds)

if info.log_results>0
    diary off
end
