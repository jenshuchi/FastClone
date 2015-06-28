function f = mvcClone( lambda, f_star, g, Ps, Pt, dPs, dPt )
%
% Arguments:   
%   g:      source image intensities
%   f_star: target image intensities
%   Ps:     coordinate (x,y) of the points inside the source patch
%   Pt:     coordinate (x,y) of the points inside the output patch
%   dPs:    coordinate (x,y) of the boundary points of Ps
%
% Output:

%   f:      output image intensity of Pt
%
    % Preprocessing stage: Compute MVC
    %lambda = MVC( Ps, dPs );
    
    f = zeros(size(Ps,1),1);
    diff = zeros(size(dPs,1));
    
    % Compute the differences along the boundary
    for ii=1:size(dPs,1)
        x1 = round(dPs(ii,1)); 
        y1 = round(dPs(ii,2));
        x2 = round(dPs(ii,1)); 
        y2 = round(dPt(ii,2));
        diff(ii) = f_star(x2,y2) - g(x1,y1);
    end

    for ii=1:size(Pt,1)
        % Evaluate the mean-value interpolant
        r = sum( lambda(ii,:) .* diff' );
        %r = 0;
        %for jj=1:size(dPs,1)
        %    r = r + lambda(ii,jj) * diff(jj);
        %end
        x1 = Ps(ii,1); 
        y1 = Ps(ii,2);
        f(ii) = g(x1,y1) + r(ii);
    end
    
end