%% ESTE PROGRAMA GENERA LAS FIGURAS DEL EJEMPLO DE REGRESION LINEAL BAYESIANA

clearvars
close all

% MY COLORS FOR THE PLOTS:
color1 = [55  140 190]/255;     % Blue
color2 = [250 140 100]/255;     % Orange
color3 = [100 190 165]/255;     % Green
color4 = [240  60  50]/255;     % Red
color5 = [140 110 180]/255;     % Purple
color6 = [230 195 150]/255;     % Beige
color7 = [166 215 85]/255;      % Other green

%% SET UP LINEAR REGRESSION AND GENERATE ARTIFICIAL DATA
%
%    y(i) = beta0 + beta1*x(i) + epsilon(i) for i=1,2,...,n and
%    epsilon(i)~N(0,sigma^2);
%

n = 30;     % Number of observations
beta0 = -1; % Constant
beta1 = 2;  % Slope coefficient
sigma=1;    % Std deviation of error term

betavec_true = [beta0;beta1];

% x_i is uniform(0,1):  

X = [ones(n,1) rand(n,1)];
Y = X*betavec_true + sigma*randn(n,1); 

figure

scatter(X(:,2),Y,'filled')
grid on
title('Artificial data for linear regression example');
ylabel('y')
xlabel('x')
%tightfig;
%print(gcf,'Figure0_bayesian_example','-dpdf');

filename = 'Figure1_linear_regression_bayesian_example.pdf';
exportgraphics(gcf,filename)



%% BAYESIAN LINEAR REGRESSION FOR KNOWN VARIANCE sigma^2
%   Here we consider two cases: (i) uniform prior and (ii) normal prior

% ---------------------------------------
% PRIOR DENSITIES
%
% CASE 1: uniform prior is proportional to 1
%
% CASE 2: normal prior
%
%

%   Define the normal pdf
normal_pdf = @(x,mu,sig) ( 1/(sig*sqrt(2*pi)) ) * exp( -0.5*( (x-mu)/sig).^2 );

%   Parameters of the normal prior
beta0_prior = zeros(2,1);   % prior mean is zero
Sigma0      = eye(2);       % prior variance is the identity matrix

% ---------------------------------------
% POSTERIOR DENSITIES

%   CASE 1: UNIFORM PRIOR
beta1_vec_uniform = (X'*X)\(X'*Y);      % With uniform prior, posterior mean is OLS estimate
Sigma1_uniform    = sigma^2*inv(X'*X);  

%   To construct posterior for beta1
sig1_unif = sqrt(Sigma1_uniform(2,2));
mu1_unif  = beta1_vec_uniform(2);


%   CASE 2: NORMAL PRIOR
Sigma1_normal    = inv( inv(Sigma0)+ (1/sigma^2)*X'*X ); 
beta1_vec_normal = Sigma1_normal*( inv(Sigma0) *beta0_prior  +  (1/sigma^2)*X'*Y );
 
%   To construct posterior for beta1
sig1_normal = sqrt(Sigma1_normal(2,2));
mu1_normal  = beta1_vec_normal(2);

posterior_normal =  @(b1) ( 1/(sig1_normal*sqrt(2*pi)) ) * exp( -0.5*( (b1-mu1_normal)/sig1_normal).^2 );

% MAKE PLOT
b1grid = linspace(-3,5,1000);
pr2 = normal_pdf(b1grid,beta0_prior(2),sqrt(Sigma0(2,2)));
post1_uniform = normal_pdf(b1grid,mu1_unif,sig1_unif);
post1_normal  = normal_pdf(b1grid,mu1_normal,sig1_normal);

figure

plot(b1grid,pr2,'linestyle','--','linewidth',2,'color',color1)
hold on
plot(b1grid,post1_normal,'linewidth',2,'color',color1)
plot(b1grid,post1_uniform,'linewidth',2,'color',color2)
xline(beta1,'linewidth',2.5,'color',[0.5 0.5 0.5])
hold off
grid on
legend('N(0,1) prior','Posterior, N(0,1) prior','Posterior, uniform prior','location','northwest')
legend boxoff
xlabel('Slope parameter \beta_1')
ylabel('Density')
title('Prior and posteriors in simple linear regression example')

% Export figure
filename = 'Figure2_linear_regression_bayesian_example.pdf';
exportgraphics(gcf,filename)


%% CASE 2: BAYESIAN LINEAR REGRESSION FOR KNOWN BETA AND BAYESIAN ESTIMATION OF sigma^2
%   We find it convenient to model this case using the precision
%   tau=1/sigma^2

% ---------------------------------------
% PRIOR DENSITIES OF THE GAMMA FAMILY FOR THE PRECISION tau

%   Define the gamma pdf function for parameters (a,b)
gamma_pdf = @(tau,a,b) ( (b^a)/ gamma(a) ) * tau.^(a-1) .* exp(-b*tau);


% CASE 1: Gamma density with parameters (a0_prior1,b0_prior1)
a0_prior1= 0.5;
b0_prior1= 1;

% CASE 2: Gamma density with parameters (a0_prior2,b0_prior2)
a0_prior2= 2;
b0_prior2= 1;


% ---------------------------------------
% POSTERIOR DENSITIES
%   As shown, posteriors for the precision are also gamma densities for
%   different parameters

%   CASE 1: update parameters of the density
a1_post1 = a0_prior1 + 0.5*n;
b1_post1 = b0_prior1 + 0.5*(Y-X*betavec_true)'*(Y-X*betavec_true);

%   CASE 2: update parameters of the density
a1_post2 = a0_prior2 + 0.5*n;
b1_post2 = b0_prior2 + 0.5*(Y-X*betavec_true)'*(Y-X*betavec_true);


% ---------------------------------------
% MAKE PLOT

taugrid = linspace(0.1,4,1000);

% PRIORS
prior1_tau = gamma_pdf(taugrid,a0_prior1,b0_prior1);
prior2_tau = gamma_pdf(taugrid,a0_prior2,b0_prior2);

% POSTERIORS
post1_tau  = gamma_pdf(taugrid,a1_post1,b1_post1);
%post1_tau = gampdf(taugrid,a1_post1,1/b1_post1);
post2_tau  = gamma_pdf(taugrid,a1_post2,b1_post2);
%post2_tau  = gampdf(taugrid,a1_post2,1/b1_post2);

figure
plot(taugrid,prior1_tau,'linestyle','--','linewidth',2,'color',color1);
hold on
plot(taugrid,post1_tau,'linewidth',2,'color',color1)
plot(taugrid,prior2_tau,'linestyle','--','linewidth',2,'color',color2);
plot(taugrid,post2_tau,'linewidth',2,'color',color2)
xline(1/sigma^2,'linewidth',2.5,'color',[0.5 0.5 0.5])
hold off
grid on
legend(['Prior Gamma(',num2str(a0_prior1),',',num2str(b0_prior1),')'],...
       ['Posterior for Gamma(',num2str(a0_prior1),',',num2str(b0_prior1),') prior'],...
       ['Prior Gamma(',num2str(a0_prior2),',',num2str(b0_prior2),')'],...
       ['Posterior for Gamma(',num2str(a0_prior2),',',num2str(b0_prior2),') prior'])
legend boxoff
xlabel('Precision parameter \tau = \sigma^{-2}')
ylabel('Density')
title('Prior and posteriors in simple linear regression example')

%tightfig;
%print(gcf,'Figure2_bayesian_example','-dpdf');
filename = 'Figure3_linear_regression_bayesian_example.pdf';
exportgraphics(gcf,filename)


%% FULL BAYESIAN ANALYSIS FOR beta and tau=1/sigma^2
%   To draw from the posterior here we use the Gibbs Sampler.

NGibbs = 10000;                  % Effective draws after burn
NBurn = 0.1*NGibbs;              % Percentage of draws burned
NGibbs_total = NBurn+NGibbs;  % Total draws

tau_gibbs  = zeros(1,NGibbs_total); % First element is tau(0)
beta_gibbs = zeros(2,NGibbs_total);

% Priors moments for beta
mean_beta_prior  = zeros(2,1);
Sigma_beta_prior = eye(2);

% Prior parameters for tau = 1/sigma^2
a_tau_prior = 2;
b_tau_prior = 1;


% -------------------------------------
%   GIBS SAMPLER

% Initialize tau[0]
tau_0 = 1;

idraw =1;
while idraw <= NGibbs_total
    
    
    % [1] DRAW beta[:,idraw] FROM prob(beta|tau[idraw-1],Y)
    if idraw == 1
        tau = tau_0;
    else
        tau = tau_gibbs(idraw-1);
    end
    
    % Draw beta[idraw] from the posterior p( beta | tau(idraw-1), Y )
    
    %   Moments of the bivariate normal posterior
    Sigma_beta_posterior = inv( inv(Sigma_beta_prior) + tau*(X'*X) ); 
    mean_beta_posterior  = Sigma_beta_posterior*( Sigma_beta_prior\mean_beta_prior + tau*(X'*Y) );
    
    %   Draw from bivariate normal
    beta_gibbs(:,idraw) = mvnrnd(mean_beta_posterior,Sigma_beta_posterior)';

    % ------------------------------------------------
    % [2] DRAW tau[idraw] FROM prob(tau|beta[idraw],Y)
    
    %   Parameters of the posterior for p(tau|beta(:,idraw),Y)
    a_tau_posterior = a_tau_prior + 0.5*n;
    b_tau_posterior = b_tau_prior + 0.5*(Y-X*beta_gibbs(:,idraw))'*(Y-X*beta_gibbs(:,idraw));
    
    %   Draw from Gamma distribution (Please note that in matlab the second
    %   parameter goes as 1/b. This is different than the way we presented
    %   the Gamma distribution in class
    tau_gibbs(idraw) = gamrnd(a_tau_posterior,1/b_tau_posterior);

    %   UPDATE idraw
    idraw = idraw+1;
end

% DROP THE BURN IN SAMPLE
tau_gibbs  = tau_gibbs(NBurn+1:end);
beta_gibbs = beta_gibbs(:,NBurn+1:end);


%% PLOTS


% PRIOR AND POSTERIOR OF THE CONSTANT OF THE REGRESSION beta0
[ posterior_beta0, beta0grid ] = ksdensity( beta_gibbs(1,:) );
prior_beta0 = normal_pdf(beta0grid , mean_beta_prior(1), sqrt(Sigma_beta_prior(1,1)) );

figure
plot(beta0grid,prior_beta0,'linestyle','--','linewidth',3,'color',color1);
hold on
plot(beta0grid,posterior_beta0,'linestyle','-','linewidth',3,'color',color3);
plot(beta0grid,normal_pdf(beta0grid,beta1_vec_normal(1),sqrt(Sigma1_normal(1,1))),'linestyle',':','linewidth',3,'color',color2);
xline(beta0,'linewidth',3,'color',[0.5 0.5 0.5])
hold off
grid on


legend(['Prior N(',num2str(mean_beta_prior(1)),',',num2str(Sigma_beta_prior(1,1)),')'],'Posterior (Gibbs Sampler)','Posterior with known \tau')
legend boxoff
xlabel('Constant parameter \beta_0')
ylabel('Density')
title('Prior and posterior of \beta_0')

%tightfig;
%print(gcf,'Figure3_bayesian_example','-dpdf');

filename = 'Figure4_linear_regression_bayesian_example.pdf';
exportgraphics(gcf,filename)



% PRIOR AND POSTERIOR OF THE SLOPE OF THE REGRESSION beta1
[ posterior_beta1, beta1grid ] = ksdensity( beta_gibbs(2,:) );
prior_beta1 = normal_pdf(beta1grid , mean_beta_prior(2), sqrt(Sigma_beta_prior(2,2)) );

figure
plot(beta1grid,prior_beta1,'linestyle','--','linewidth',3,'color',color1);
hold on
plot(beta1grid,posterior_beta1,'linestyle','-','linewidth',3,'color',color3);
plot(beta1grid,normal_pdf(beta1grid,mu1_normal,sig1_normal),'linestyle',':','linewidth',3,'color',color2);
xline(beta1,'linewidth',3,'color',[0.5 0.5 0.5])
hold off
grid on

legend(['Prior N(',num2str(mean_beta_prior(2)),',',num2str(Sigma_beta_prior(2,2)),')'],'Posterior (Gibbs Sampler)','Posterior with known \tau','Location','Northwest')
legend boxoff
xlabel('Slope parameter \beta_1')
ylabel('Density')
title('Prior and posterior of \beta_1')

%tightfig;
%print(gcf,'Figure4_bayesian_example','-dpdf');
filename = 'Figure5_linear_regression_bayesian_example.pdf';
exportgraphics(gcf,filename)


% PRIOR AND POSTERIOR OF THE PRECISION PARAMETER TAU
[posterior_tau,taugrid] = ksdensity(tau_gibbs);
prior_tau = gamma_pdf(taugrid,a_tau_prior,b_tau_prior);

figure
plot(taugrid,prior_tau,'linestyle','--','linewidth',3,'color',color1);
hold on
plot(taugrid,posterior_tau,'linestyle','-','linewidth',3,'color',color3);
plot(taugrid,gampdf(taugrid,a1_post1,1/b1_post1),'linestyle',':','linewidth',3,'color',color2);     % This is posterior with beta known
xline(1/sigma^2,'linewidth',3,'color',[0.5 0.5 0.5])
hold off
grid on

legend(['Prior Gamma(',num2str(a_tau_prior),',',num2str(b_tau_prior),')'],'Posterior (Gibbs Sampler)','Posterior with known \beta')
legend boxoff
xlabel('Precision parameter \tau = \sigma^{-2}')
ylabel('Density')
title('Prior and posterior of the precision \tau')

filename = 'Figure6_linear_regression_bayesian_example.pdf';
exportgraphics(gcf,filename)


%tightfig;
%print(gcf,'Figure5_bayesian_example','-dpdf');