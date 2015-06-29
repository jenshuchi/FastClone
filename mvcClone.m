function f = mvcClone( lambda, f_star, g, l, PsValue, dPsValue, dPtValue )
%
% Arguments:   
%   g:      source image intensities
%   f_star: target image intensities
%   Ps:     coordinate (x,y) of the points inside the source patch
%   Pt:     coordinate (x,y) of the points inside the output patch
%   dPs:    coordinate (x,y) of the boundary points of Ps
%   dPsValue:    intensities of the boundary points of Ps
%   dPtValue:    intensities of the boundary points of Pt
%
% Output:

%   f:      output image intensity of Pt
%
    % Preprocessing stage: Compute MVC
    %lambda = MVC( Ps, dPs );
    
    f = zeros(l,1);
    %diff = zeros(size(dPsValue,1),1);
    
    % Compute the differences along the boundary
    diff = dPtValue - dPsValue;
    %for ii=1:size(dPsValue,1)
        %x1 = round(dPs(ii,1)); 
        %y1 = round(dPs(ii,2));
        %x2 = round(dPt(ii,1)); 
        %y2 = round(dPt(ii,2));
        %diff(ii) = f_star(x2,y2) - g(x1,y1);
        %diff(ii) = dPtValue(ii) - dPsValue(ii);
    %end
    
    
    for ii=1:l
        % Evaluate the mean-value interpolant
        r = sum( lambda(ii,:) .* diff' );
        %r = 0;
        %for jj=1:size(dPs,1)
        %    r = r + lambda(ii,jj) * diff(jj);
        %end
        
        %x1 = Ps(ii,1); 
        %y1 = Ps(ii,2);
        %f(ii) = g(x1,y1) + r(ii);
        f(ii) = PsValue(ii) + r;
    end
    
end