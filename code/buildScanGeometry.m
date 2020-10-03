function [ scanGeometry ] = buildScanGeometry(  )

% buildScanGeometry: builds scanGeometry structure
        % no arguments (change code directly to change geometry)
% scanGeometry: contains parameters needed for sim. and recon.

% Matt Tivnan
% EECE5664 - Biomedical Signal Processing and Medical Imaging
% tivnan.m@husky.neu.edu

    % Set up a meshgrid (x-y position of every voxel;
        % change these lines
            Nx = 201; % (number of x pixels)
            Ny = 201; % (number of y pixels)
            xmin = -400; % mm (min x position)
            xmax = +400; % mm (max x position)
            ymin = -400; % mm (min y position)
            ymax = +400; % mm (max y position)

        % don't change these lines
            dx = (xmax - xmin)/(Nx-1); % mm (x pixel resolution)
            dy = (ymax - ymin)/(Ny-1); % mm (y pixel resolution)
            [x, y] = meshgrid(linspace(xmin,xmax,Nx), linspace(ymin,ymax,Ny));

    % Scanner geometry and fanogram meshgrid
        % change these lines
            d = 600; % mm (source-to-center distance) 
            Nv = 201; % (number of views per rotation)
            Na = 201; % (number of fan angles per view)
            amin = -45; % degrees (min fan angle)
            amax = +45; % degrees (max fan angle)
        % don't change these lines
            da = (amax - amin)/(Na-1); % degrees (fan angle resolution)
            dv = (360)/(Nv); % degrees (view angle resolution)
            [v,a] = meshgrid((1:Nv)*dv,linspace(amin,amax,Na));
                   
            
    % Sinogram meshgrid corresponding to fanogram meshgrid
        % dont' change these lines
                % temporary
                    %ra = (v + 180) + a; % degrees (ray angle or ray propagation direction)
                    %p = mod(ra,180); % degrees (projection angle)
            fp = mod(v+a,180); % degrees (projection angle)
            % temporary
                    %sx = d*cosd(v); % mm (x position of source)
                    %sy = d*sind(v); % mm (y position of source)
                    %m = sind(p)/cosd(p); % line-of-response slope
                    %b = sy-m.*sx; % line-of-response y-intercept
                    %s = b*cosd(p); % sinogram translation
                    %s = d.*(cosd(p).*sind(v)-*sind(p).*cosd(v)); % mm (s-value of sinogram)
                    %s = d.*sind(v - p)
            fs = d.*sind(v - fp);
        % limit angle to (0 180] degree range

        
    % Sinogram meshgrid
        % don't change this
            Np = floor(Nv/2) + 1;
                % temporary
                    r = radon(x, (pi/Np)*(1:Np));
                    [Ns, Np]  = size(r);
                    clear r;
            [p,s] = meshgrid((180/Np)*(1:Np), dx*(1:Ns));
            phi = 270 - (180/Np)*(1:Np) ;
            s = s - mean(s(:));
            
        
    
    % Hacky way to load all variables into scannerGeometry structure
                        
            S=whos;
            for ii = 1:length(S)
                eval(['scanGeometry.', S(ii).name, ' = ', S(ii).name, ';']) 
            end
end

