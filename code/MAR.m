function [ I ] = MAR( s, f, F)
%MAR3 Summary of this function goes here
%   Detailed explanation goes here

%     [xx,yy] = meshgrid( -10:10, -10:10);
%     rr = sqrt(xx.^2 + yy.^2);
%     h = exp(-rr.^2/(2*(2)^2));
%     h = h./sum(h(:));
    
   % Filtered Back-Projection
        g = fanogramToSinogram(s,f);
        I = iradon(g,s.phi,'linear','Ram-Lak',1,size(s.x,1));
            
    % Segmentation:
            % air
            % bone
            % brain matter
            % iron
    
    u = [-1e10 0 .174, .191, .208 , 0.352,  2.90 1e10];
    I = interp1(u,u,I,'nearest');
    
    % Initial Cost
    cost(1) = sum((F*I(:) - f(:)).^2);
    
    % Gaussian Low-Pass-Filter
    [xx,yy] = meshgrid( -10:10, -10:10);
    rr = sqrt(xx.^2 + yy.^2);
    h = exp(-rr.^2/(2*(1)^2));
    h = h./sum(h(:));
    
    for ii = 1:3
        
        ii
        
        % Forward-Project Image to Sinogram
        f_hat = reshape(F*I(:), size(f));
        g_hat = fanogramToSinogram(s,f_hat);
        
        % Filtered Back-Project Measured Error
        deltaI = iradon(g-g_hat,s.phi,'linear','Ram-Lak',1,size(s.x,1));
        
        % Adjust Image
        t = linear_search(f(:), F*I(:), F*deltaI(:));
        t
        I = I + t*deltaI;
        
        % Segmentation
        Itmp = interp1(u,u,I,'nearest');
        idxBrain = Itmp>=.150 & Itmp<=.22;
        Itmp2 = I;
        Itmp2(~idxBrain) = 0;
        
        % Smooth Brain Region
        Itmp2 = conv2(Itmp2,h,'same')./conv2(double(idxBrain),h,'same');
        Itmp(idxBrain) = Itmp2(idxBrain);
        
        % Remove Brain In Air and Bone in Brain
        idxAir = Itmp == 0;
        idxBone = Itmp == .352;
        idxHead = imfill(idxBone, 'holes');
        idxBrainInAir = ~idxAir & ~idxHead;
        idxBrain = idxHead & ~idxBone;
        idxBrain = imfill(idxBrain, 'holes');
        idxBoneInBrain = idxBrain & idxBone;
        I(idxBrainInAir) =  interp1([0 .352],[0 .352],I(idxBrainInAir),'nearest');
        I(idxBoneInBrain) =  interp1([.204 2.9],[.204 2.9],I(idxBoneInBrain),'nearest');
        
        I = interp1(u,u,I,'nearest');

    end
    
    air = 0;
    metal = 2.9;
    bone = 0.352;
    brain = 0.174;
    
    idxAir = I == 0;
    idxAir = conv2(double(idxAir),ones(3),'same')>4;
    idxMetal = I == 2.9;
    idxBone = I == .352;
    idxBrain = ~idxAir & ~idxMetal & ~idxBone;

    I = zeros(size(I));
    I(idxAir) = air;
    I(idxMetal) = metal;
    I(idxBone) = bone;
    I(idxBrain) = brain;
    
    
    for ii = 1:6
        ii
        dg = fanogramToSinogram(s,f - reshape(F*I(:),size(f)));
        dI = iradon(dg,s.phi, 'linear','Ram-Lak', 1, size(I,1));    
        I = I + dI;
        I = interp1(u,u,I,'nearest');
    end
   
    
end

