% Random Walk Metropolis Hastings
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
% Kernel of p(x) is k(x) = alpha exp( -0.5*(x-mu1)^2/sigma1^2 ) * (1-alpha)exp( -0.5*(x-mu2)^2/sigma2^2 )

clearvars
close all


%% TARGET DISTRIBUTION
mu1    = 0;          %-3
sigma1 = sqrt(2.5);  %1
mu2    = 10;
sigma2 = sqrt(2.5);  %1
eta    = 0.3;

% Kernel of the mixture
k = @(x) eta * exp(-0.5*(x-mu1).^2/sigma1^2) + (1-eta) * exp(-0.5*(x-mu2).^2/sigma2^2);



%% PROPOSAL PDF
sigma3 = 8;
proposal_pdf = @(x,mu) normpdf(x,mu,sigma3);
%sample_from_proposal = @(mu) normrnd(mu,sigma3);
sample_from_proposal = @(mu) mu + sigma3*randn;

%% INFORMATION METROPOLIS HASTINGS
M     = 60000;     % Number of samples (iterations)
burn  = 1000;      % Number of runs until the chain approaches stationarity
Mb    = M + burn;
nn      = 100;       % Number of samples for examine the AC

% Storage
xdraws = zeros(Mb,1);    % Samples drawn from the Markov chain (States)
accept = zeros(Mb,1);    % Accepted draw


%% Main algorithm
x = 0;  % Starting point of the chain
xdraws(1) = x;
accept(1) = 1;
for iter=1:Mb-1

    x = xdraws(iter);

    % Draw y from proposal density
    y = sample_from_proposal(x);


    % Compute acceptance probability
    %alpha =  min(( k(y)*proposal_pdf(x,y) )/ (  k(x)*proposal_pdf(y,x) ),1);
    alpha =  min(k(y)/k(x),1); % In case of symmetric random walk the expression simplifies

    if rand<=alpha
        % Accept the draw
        xdraws(iter+1) = y;
        accept(iter+1) = 1;

    else 
        % Reject the draw
        xdraws(iter+1) = x;
    end
end

% Drop burning sample
xdraws = xdraws(burn+1:end);
accept = accept(burn+1:end);
accept_rate = sum(accept)/M;
disp('Acceptance rate:')
disp(accept_rate)



% Compute autocorrelation of chain at beginning and end of sample
% Autocorrelation (AC)
pp  = xdraws(1:nn);        % First nn samples
pp2 = xdraws(end-nn:end);  % Last nn samples
[r, lags]   = xcorr(pp-mean(pp), 'normalized');
[r2, lags2] = xcorr(pp2-mean(pp2), 'normalized');


%% Test for convergence
% Geweke test 1992, see Ref 1. Pag. 15.
% After removing burn in period, split the sample in two blocks:
% Block 1: first 10% of the sample
% Block 2: last 50% of the sample
% Check mean in block 1 and block 2. If they are approximately equal, the
% test is OK. If not, it has not converged yet

block1 = xdraws(1:round(0.1*M));
mean1  = mean(block1);

block2 = xdraws(round(0.5*M):end);
mean2  = mean(block2);
if abs((mean1-mean2)/mean1) < 0.03   % 3% error
   fprintf('\n The Geweke test OK \n')
else
   fprintf('\n The Geweke test failed \n')
end



%% Make plot
% Colors:
color1 = [0         0.4470	0.7410];
color2 = [0.8500    0.3250  0.0980];
color3 = [0.9290    0.6940  0.1250];
color4 = [0.4940    0.1840  0.5560];
color5 = [0.4660    0.6740  0.1880];
color6 = [0.3010    0.7450  0.9330];
color7 = [0.6350	0.0780  0.1840];
colorr = [238	59	59]/255;    % This red is called brown2 #ee3b3b


% Plot autocorrelation of chain at beginning and end of sample

figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,1,1);   stem(lags, r);
title('Autocorrelation', 'FontSize', 14);
ylabel('AC (first 100 samples)', 'FontSize', 12);

subplot(2,1,2);   stem(lags2, r2);
ylabel('AC (last 100 samples)', 'FontSize', 12);

% Export figure
filename = 'Figure_RWMH_Autocorrelations.pdf';
exportgraphics(gcf,filename)


%% Plot histograms

xlow = -6;
xhig = 16;
xx = xlow:0.01:xhig;   % x-axis (Graphs)


figure('units','normalized','outerposition',[0 0 1 1])

subplot(2,1,1); 
histogram(xdraws,ceil(sqrt(M)),'Normalization','pdf');
hold on
plot(xx, k(xx)/trapz(xx,k(xx)), 'r-', 'LineWidth', 2);        % Normalized "PDF"
xlim([xlow xhig]); grid on; 
title('Distribution of samples', 'FontSize', 15);
ylabel('Probability density function', 'FontSize', 12);
text(xlow+1,0.15,sprintf('Acceptance rate = %g', accept_rate),'FontSize',12);

% Samples
subplot(2,1,2)
%plot(xdraws,1:M)
scatter(xdraws,1:M,'.')
xlim([xlow xhig])
ylim([0 M])
grid on
xlabel('Location', 'FontSize', 12);
ylabel('Iterations', 'FontSize', 12); 

% Export figure
filename = 'Figure_RWMH_Sampling.pdf';
exportgraphics(gcf,filename)

%% Compute and plot running mean

cumsum_xdraws = cumsum(xdraws);
indices       = (1:M)';
running_mean  = cumsum_xdraws ./ indices;

figure('units','normalized','outerposition',[0 0 1 1])
l1 = line(1:M,running_mean,'color',color1,'linewidth',1.5);
l2 = line(1:M,ones(M,1)*(eta*mu1+(1-eta)*mu2),'color',color2,'linewidth',1.5);
grid on
hleg = legend(gca,[l1,l2],'Recursive mean','True mean  $\eta \mu_1 + (1-\eta)\mu_2$','location','northwest');
legend(gca,'boxoff')
set(hleg,'Interpreter','Latex','Fontsize',14);
title('Recursive mean', 'FontSize', 15);
xlabel('Iterations, M', 'FontSize', 12);

% Export figure
filename = 'Figure_RWMH_RunningMean.pdf';
exportgraphics(gcf,filename)

