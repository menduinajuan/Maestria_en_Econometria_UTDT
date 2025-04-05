function [nGAMA,nDELTA,nALFA,nPSI,nRHO,nOMEGA,nPHI,nR,nc,ncp,nh,nhp,nk,nkp,nk1,nk1p,nd,ndp,ni,nip,ntb,ntbp,neta,netap,nla,nlap,ny,nyp,na,nap,ntby,ntbyp,ncay,ncayp]=mendoza91_ss
%This program produces the deep structural parameters and computes the steady state of a small open economy model with an endogenous discount factor described in ``Closing Small Open Economy Models,'' by S. Schmitt-Grohe and Martin Uribe. 

%(c) Stephanie Schmitt-Grohe and Martin Uribe

%Date November 8, 2001

nGAMA = 2; %intertemporal elasticity of substitution

nDELTA = 0.1; %Depreciation rate

nALFA = 0.32; %Capital elasticity of the production function

nPSI = 0.11135;%0.11; %Minus elasticity of discount factor with respect to its argument

nRHO = 0.42; %Serial correlation of productivity shock

nOMEGA = 1.455; %exponent of labor in utility function

nPHI = 0.028; %Parameter of adjustment cost function

nR = 0.04; %world interest rate

h_over_k = ((nR+nDELTA)/nALFA)^(1/(1-nALFA)); %hours to capital ratio


nh = ((1-nALFA) * (nALFA/(nR+nDELTA)) ^ (nALFA/(1-nALFA)))^(1/(nOMEGA-1)); %hours

nc = (1+nR)^(1/nPSI) + nh^nOMEGA/nOMEGA -1; %consumption

nk = nh / h_over_k; %capital

ni = nDELTA * nk; %investment

ny = nk^nALFA * nh^(1-nALFA); %output

ntb = ny - nc - ni; %trade balance

nd = ntb/nR; %net foreign asset positioin

nU = (( nc - nh^nOMEGA/nOMEGA)^(1-nGAMA)-1)  / (1-nGAMA); %utility

nUc = ( nc - nh^nOMEGA/nOMEGA)^(-nGAMA); %marginal urility of consumption

ntby = ntb / ny;

ncay = (-nR * nd + ntb) / ny; 

nbeta = 1/(1+nR); %subjective disount rate

nbetac = -nPSI * (1+nc-nh^nOMEGA/nOMEGA)^(-nPSI-1); %derivative of discount factor wrt consumption

neta = -nU / (1-nbeta); %multiplier on evolution of discount factor

nla = nUc - neta  * nbetac; %marginal utility of wealth

nk1 = nk; %Auxiliary variable

na = 1; %Productivity shock 

%Take logs
nc = log(nc);
nh = log(nh);
nk = log(nk);
nk1 = log(nk1);
nla = log(nla);
neta = log(neta);
ny = log(ny);
ni = log(ni);
nd = log(nd);
na = log(na);

%Next-period variables
ncp=nc;
nyp= ny;
nkp=nk;
nk1p=nk;
netap = neta;
nip= ni;
nhp=nh;
ndp=nd; 
nlap=nla;
nap=na;
ntbp=ntb;
ntbyp = ntby;
ncayp = ncay;