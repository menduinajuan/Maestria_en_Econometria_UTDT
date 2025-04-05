% Program for factor models
clear
close all

% load yield data
load UnsmFB_70_09.txt -ascii

data = UnsmFB_70_09(:,2:end);               % Yield data
time = (1970 + 0.5/12:1/12:2009+11.5/12)';  % Time index
% 
% ynames = ['3   months ';...
%           '6   months ';...
%           '9   months ';...
%           '12  months ';...
%           '15  months ';...
%           '18  months ';...
%           '21  months ';...
%           '24  months ';...
%           '30  months ';...
%           '36  months ';...
%           '48  months ';...
%           '60  months ';...
%           '72  months ';...
%           '84  months ';...
%           '96  months ';...
%           '108 months ';...
%           '120 months '];
          
figure(1);
plot(time,data);
title('Bond yield data','Fontsize',14);
grid on
print bond_yields.eps -deps2c


% Standardize data for analysis:
data_norm = zscore(data);

figure(2);
plot(time,data_norm);
title('Normalized Bond yield data','Fontsize',14);
grid on
print bond_yields_norm.eps -deps2c

% Now compute principal components of data
[pca_coeff, factors, eigenvalues ] = pca(data_norm);

% Scree plot
figure(3)
plot(100*eigenvalues/sum(eigenvalues),'o-','linewidth',1.5);
title('Scree plot','Fontsize',14)
xlabel('Component number','Fontsize',12)
ylabel('Fraction of variance ($\lambda_i/\sum\lambda_j$ ) (percent)','Fontsize',12','interpreter','latex')
xlim([0 length(eigenvalues)+1]);    %Sets X-axis
grid on
print scree_plot_yields.eps -deps2c

% Plot fit using principal components
figure(4)
plot(time,factors(:,1:3),'linewidth',1.5)
title('Three "largest" principal components','Fontsize',14)
legend('PC 1','PC 2','PC 3');
legend boxoff
grid on
print 3factors_yields.eps -deps2c


% Compute fit using 1 component, 2 components, and 3 components
fit1 = (pca_coeff(:,1)*factors(:,1)')';     % Using 1st PC
fit2 = (pca_coeff(:,1:2)*factors(:,1:2)')'; % Using 1st and 2nd PC
fit3 = (pca_coeff(:,1:3)*factors(:,1:3)')'; % Using 1st, 2nd and 3rd PC
fit4 = (pca_coeff(:,1:4)*factors(:,1:4)')'; % Using 1st, 2nd, 3rd and 4th PC
fit5 = (pca_coeff(:,1:5)*factors(:,1:5)')'; 
fit6 = (pca_coeff(:,1:6)*factors(:,1:6)')'; 
fit7 = (pca_coeff(:,1:7)*factors(:,1:7)')'; 
fit8 = (pca_coeff(:,1:8)*factors(:,1:8)')'; 
fit9 = (pca_coeff(:,1:9)*factors(:,1:9)')'; 
fit10= (pca_coeff(:,1:10)*factors(:,1:10)')'; 
fit11= (pca_coeff(:,1:11)*factors(:,1:11)')'; 
fit12= (pca_coeff(:,1:12)*factors(:,1:12)')'; 
fit13= (pca_coeff(:,1:13)*factors(:,1:13)')'; 
fit14= (pca_coeff(:,1:14)*factors(:,1:14)')'; 
fit15= (pca_coeff(:,1:15)*factors(:,1:15)')'; 
fit16= (pca_coeff(:,1:16)*factors(:,1:16)')'; 
fit17= (pca_coeff(:,1:17)*factors(:,1:17)')'; 

% CRITERIA TO CHOOSE NUMBER OF FACTORS

% BAI AND NG
err1  = data_norm - fit1;
err2  = data_norm - fit2;
err3  = data_norm - fit3;
err4  = data_norm - fit4;
err5  = data_norm - fit5;
err6  = data_norm - fit6;
err7  = data_norm - fit7;
err8  = data_norm - fit8;
err9  = data_norm - fit9;
err10 = data_norm - fit10;
err11 = data_norm - fit11;
err12 = data_norm - fit12;
err13 = data_norm - fit13;
err14 = data_norm - fit14;
err15 = data_norm - fit15;
err16 = data_norm - fit16;
err17 = data_norm - fit17;

% Construct Bai Ng Criterion
V = zeros(17,1);
V(1)  = sum(sum(err1.*err1,2))/numel(err1);
V(2)  = sum(sum(err2.*err2,2))/numel(err2);
V(3)  = sum(sum(err3.*err3,2))/numel(err3);
V(4)  = sum(sum(err4.*err4,2))/numel(err4);
V(5)  = sum(sum(err5.*err5,2))/numel(err5);
V(6)  = sum(sum(err6.*err6,2))/numel(err6);
V(7)  = sum(sum(err7.*err7,2))/numel(err7);
V(8)  = sum(sum(err8.*err8,2))/numel(err8);
V(9)  = sum(sum(err9.*err9,2))/numel(err9);
V(10) = sum(sum(err10.*err10,2))/numel(err10);
V(11) = sum(sum(err11.*err11,2))/numel(err11);
V(12) = sum(sum(err12.*err12,2))/numel(err12);
V(13) = sum(sum(err13.*err13,2))/numel(err13);
V(14) = sum(sum(err14.*err14,2))/numel(err14);
V(15) = sum(sum(err15.*err15,2))/numel(err15);
V(16) = sum(sum(err16.*err16,2))/numel(err16);
V(17) = sum(sum(err17.*err17,2))/numel(err17);

term = sum(size(data_norm))*log(min(size(data_norm)))/numel(data_norm);

% This is V(r) + r*(N+T)*log(min(N,T))/(N*T):
Bai_Ng_criterion = V + (1:size(data_norm,2))'*term;

% AHN AND HORESTEIN
ahn_horenstein_criterion = eigenvalues(1:end-1)./eigenvalues(2:end);


fprintf('\n Choosing number of factors\n\n')
fprintf('Factor #    Bai-Ng    Ahn-Horenstein \n');
fprintf('==================================== \n');
for il = 1:10
    fprintf(' %i         %6.3f        %6.3f   \n',il,Bai_Ng_criterion(il),ahn_horenstein_criterion(il));
end
% HOWEVER, YIELDS SEEM TO HAVE A UNIT ROOT AT LEAST IN SMALL SAMPLE. MUST BE CAREFUL



% NOW PLOT A FEW MATURITIES AGAINST FIT
imat1 = 1;   % 3 months
imat2 = 4;   % 12 months
imat3 = 13;  % 6 years
imat4 = 17;  % 10 years

% 1st PC
figure(5);
subplot(2,2,1);
plot(time,data_norm(:,imat1),time,fit1(:,imat1));
title('3 months yield and fit using 1st PC','Fontsize',9)
grid on

subplot(2,2,2);
plot(time,data_norm(:,imat2),time,fit1(:,imat2));
title('12 months yield and fit using 1st PC','Fontsize',9)
grid on

subplot(2,2,3);
plot(time,data_norm(:,imat3),time,fit1(:,imat3));
title('6 year yield and fit using 1st PC','Fontsize',9)
grid on

subplot(2,2,4);
plot(time,data_norm(:,imat4),time,fit1(:,imat4));
title('10 year yield and fit using 1st PC','Fontsize',9)
grid on

print fit_1factor.eps -deps2c


% 1st and 2nd PC
figure(6);
subplot(2,2,1);
plot(time,data_norm(:,imat1),time,fit2(:,imat1));
title('3 months yield and fit using 2 PCs','Fontsize',9)
grid on

subplot(2,2,2);
plot(time,data_norm(:,imat2),time,fit2(:,imat2));
title('12 months yield and fit using 2 PCs','Fontsize',9)
grid on

subplot(2,2,3);
plot(time,data_norm(:,imat3),time,fit2(:,imat3));
title('6 year yield and fit using 2 PCs','Fontsize',9)
grid on

subplot(2,2,4);
plot(time,data_norm(:,imat4),time,fit2(:,imat4));
title('10 year yield and fit using 2 PCs','Fontsize',9)
grid on
print fit_2factor.eps -deps2c


% 1st 2nd and 3rd PC
figure(7);
subplot(2,2,1);
plot(time,data_norm(:,imat1),time,fit3(:,imat1));
title('3 months yield and fit using 3 PCs','Fontsize',9)
grid on

subplot(2,2,2);
plot(time,data_norm(:,imat2),time,fit3(:,imat2));
title('12 months yield and fit using 3 PCs','Fontsize',9)
grid on

subplot(2,2,3);
plot(time,data_norm(:,imat3),time,fit3(:,imat3));
title('6 year yield and fit using 3 PCs','Fontsize',9)
grid on

subplot(2,2,4);
plot(time,data_norm(:,imat4),time,fit3(:,imat4));
title('10 year yield and fit using 3 PCs','Fontsize',9)
grid on

print fit_3factor.eps -deps2c

% 1st 2nd, 3rd, and 4th PC
figure(8);
subplot(2,2,1);
plot(time,data_norm(:,imat1),time,fit4(:,imat1));
title('3 months yield and fit using 4 PC','Fontsize',9)
grid on

subplot(2,2,2);
plot(time,data_norm(:,imat2),time,fit4(:,imat2));
title('12 months yield and fit using 4 PC','Fontsize',9)
grid on

subplot(2,2,3);
plot(time,data_norm(:,imat3),time,fit4(:,imat3));
title('6 year yield and fit using 4 PC','Fontsize',9)
grid on

subplot(2,2,4);
plot(time,data_norm(:,imat4),time,fit4(:,imat4));
title('10 year yield and fit using 4 PC','Fontsize',9)
grid on

print fit_4factor.eps -deps2c

% Plot factor loadings
fdata = factors(:,1:3);       % First 3 factors
fload = pca_coeff(:,1:3);     % Factor weights

matur = [ 3 6 9 12 15 18 21 24 30 36 48 60 72 84 96 108 120];
          
figure(9)
plot(matur,fload,'Linewidth',2);
legend('PC1 (Level)','PC2 (Slope)','PC3 (Curvature)')
legend boxoff
grid on
axis([1 120 -inf +inf])
title('Factor loadings (level, slope and curvature)','Fontsize',12)
xlabel('Maturity (months)','Fontsize',12)
ylabel('Loading','Fontsize',12)
grid on

print factor_loadings.eps -deps2c

% ---------------------------------------------
% NOW ESTIMATE A VAR PROCESS FOR THE 3 MAIN FACTORS

% Check lag length using standard criteria
Lmax = 8; % Maximun number of lags to check for VAR order

% To store information criteria
AIC = zeros(Lmax,1);
SIC = zeros(Lmax,1);
HQC = zeros(Lmax,1);

% Estimate for each lag to compute information criteria
for ilag = 1:Lmax
    outputVAR = var_ls( fdata, ilag, Lmax );
    AIC(ilag) = outputVAR.AIC;  % Akaike
    SIC(ilag) = outputVAR.SIC;  % Schwarz
    HQC(ilag) = outputVAR.HQC;  % Hannan-Quinn
end
fprintf('\n Information Criteria \n\n')
fprintf('Lag    AIC      SIC      HQC  \n');
fprintf('============================= \n');
for il = 1:Lmax
    fprintf(' %i  %6.3f   %6.3f   %6.3f \n',il,AIC(il),SIC(il),HQC(il));
end

% Estimate first order VAR for forecasting exercise (just for illustration)
nlag = 1;
fVAR = var_ls( fdata, nlag );
AA = fVAR.coef{1};  % Matrix on lagged values


% Data transposed: column is date, row is yield
YY = data_norm';

% We start forecasting at last day in sample. Let's call it T:
FT = factors(end,1:3)';

fhorizon = 60;     % Maximum forecast horizon: 5 years

Yfore = zeros(size(YY,1),fhorizon);

for ih = 1:fhorizon
    Yfore(:,ih) = fload * AA^ih * FT;
end

% Now let's put this in a plot
time2 = (time(end)+1/12:1/12:time(end)+fhorizon/12)';
n0 = 410;
figure(10)
plot(time(n0:end),YY(:,n0:end)');
hold on
plot([time(end); time2],[YY(:,end) Yfore]','.');
hold off
axis([2005 2015 -2.2 0])
grid on
title('Actual and forecasted bond yields (dots) using the DFM','Fontsize',14)
print yields_forecasts.eps -deps2c
