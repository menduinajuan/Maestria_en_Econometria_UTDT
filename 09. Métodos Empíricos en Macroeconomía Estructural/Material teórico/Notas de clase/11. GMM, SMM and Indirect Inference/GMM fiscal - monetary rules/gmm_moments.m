function [moments, mm] = gmm_moments(Y,X,Z,b)
% This computes the sample moments (Y-X*b)*Z where Z are the instruments

mm = bsxfun(@times,Y-X*b,Z);    % This is the residual at time t multiplied by the instruments at time t
moments  = mean(mm);            % This is the sample average of the previous variables
