function [ f ] = buildFanogram( scanGeometry, forwardProjector, mu)
%BUILDFANOGRAM Summary of this function goes here
%   Detailed explanation goes here
    
    f = reshape(forwardProjector*mu(:),size(scanGeometry.v));

end

