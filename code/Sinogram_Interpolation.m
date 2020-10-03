function [metal_mu] = Sinogram_Interpolation( s, mu_hat, g, mu)
%mu_hat is the reconstructed image
%g is the original sinogram
%s is the scanner geometry output

% image = iradon(g,s.phi,'Ram-Lak', 1, size(s.x,1));
% imagesc(image)

%create metal-only mask image
metal_only = zeros(size(mu_hat));
metal_ind = find(mu_hat > 0.2*max(max(mu_hat)));
metal_only(metal_ind) = mu_hat(metal_ind);
metal_sinogram = radon(metal_only, s.phi);
metal_sin_ind = find(metal_sinogram~=0);
[metal_sin_row, metal_sin_col] = find(metal_sinogram~=0);
[nonmetal_row, nonmetal_col] = find(metal_sinogram==0);
metal_rep = g;

% 
% %remove metal only sinogram from original sinogram
 metal_rep(metal_sin_ind) = 0;

 tmp1 = metal_rep;
 tmp2 = metal_rep;
 tmp3 = metal_rep;
 
 metal_sin_i = [metal_sin_row, metal_sin_col];
 nonmetal_i = [nonmetal_row, nonmetal_col];
 
 for i = 1:length(nonmetal_row)
     V1(i) = g(nonmetal_row(i), nonmetal_col(i));
 end
% keyboard
  %% linear interpolation
  F = scatteredInterpolant(nonmetal_i, V1', 'natural');
  F2 = scatteredInterpolant(nonmetal_i, V1', 'linear');
  F3 = scatteredInterpolant(nonmetal_i, V1', 'nearest');
 %%
 for i = 1:length(metal_sin_i)
     V2(i) = F(metal_sin_row(i), metal_sin_col(i));
     V3(i) = F2(metal_sin_row(i), metal_sin_col(i));
     V4(i) = F3(metal_sin_row(i), metal_sin_col(i));
     metal_rep(metal_sin_row(i), metal_sin_col(i)) = V2(i);
     tmp2(metal_sin_row(i), metal_sin_col(i)) = V3(i);
     tmp3(metal_sin_row(i), metal_sin_col(i)) = V4(i);
 end

 tmp = iradon(tmp1, s.phi,'linear','Ram-Lak',1,size(s.x,1));
 metal_mu = iradon(metal_rep, s.phi,'linear','Ram-Lak',1,size(s.x,1));
 metal_mu2 = iradon(tmp2, s.phi,'linear','Ram-Lak',1,size(s.x,1));
 metal_mu3 = iradon(tmp3, s.phi,'linear','Ram-Lak',1,size(s.x,1));
 
 
 tmp(metal_ind) = mu_hat(metal_ind);
 metal_mu(metal_ind) = mu_hat(metal_ind);
 metal_mu2(metal_ind) = mu_hat(metal_ind);
 metal_mu3(metal_ind) = mu_hat(metal_ind);
 


 
 
 %%Pixel Classification
 %%Values are determined by visually examining a histogram
 
thresh1 = 0.1;
thresh2 = 0.25;
thresh3 = 0.4;

average1 = mean(metal_mu(metal_mu<thresh1));
average2 = mean(metal_mu(metal_mu<thresh2 & metal_mu>thresh1));
average3 = mean(metal_mu(metal_mu<thresh3 & metal_mu>thresh2));
average4 = mean(metal_mu(metal_mu>thresh3));

for i = 1:size(metal_mu, 1)
    for j = 1:size(metal_mu, 2)
        if (metal_mu(i,j)<thresh1)
            mu_class(i,j)=average1;
        elseif (metal_mu(i,j)<thresh2 && metal_mu(i,j)>thresh1)
            mu_class(i,j)=average2;
        elseif (metal_mu(i,j)<thresh3 && metal_mu(i,j)>thresh2)
            mu_class(i,j)=average3;
        else 
            mu_class(i,j)=average4;
        end
    end
end
 
class_sinogram = radon(mu_class, s.phi);
%keyboard
difference = g-class_sinogram;
correction_sinogram = zeros(size(class_sinogram));
correction_sinogram(metal_sin_ind) = difference(metal_sin_ind);

correction_image = iradon(correction_sinogram,s.phi,'linear','Ram-Lak',1,size(s.x,1));

MAR_2 = mu_hat - correction_image;

cost1 = sum(( metal_mu(:) - mu(:)).^2);
cost2 = sum(( MAR_2(:) - mu(:)).^2);
disp(cost1)
disp(cost2)

%%
WIDTH = 750;
HEIGHT = 500;
% keyboard
figure('position', [0,0,WIDTH, HEIGHT])
subplot(2, 2, 2)
imagesc(mu_hat)
title('Original Image')
colormap gray
colorbar
caxis([0 0.6])
subplot(2, 2, 1)
imagesc(g)
title('Original Sinogram')
colormap gray
colorbar
subplot(2, 2, 4)
imagesc(metal_only)
colorbar
colormap gray
title('metal only Image')
subplot(2, 2, 3)
imagesc(metal_sinogram)
colorbar
colormap gray
title('Metal only sinogram')



figure('position', [0, 0, WIDTH, HEIGHT])
imagesc(MARless)
colorbar
title('Metal replaced image')
colormap gray

figure('position', [0, 0, WIDTH, HEIGHT])
imagesc(metal_rep)
title('Metal replaced sinogram of the image')
xlabel('Angle (degrees)')
ylabel('distance along projection')
colormap gray
figure('position', [0, 0, WIDTH, HEIGHT])
imagesc(metal_mu)
title('1st MAR image')
xlabel('Angle (degrees)')
ylabel('distance along projection')
colorbar
caxis([0 0.6])
colormap gray
figure('position', [0, 0, WIDTH, HEIGHT])
imagesc(mu_class)
title('Segmented image')
xlabel('Angle (degrees)')
ylabel('distance along projection')
colorbar
caxis([0 0.6])
colormap gray
figure('position', [0, 0, WIDTH, HEIGHT])
imagesc(class_sinogram)
title('Segmented sinogram')
xlabel('Angle (degrees)')
ylabel('distance along projection')
colorbar
colormap gray
figure('position', [0, 0, WIDTH, HEIGHT])
imagesc(difference)
title('difference image')
xlabel('Angle (degrees)')
ylabel('distance along projection')
colorbar
colormap gray
figure('position', [0, 0, WIDTH, HEIGHT])
imagesc(correction_sinogram)
title('correction sinogram')
xlabel('Angle (degrees)')
ylabel('distance along projection')
colorbar
colormap gray
figure('position', [0, 0, WIDTH, HEIGHT])
imagesc(correction_image)
title('correction image')
xlabel('Angle (degrees)')
ylabel('distance along projection')
colorbar
caxis([0 1])
caxis('auto')
colormap gray
figure('position', [0, 0, WIDTH, HEIGHT])
imagesc(MAR_2)
title('2nd MAR Image')
colorbar
caxis([0 0.6])
colormap gray
% %metal_only sinogram
% % metal_sinogram = radon(metal_only, 0:100);
% % image = iradon(metal_sinogram,s.phi,'Ram-Lak', 1, size(s.x,1));
% % metal_replaced = g - metal_sinogram;
% % figure
% % imagesc(image)
% % figure
% % imagesc(metal_sinogram)
end

