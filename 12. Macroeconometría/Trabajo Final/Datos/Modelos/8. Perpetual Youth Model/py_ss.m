function [nDELTA,nALFA,nRHO,nOMEGA,nPHI,nR,nc,ncp,nh,nhp,nk,nkp,nk1,nk1p,nd,ndp,ni,nip,ntb,ntbp,nla,nlap,ny,nyp,na,nap,ntby,ntbyp,ncay,ncayp, nzztil,nzztilp, nXBAR, nTHETA, nBETTA,dist]=py_ss(nRinput);
%This program produces the deep structural parameters and computes the steady state of a small open economy with a perpetual youth described in ``Lecture in Open Economy Macroeconomics,'' by Martin Uribe.
%The default value for the interest rate is 3.7451 percent, and was obtained by running the program find_interest_rate_ss.m.  
%
%(c) Martin Uribe, April 2009
%
%The notation in this file differs from the notation in the notes as follows: what in the notes is calls z, here is called zz. What in the notes is called ztilde, here is called zztil

if nargin<1
nRinput =    0.0374509; %this value was found by running find_interest_rate_ss.m 
end

nDELTA = 0.1; %Depreciation rate

nALFA = 0.32; %Capital elasticity of the production function

nRHO = 0.42; %Serial correlation of productivity shock

nOMEGA = 1.455; %exponent of labor in utility function

nPHI = 0.028; %Parameter of adjustment cost function

nR = nRinput;

nBETTA =  1/1.04; %subjective discount factor

nSIGG = 2; %curvature of period utility with respect to x. That is, SIGG = -x/(x-XBAR)

TBY = 0.02; %trade balance to output ratio

nTHETA = 1-1/75; %Probability of surviging the current period, implying a life expectancy of 75 years. 

h_over_k = ((1/nBETTA-1+nDELTA)/nALFA)^(1/(1-nALFA)); %hours to capital ratio

nh = ((1-nALFA) * h_over_k^(-nALFA))^(1/(nOMEGA-1)); %hours

nk = nh / h_over_k; %capital

ni = nDELTA * nk; %investment

ny = nk^nALFA * nh^(1-nALFA); %output

nd = TBY*ny/nR; %debt

ntb = TBY*ny; %trade balance

nc = ny - ntb - ni; %consumption

nx = nc - nh^nOMEGA/nOMEGA ; %argument of period utility function

nXBAR = nx * (1+nSIGG)/nSIGG; %satiation point (set to match a degree of realtive risk aversion of 2 in the steady state). 

npai = nALFA*ny - ni; %profits of capital producing firms

nzz = npai + (1-1/nOMEGA) * (1-nALFA) * ny - nXBAR;

nzztil = nTHETA / (1 + nR - nTHETA) * nzz; %present discounted value of nzz

nla = -(nx - nXBAR); %marginal utility of consumption

ntby = ntb / ny; %trade-balance-to-output ratio

ncay = (-nR * nd + ntb) / ny;  %current-account-to-output ratio

nk1 = nk; %Auxiliary variable

na = 1; %productivity shock 

ndp = nd;
nzztilp = nzztil;

cc = nTHETA * (1-nBETTA*(1+nR)) / ((1+nR-nTHETA)*(nTHETA-nBETTA*(1+nR)));

%the following expression is the distance between the value of debt implied by our calibration of TBY and the value of debt impoied by the steady state
dist = abs(nd-cc*nzz);

%Apply logs
nc = log(nc);
nh = log(nh);
nk = log(nk);
nk1 = log(nk1);
nla = log(nla);
ny = log(ny);
ni = log(ni);
na = log(na);

%Next-period variables
ncp=nc;
nyp= ny;
nkp=nk;
nk1p=nk;
nip= ni;
nhp=nh;
nlap=nla;
nap=na;
ntbp=ntb;
ntbyp = ntby;
ncayp = ncay;