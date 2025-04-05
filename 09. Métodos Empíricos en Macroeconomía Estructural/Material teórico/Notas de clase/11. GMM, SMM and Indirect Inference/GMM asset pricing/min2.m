% min2.m
%/* quick one dimensional brute force minimizer */

function [gam,Jt,gTl,ut] = min2(W,xt,pt,gamtol,tester,dc)
    gamlo = -1000;
    gamhi = 1000;
    while (gamhi - gamlo) > gamtol;
        gamv = (gamlo:(gamhi-gamlo)/10:gamhi)';
        Jt = zeros(size(gamv,1),1);
        i = 1;
        dcbig = dc*ones(1,size(xt,2)); 
        while i <= size(gamv,1);
            ut = (dcbig.^-gamv(i)).*xt-pt;
            gTl = mean(ut)';
            Jt(i) = gTl'*W*gTl;
            i = i+1;
        end;
        if tester;
            disp(gamv');
            disp(Jt')
        end;
        [~, mini] = min(Jt);
        if ((mini == 1) || (mini == size(Jt,1)));
            disp('Error: minimum is outside assumed gamma range');
        end;
        gamlo = gamv(mini-1);
        gamhi = gamv(mini+1);
    end;
    gam = gamv(mini);
    Jt = Jt(mini);
    ut = (dcbig.^-gamv(mini)).*xt-pt;
    gTl = mean(ut)';
return; 
