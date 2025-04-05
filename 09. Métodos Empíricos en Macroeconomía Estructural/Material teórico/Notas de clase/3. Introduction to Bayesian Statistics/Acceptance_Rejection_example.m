% ACCEPTANCE REJECTION EXAMPLE
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

%% PLOT KERNEL, PROPOSAL DENSITY, AND ENVELOPE
xlow =-10;
xhig = 20;

N = 200;
xvec = linspace(xlow,xhig,N);
kvec = k(xvec);
gvec = g(xvec);
M = 12;
Mgvec = M*gvec;

figure('units','normalized','outerposition',[0 0 1 1])
l1 = line(xvec,kvec,'linewidth',2,'color',color1);
l2 = line(xvec,gvec,'linewidth',2,'color',color2);
l3 = line(xvec,Mgvec,'linewidth',2,'color',color5);
grid on

hleg = legend(gca,[l1,l2,l3],'Target kernel $k(x)$','Proposal pdf $g(x)$','$Mg(x)$','location','northwest');
legend(gca,'boxoff')
set(hleg,'Interpreter','Latex','Fontsize',14);

% Export figure
filename = 'Figure_AcceptReject_Kernel_Proposal.pdf';
exportgraphics(gcf,filename)



%% MAKE DRAWS FROM PROPOSAL AND COMPUTE ACCEPTANCE-REJECTION SAMPLING

Ndraws = 200000;                        % Number of draws
xdraws = mu3 + sigma3*randn(Ndraws,1);  % Drawing from proposal
prob   = k(xdraws)./(M*g(xdraws));      % Compute acceptance probabilities     
udraws = rand(Ndraws,1);                % Draw uniforms
xaccept = xdraws(udraws<prob);          % Draws from target distribution

NA = numel(xaccept)/Ndraws;             % Fraction of accepted draws (estimate of acceptance probability)s
disp('Acceptance rate:')
disp(NA)

figure('units','normalized','outerposition',[0 0 1 1])
l1=histogram(xaccept,100,'Normalization','pdf');
hold on
l2=plot(xvec,kvec/(M*NA),'linewidth',2,'color',color2);
grid on
hleg = legend(gca,[l1,l2],'Acceptance-Rejection sampling','True density $p(x)$','location','northwest');
legend(gca,'boxoff')
set(hleg,'Interpreter','Latex','Fontsize',14);

% Export figure
filename = 'Figure_AcceptReject_Sampling.pdf';
exportgraphics(gcf,filename)
