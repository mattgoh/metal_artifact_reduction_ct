
% build the scan geometry structure
s = buildScanGeometry;

% smiley face target
% mu = zeros(size(s.x));
%     idxLeftEye = sqrt((s.x + 120).^2 + (s.y - 120).^2) < 50;
%     idxRightEye = sqrt((s.x - 120).^2 + (s.y - 120).^2) < 50;
%     idxSmile = sqrt( (s.x).^2 + (s.y - 30).^2 ) > 200 ...
%                     & sqrt( (s.x).^2 + (s.y - 30).^2 ) < 220 ...
%                     & s.y < 0 ;
%     idxCircle = sqrt( (s.x).^2 + (s.y).^2 ) > 300 ...
%                    & sqrt( (s.x).^2 + (s.y).^2 ) < 320;
% mu(idxLeftEye) = 1;
% mu(idxRightEye) = 2;
% mu(idxSmile) = 3;
% mu(idxCircle) = 4;

% build forward projection matrix
    % this is SLOW!!
    % save matrix and skip on future steps
    
F = buildForwardProjector(s);

% apply forward projector to build fanogram
%f = buildFanogram(s,F,mu);
    % NOTE: these are the measurements a real scanner would collect

% re-bin the fanogram data into sinogram data

f = buildFanogram(s,F,mu); % GOH

g = fanogramToSinogram(s,f);

% use matlab-based reconstruction to recover mu

mu_hat = iradon(g,s.phi,'Ram-Lak', 1, size(s.x,1));

% plot everything
set(gcf,'position',[368  36  834  583])

%%
figure('position', [0, 0, 850, 650]);
subplot(2,2,1)
imagesc(s.x(1,:), s.y(:,1), mu)
caxis([0.150 0.250]); 
set(gca,'ydir','default');
axis square; axis off;
xlabel('X (mm)')
ylabel('Y (mm)')
colorbar; colormap gray;
title('a. Original Image')

subplot(2,2,2)
imagesc(s.v(1,:), s.a(:,1), f);
set(gca,'ydir','default');
axis square;
xlabel('View Angle (deg)')
ylabel('Fan Angle (deg)')
colorbar; colormap gray;
title('b. Fanogram (Measurements)')

subplot(2,2,3)
imagesc(s.x(1,:), s.y(:,1), mu_hat);
caxis([0.150 0.250]); axis off;
set(gca,'ydir','default');
axis square;
xlabel('X (mm)')
ylabel('Y (mm)')
colorbar; colormap gray;
title('c. Reconstructed Image')

subplot(2,2,4);
imagesc(s.p(1,:), s.s(:,1), g);
set(gca,'ydir','default');
axis square;
xlabel('Projection Angle (deg)')
ylabel('Linear Shift (mm)')
colorbar; colormap gray;
title('d. Sinogram (Re-binned)')
