function [ F ] = buildForwardProjector( scanGeometry )
    
    S=fields(scanGeometry);
    for ii = 1:length(S)
        eval([S{ii}, ' = scanGeometry.', S{ii}, ';']) 
    end
    clear S scanGeometry
    
    N = Nx*Ny;
    M = Nv*Na;
    
    sizeThreshold = 1e8;
    if (M > sizeThreshold)
        error('M is too large')
    end
    
    sx = d.*cosd(v); % mm (x position of source)
    sy = d.*sind(v); % mm (y position of source)
    m = sind(fp)./cosd(fp); % line-of-response slope
    b = sy-m.*sx; % line-of-response y-intercept
   
    x1 = x - (dx/2);
    x2 = x + (dx/2);
    y3 = y - (dy/2);
    y4 = y + (dy/2);
    
    max_rows = floor(sizeThreshold/N);
    F = sparse(M,N);
    Ftmp = zeros(max_rows, N);

    tic

    ii = 1;
    n = 0;
    for mm = 1:M
        
        x3 = (y3 - b(mm))./m(mm);
        x4 = (y4 - b(mm))./m(mm);
        y1 = m(mm).*x1 + b(mm);
        y2 = m(mm).*x2 + b(mm);
        
        idx1 = y3 < y1 & y1 < y4;
        idx2 = y3 < y2 & y2 < y4;
        idx3 = x1 < x3 & x3 < x2;
        idx4 = x1 < x4 & x4 < x2;

        idx12 = idx1 & idx2;
        idx13 = idx1 & idx3;
        idx14 = idx1 & idx4;
        idx23 = idx2 & idx3;
        idx24 = idx2 & idx4;
        idx34 = idx3 & idx4;

        distance = zeros(size(x));
        distance(idx12) = sqrt((x1(idx12) - x2(idx12)).^2 + (y1(idx12) - y2(idx12)).^2);
        distance(idx13) = sqrt((x1(idx13) - x3(idx13)).^2 + (y1(idx13) - y3(idx13)).^2);
        distance(idx14) = sqrt((x1(idx14) - x4(idx14)).^2 + (y1(idx14) - y4(idx14)).^2);
        distance(idx23) = sqrt((x2(idx23) - x3(idx23)).^2 + (y2(idx23) - y3(idx23)).^2);
        distance(idx24) = sqrt((x2(idx24) - x4(idx24)).^2 + (y2(idx24) - y4(idx24)).^2);
        distance(idx34) = sqrt((x3(idx34) - x4(idx34)).^2 + (y3(idx34) - y4(idx34)).^2);

        Ftmp(ii,:) = distance(:)/dx;
        ii = ii + 1;

        if (mod(ii-1,max_rows) == 0 || mm == M)

            mm/M
            
            numRows = min([max_rows M-n*max_rows]);

            F((1:numRows) + n*max_rows, :) = Ftmp(1:numRows,:);

            Ftmp = Ftmp*0;
            n = n +1;
            ii = 1;
            toc
            tic               
        end


    end
        
end