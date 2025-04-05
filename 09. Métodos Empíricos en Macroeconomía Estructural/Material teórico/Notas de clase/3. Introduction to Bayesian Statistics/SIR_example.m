% SAMPLING IMPORTANCE RESAMPLING EXAMPLE
%
% Target p(x) is a gaussian mixture:
%
%     p(x) = alpha*N(mu1,sigma1^2) + (1-alpha)*N(mu2,sigma2^2)
%
% Proposal density is gaussian:
%
%     g(x) = N(mu3,sigma3^2)
%
%
% Kernel of p(x) is k(x) = eta*exp( -0.5*(x-mu1)^2/sigma1^2 ) * (1-eta)*exp( -0.5*(x-mu2)^2/sigma2^2 )

clearvars
close all

% Colors:
color1 = [0         0.4470	0.7410];
color2 = [0.8500    0.3250  0.0980];
color3 = [0.9290    0.6940  0.1250];
color4 = [0.4940    0.1840  0.5560];
color5 = [0.4660    0.6740  0.1880];
color6 = [0.3010    0.7450  0.9330];
color7 = [0.6350	0.0780  0.1840];
colorr = [238	59	59]/255;    % This red is called brown2 #ee3b3b

%% TARGET DISTRIBUTION
mu1    = 0;          %-3
sigma1 = sqrt(2.5);  % 1
mu2    = 10;         % 2
sigma2 = sqrt(2.5);  % 1
eta    = 0.3;

% Kernel of the mixture
k = @(x) eta * exp(-0.5*(x-mu1).^2/sigma1^2) + (1-eta) * exp(-0.5*(x-mu2).^2/sigma2^2);

%% PROPOSAL DENSITY
mu3 = 8;
sigma3 = 6;
g = @(x) normpdf(x,mu3,sigma3);


% Parameters target
%mu1    = -3;
%sigma1 = 1;
%mu2    = 2;
%sigma2 = 1;
%alpha  =0.3;

%k = @(x) alpha * exp(-0.5*(x-mu1).^2/sigma1^2) + (1-alpha) * exp(-0.5*(x-mu2).^2/sigma2^2);


% Parameters proposal density
%mu3 = 0;
%sigma3 = 3;
%g = @(x) normpdf(x,mu3,sigma3);

%% SAMPLING-IMPORTANCE RESAMPLING ALGORITHM

% Sample from the proposal distribution and compute importance weights
Ndraws = 200000;                        % Number of draws
xdraws = mu3 + sigma3*randn(Ndraws,1);  % Draws from proposal density
omega  = k(xdraws)./g(xdraws);          % Importance weights

% Normalize importance weights to create probabilities of particles
qprob = omega/sum(omega);

% Compute cummulative distribution of discrete probability
qcdf  = cumsum(qprob);

% Draw Mdraw samples from the discrete distribution. 
% Rule of thumb is Mdraws/Ndraws <= (1/10)
Mdraws = round(Ndraws/10);
%Mdraws = 100000;


% Draw uniform random numbers
uniformSamples = rand(Mdraws, 1);

% Map uniform samples to discrete outcomes using discretize function
idx = discretize(uniformSamples, [0;qcdf]);
samples = xdraws(idx);


%% Make plot

xlow =-10;
xhig = 20;

N = 200;
xvec = linspace(xlow,xhig,N);
kvec = k(xvec);
gvec = g(xvec);


figure('units','normalized','outerposition',[0 0 1 1])
l1 = line(xvec,kvec,'linewidth',2,'color',color1);
l2 = line(xvec,gvec,'linewidth',2,'color',color2);
grid on

hleg = legend(gca,[l1,l2],'Target kernel $k(x)$','Proposal pdf $g(x)$','location','northwest');
legend(gca,'boxoff')
set(hleg,'Interpreter','Latex','Fontsize',14);


% Export figure
filename = 'Figure_SIR_kernel_proposal.pdf';
exportgraphics(gcf,filename)

%% PLOT SIR SAMPLES AND TRUE DENSITY
% To plot true density
NormalizingConstant = sum(omega)/Ndraws;

figure('units','normalized','outerposition',[0 0 1 1])
l1=histogram(samples,100,'Normalization','pdf');
hold on
l2=plot(xvec,kvec/NormalizingConstant,'linewidth',2,'color',color2);
hleg = legend(gca,[l1,l2],'SIR','True density $p(x)$','location','northwest');
legend(gca,'boxoff')
set(hleg,'Interpreter','Latex','Fontsize',14);
grid on

% Export figure
filename = 'Figure_SIR_Sampling.pdf';
exportgraphics(gcf,filename)