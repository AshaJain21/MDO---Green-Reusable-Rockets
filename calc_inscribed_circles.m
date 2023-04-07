function noPipes = calc_inscribed_circles(rs, rl)

%   rl = dl/2;
%   rs = ds/2;
  
  if (rl > 0 && rs > 0)
    noPipes = 0;
    rc = rl - rs;
        if (rs > rl) 
          disp("Inside smaller diameters larger than outside diameter!");
        elseif (rl < 2 * rs)
%           disp("Only 1 pipe fits!")
          noPipes = 1;
        else
        noPipes = count_circlces(rs, rc);
        end
  end
end
  
function noPipes = count_circlces(rs, rc)
    noPipes = 0;
    
    while rc >= rs
        no = floor((2 * pi * rc) / (2 * rs));
        x0 = rc * cos(0 * 2 * pi / no);
        y0 = rc * sin(0 * 2 * pi / no);
        x1 = rc * cos(1 * 2 * pi / no);
        y1 = rc * sin(1 * 2 * pi / no);
        dist = ((x0 - x1)^2 + (y0 - y1)^2)^0.5;

        if (dist < (2 * rs)) 
            no = no - 1;
        end

        noPipes = noPipes + no;
        
        oldrc = rc;
        rc = rc - (2 * rs);

    end
    if oldrc > (2*rs)
        noPipes = noPipes + 1;
    end
end
	
