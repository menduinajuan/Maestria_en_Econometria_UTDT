% Estimation of monetary and fiscal rules. This is my version of Canova's
% example

%%%%%%%%%%%%%%%%%%%%%% Exercises %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% exercise 1: Change the number of instruments in equation 1 and then in equation 2.
% exercise 2: Change the sample. 
% exercise 3: Compare just -identified and overidentified estimates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
%=======================================================================
% LOAD DATA
%=======================================================================
data = xlsread('data_example2_US');

%=======================================================================
% SAMPLE 
%=======================================================================
sample=1:151;     % This is the entire sample
%sample=[65:151];

nobs = length(sample);  % Number of observations

%=======================================================================
% ESTIMATION
%=======================================================================
dates=data(sample,1);

% Instruments
deficit_2 = data(sample,16);    % deficit ratio in t-2
gap_2     = data(sample,17);    % output gap in t-2
gap_s_2   = data(sample,18);    % gap s in t-2
gap_b_2   = data(sample,19);    % gap b in t-2
debt_2    = data(sample,20);    % debt ratio in t-2
cpi_2     = data(sample,21);    % inflaiton in t-2
r_2       = data(sample,22);    % interest rate in t-2

deficit_3 = data(sample,23);    % deficit ratio in t-3
gap_3     = data(sample,24);    % output gap in t-3
gap_s_3   = data(sample,25);    % gap s in t-3
gap_b_3   = data(sample,26);    % gap b in t-3
debt_3    = data(sample,27);    % debt ratio in t-3
cpi_3     = data(sample,28);    % inflaiton in t-3
r_3       = data(sample,29);    % interest rate in t-3

% LEFT HAND VARIABLES: current deficit and interest rate

deficit = data(sample,2);     % Current deficit
r       = data(sample,8);     % Current interest rate

Y1 = deficit;
Y2 = r;

% RIGHT HAND VARIABLES: Fiscal (F) and Monetary (M)
deficit_1 = data(sample,9);
gap_s     = data(sample,4);
gap_b     = data(sample,5);
debt      = data(sample,6);

X1=[deficit_1 gap_s gap_b debt]; %FISCAL POLICY

gap = data(sample,3);
cpi = data(sample,7);
r_1 = data(sample,15);

X2=[cpi gap r_1];      %MONETARY POLICY including lagged interest rate

% INSTRUMENTS, system F and system M
gap_s_1 = data(sample,11);
gap_b_1 = data(sample,12);
debt_1  = data(sample,13);
cpi_1   = data(sample,14);
gap_1   = data(sample,10);

% Z1 are instruments for the fiscal equation, 
% Z2 are instruments for the monetary equation

%Z1=[deficit_1 deficit_2  gap_s_1 debt_1 debt_2 cpi_1 cpi_2];
Z1 = [deficit_1 gap_s_1 gap_b_1 debt_1 cpi_1];


Z2=[cpi_1 gap_1 r_1];           % in case of whole sample but no overidentific
%Z2=[cpi_1 gap_1 r_1 cpi_2 gap_2 r_2];    %in case of reduced sample (passive)
%Z2=[cpi_1 gap_1 r_1 cpi_2];    % in case of reduced sample (passive)
%Z2=[cpi_1 gap_1 r_1 cpi_3];    % in case of reduced sample (active)

% Add constant to regressors?
X1=[ones(nobs,1) X1]; % adding constant in the fiscal policy
Z1=[ones(nobs,1) Z1];

X2=[ones(nobs,1) X2];  % adding constant in the monetary policy
Z2=[ones(nobs,1) Z2];

% Total number of parameters:
npar = size(X1,2)+size(X2,2);

% Initial guess parameters
b0 = zeros(npar,1);

nz1 = size(Z1,2);
nz2 = size(Z2,2);

% Initial weighting matrix
W = eye(nz1+nz2);

option_fmu = optimset('Largescale','off','Display','iter','MaxFunEvals',15000,...
                       'Maxiter',2000,'TolX',1e-12,'Tolfun',1e-8);

fprintf('\n First stage GMM using W = I. \n')

[ b1, J1 ] = fminunc( @gmm_objective_moneyfiscal,b0,option_fmu,Y1,Y2,X1,X2,Z1,Z2,W);

% Now compute asymptotic covariance matrix to perform second stage GMM
[~, moments, mm] = gmm_objective_moneyfiscal(b1,Y1,Y2,X1,X2,Z1,Z2,W);
Shat = vcov_HAC( mm, 0 );

% Second stage GMM using estimate of asymptotic covariance matrix
W2 = inv(Shat);
[ b2, J2 ] = fminunc( @gmm_objective_moneyfiscal, b1, option_fmu, Y1,Y2,X1,X2,Z1,Z2,W2);

% Iterate a few times to see what happens with the estimates
b_it = b2;
W_it = W2;
norm_b=1;
while norm_b>0.000001;
%for i=1:30;     % Iterate 10 times, this is enough
    [~, ~, mm] = gmm_objective_moneyfiscal(b_it,Y1,Y2,X1,X2,Z1,Z2,W_it);
    S_it = vcov_HAC( mm, 0 );
    W_it = inv(S_it);
    [ bnew, J_it ] = fminunc( @gmm_objective_moneyfiscal,b_it,option_fmu,Y1,Y2,X1,X2,Z1,Z2,W_it);
    norm_b = norm(bnew-b_it);
    b_it=bnew;
end

% Now compute standard errors of the second stage and the iterative GMM
D1 = -Z1'*X1/nobs;      % First equation
D2 = -Z2'*X2/nobs;      % Second equation

% All equations together
D = [D1                    zeros(nz1,size(X2,2));
     zeros(nz2,size(X1,2)) D2                  ];

% Standard errors, second step;
J   = J2;
b   = b2;   % 2-stage GMM
Wb  = inv( D'*inv(Shat)*D )/nobs;    %#ok<MINV>
seb = sqrt( diag( Wb ) ); 
R = [0 0 1 -1 0 0 0 0 0];        % Test equality b(3) = b(4);
test_eq = (R*b)*inv(R*Wb*R')*R*b;
% Thisis  a Wald statistic distributed as chi-square with 1 degree of freedom
tstat = b./seb;

% Standard error, iterative GMM
Wb_it = inv( D'*inv(S_it)*D )/nobs;    %#ok<MINV>
seb_it = sqrt(diag(Wb_it));
pool_it = (b_it(3)-b_it(4))*(ones(1,2)*Wb_it(3:4,3:4)*ones(2,1))*(b_it(3)-b_it(4)); % Test of equality of coefficient gap boom and recession
test_eq_it = (R*b_it)*inv(R*Wb_it*R')*R*b_it;
tstat_it = b_it./seb_it;

fprintf(' Results GMM estimation Money and Fiscal rules \n')
fprintf(' ============================================= \n\n')
fprintf(' 2-stage GMM\n\n');
fprintf(' Coef  \t Value \t    Std err. \t t-stat \n')
fprintf(' ======================================= \n')
fprintf(' a0  \t %6.4f \t %6.4f \t %6.4f \n',b2(1),seb(1),b2(1)/seb(1))
fprintf(' a1  \t %6.4f \t %6.4f \t %6.4f \n',b2(2),seb(2),b2(2)/seb(2))
fprintf(' a2  \t %6.4f \t %6.4f \t %6.4f \n',b2(3),seb(3),b2(3)/seb(3))
fprintf(' a3  \t %6.4f \t %6.4f \t %6.4f \n',b2(4),seb(4),b2(4)/seb(4))
fprintf(' a4  \t %6.4f \t %6.4f \t %6.4f \n',b2(5),seb(5),b2(5)/seb(5))
fprintf(' b0  \t %6.4f \t %6.4f \t %6.4f \n',b2(6),seb(6),b2(6)/seb(6))
fprintf(' b1  \t %6.4f \t %6.4f \t %6.4f \n',b2(7),seb(7),b2(7)/seb(7))
fprintf(' b2  \t %6.4f \t %6.4f \t %6.4f \n',b2(8),seb(8),b2(8)/seb(8))
fprintf(' b3  \t %6.4f \t %6.4f \t %6.4f \n',b2(8),seb(8),b2(8)/seb(8))
fprintf(' b4  \t %6.4f \t %6.4f \t %6.4f \n',b2(9),seb(9),b2(9)/seb(9))
fprintf(' J-test: %6.4f; p-value: %6.4f \n',nobs*J,1-chi2cdf(nobs*J,nz1+nz2-length(b)));
fprintf(' Test of equality a2=a3 : %6.4f, pvalue: %6.4f\n',test_eq,1-chi2cdf(test_eq,1));
fprintf(' \n\n\n')

fprintf(' Iterative-stage GMM\n\n');
fprintf(' Coef  \t Value \t    Std err. \t t-stat \n')
fprintf(' ======================================= \n')
fprintf(' a0  \t %6.4f \t %6.4f \t %6.4f \n',b_it(1),seb_it(1),b_it(1)/seb_it(1))
fprintf(' a1  \t %6.4f \t %6.4f \t %6.4f \n',b_it(2),seb_it(2),b_it(2)/seb_it(2))
fprintf(' a2  \t %6.4f \t %6.4f \t %6.4f \n',b_it(3),seb_it(3),b_it(3)/seb_it(3))
fprintf(' a3  \t %6.4f \t %6.4f \t %6.4f \n',b_it(4),seb_it(4),b_it(4)/seb_it(4))
fprintf(' a4  \t %6.4f \t %6.4f \t %6.4f \n',b_it(5),seb_it(5),b_it(5)/seb_it(5))
fprintf(' b0  \t %6.4f \t %6.4f \t %6.4f \n',b_it(6),seb_it(6),b_it(6)/seb_it(6))
fprintf(' b1  \t %6.4f \t %6.4f \t %6.4f \n',b_it(7),seb_it(7),b_it(7)/seb_it(7))
fprintf(' b2  \t %6.4f \t %6.4f \t %6.4f \n',b_it(8),seb_it(8),b_it(8)/seb_it(8))   
fprintf(' b3  \t %6.4f \t %6.4f \t %6.4f \n',b_it(9),seb_it(9),b_it(9)/seb_it(9))   
fprintf(' J-test: %6.4f; p-value: %6.4f \n',nobs*J_it,1-chi2cdf(nobs*J_it,nz1+nz2-length(b)));
fprintf(' Test of equality a2=a3 : %6.4f, pvalue: %6.4f\n',test_eq_it,1-chi2cdf(test_eq_it,1));

