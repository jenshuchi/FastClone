function [ Pt, f ] = mvcClone( f_star, g, Ps, dPs )
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
    lambda = zeros( size(Ps,1), size(dPs,1));
    
    % Preprocessing stage: Compute MVC
    for ii=1:size(Ps,1)
        lambda(ii,:) = MVC( Ps(ii), dPs );
    end
    
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

function l = MVC( x, dPs )
    w_sum = 0;
    w = zeros(size(dPs,1),1);
    
    tan1 = halfTan( x, dPs(end,:), dPs(1,:) );
    tan2 = halfTan( x, dPs(1,:), dPs(2,:) );
    d = ( (dPs(1,1)-x(1))^2 + (dPs(1,2)-x(2))^2 )^0.5;
    w(1) = (tan1 + tan2) / d;
    w_sum = w_sum + w(1);
    
    for ii=2:size(dPs,1)
        tan1 = halfTan( x, dPs(ii-1,:), dPs(ii,:) );
        tan2 = halfTan( x, dPs(ii,:), dPs(ii+1,:) );
        d = ( (dPs(ii,1)-x(1))^2 + (dPs(ii,2)-x(2))^2 )^0.5;
        w(ii) = (tan1 + tan2) / d;
        w_sum = w_sum + w(ii);
    end
    l = w / w_sum;
end

function  t = halfTan( x, p1, p2 )
    v1 = [ x(1)-p1(1), x(2)-p1(2) ];
    d1 = ( v1(1)^2 + v1(2)^2 )^0.5;
    v2 = [ x(1)-p2(1), x(2)-p2(2) ];
    d2 = ( v2(1)^2 + v2(2)^2 )^0.5;
    
    c = (v1(1)*v2(1) + v1(2)*v2(2)) / (d1*d2);
    c = ( (1+c)/2 )^0.5;
    theta = acos(c);
    s = cos(pi/2 - theta);
    t = s / c;
end