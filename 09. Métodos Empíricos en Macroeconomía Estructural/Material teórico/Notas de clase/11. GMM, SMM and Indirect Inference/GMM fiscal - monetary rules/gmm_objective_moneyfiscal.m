function [objective, moments, mm] = gmm_objective_moneyfiscal(b,Y1,Y2,X1,X2,Z1,Z2,W)

nx1 = size(X1,2);

[moments1, mm1] = gmm_moments(Y1,X1,Z1,b(1:nx1));
[moments2, mm2] = gmm_moments(Y2,X2,Z2,b(nx1+1:end));

moments = [moments1 moments2]';
mm  = [mm1 mm2];

objective = moments'*W*moments;