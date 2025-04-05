function [nGAMA,nDELTA,nALFA,nPSI,nRHO,nOMEGA,nPHI,nR,nDBAR,nc,ncp,nh,nhp,nk,nkp,nk1,nk1p,nd,ndp,ni,nip,ntb,ntbp,nla,nlap,ny,nyp,na,nap,ntby,ntbyp,ncay,ncayp]=deir_ss
%This program produces the deep structural parameters and computes the steady state of a small open economy with a debt-elastic interest-rate premium described in ``Closing Small Open Economy Models,'' by S. Schmitt-Grohe and Martin Uribe. 

%(c) Stephanie Schmitt-Grohe and Martin Uribe

%Date November 8, 2001

nGAMA = 2; %intertemporal elasticity of substitution

nDELTA = 0.1; %Depreciation rate

nALFA = 0.32; %Capital elasticity of the production function

nPSI = 0.11135/150;%parameter of portfolio adjustment cost function (set so as to match sd of cay in Mendoza91). 

nRHO = 0.42; %Serial correlation of productivity shock

nOMEGA = 1.455; %exponent of labor in utility function

nPHI = 0.028; %Parameter of adjustment cost function

nR = 0.04; %world interest rate

nDBAR =  0.74421765717098; %parameter of interest-rate-premium function

h_over_k = ((nR+nDELTA)/nALFA)^(1/(1-nALFA)); %hours to capital ratio

nh = ((1-nALFA) * (nALFA/(nR+nDELTA)) ^ (nALFA/(1-nALFA)))^(1/(nOMEGA-1)); %hours

nd =  nDBAR; %foreign debt

nk = nh / h_over_k; %capital

ni = nDELTA * nk; %investment

ny = nk^nALFA * nh^(1-nALFA); %output

ntb = nd * nR; %net foreign debt position

nc = ny - ntb - ni; %trade balance

ntby = ntb / ny;

ncay = (-nR * nd + ntb) / ny; 

nbeta = 1/(1+nR); %subjective disount rate

nUc = ( nc - nh^nOMEGA/nOMEGA)^(-nGAMA); %marginal urility of consumption

nla = nUc; %marginal utility of wealth

nk1 = nk; %Auxiliary variable

na = 1; %productivity shock 

%Apply logs
nc = log(nc);
nh = log(nh);
nk = log(nk);
nk1 = log(nk1);
nla = log(nla);
ny = log(ny);
ni = log(ni);
nd = log(nd);
na = log(na);

%Next-period variables
ncp=nc;
nyp= ny;
nkp=nk;
nk1p=nk;
nip= ni;
nhp=nh;
ndp=nd; 
nlap=nla;
nap=na;
ntbp=ntb;
ntbyp = ntby;
ncayp = ncay;
