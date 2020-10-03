function [ g ] = fanogramToSinogram( scanGeometry, f )

    in = scatteredInterpolant(scanGeometry.fp(:),scanGeometry.fs(:),f(:),'linear','linear');
    g = in(scanGeometry.p, scanGeometry.s);

end

