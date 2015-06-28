function lambda = MVC( Ps, dPs )
    w_sum = 0;
    w = zeros( size(dPs,1), 1 );
    lambda = zeros( size(Ps,1), size(dPs,1));
    
    for jj=1:size(Ps,1)
        x = Ps(jj,:);
        
        tan1 = halfTan( x, dPs(end,:), dPs(1,:) );
        tan2 = halfTan( x, dPs(1,:), dPs(2,:) );
        d = ( (dPs(1,1)-x(1))^2 + (dPs(1,2)-x(2))^2 )^0.5;
        w(1) = (tan1 + tan2) / d;
        w_sum = w_sum + w(1);

        for ii=2:size(dPs,1)-1
            tan1 = halfTan( x, dPs(ii-1,:), dPs(ii,:) );
            tan2 = halfTan( x, dPs(ii,:), dPs(ii+1,:) );
            d = ( (dPs(ii,1)-x(1))^2 + (dPs(ii,2)-x(2))^2 )^0.5;
            w(ii) = (tan1 + tan2) / d;
            w_sum = w_sum + w(ii);
        end
        tan1 = halfTan( x, dPs(end-1,:), dPs(end,:) );
        tan2 = halfTan( x, dPs(end,:), dPs(1,:) );
        d = ( (dPs(end,1)-x(1))^2 + (dPs(end,2)-x(2))^2 )^0.5;
        w(size(dPs,1)) = (tan1 + tan2) / d;
        w_sum = w_sum + w(end);
        l = w / w_sum;
        lambda(jj,:) = l;
    end
    
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