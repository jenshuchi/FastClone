function [ Pt, f ] = mvcClone( lambda, f_star, g, Ps, dPs )
%
% Arguments:   
%   g:      source image intensities
%   f_star: target image intensities
%   Ps:     coordinate (x,y) of the points inside the source patch
%   dPs:    coordinate (x,y) of the boundary points of Ps
%
% Output:
%   Pt:     coordinate (x,y) of the points inside the output patch
%   f:      output image intensity of Pt
%
    % Preprocessing stage: Compute MVC
    %lambda = MVC( Ps, dPs );
    
    f = zeros(size(Ps,1),1);
    Pt = Ps;
    diff = zeros(size(dPs,1));
    
    % Compute the differences along the boundary
    for ii=1:size(dPs,1)
        diff(ii) = f_star( dPs(ii) ) - g( dPs(ii) );
    end

    for ii=1:size(Pt,1)
        % Evaluate the mean-value interpolant
        r = 0;
        for jj=1:size(dPs,1)
            r = r + lambda(ii,jj) * diff(jj);
        end
        f(ii) = g(Ps(ii)) + r(ii);
    end
    
end