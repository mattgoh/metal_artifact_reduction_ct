clear;

addpath(genpath('E:\Dropbox\5664_Biomedical_Signal_Processing\Project')) % win

%addpath(genpath('/Users/sg/Dropbox/5664_Biomedical_Signal_Processing/')) % mac

%%
load('MAR_data.mat')
load('mu.mat');
% s: scan geometry
% f: fanogram measurements
% g: re-binned sinogram representation of f

% straight back-projection
mu_BP = iradon(g,s.phi,'linear','none',1,size(s.x,1));

% filtered back-projection
mu_FBP = iradon(g,s.phi,'linear','Ram-Lak',1,size(s.x,1));

% display the result
imagesc(s.x(1,:), s.y(:,1), mu_FBP);
colormap gray;
colorbar;
caxis([0.150 0.250]);
set(gca,'ydir','default');
xlabel('X (mm)')
ylabel('Y (mm)')

%% GOH

metal = mu_FBP > 0.25;

seg = mu_FBP - metal;
imagesc(seg);

colormap gray;
colorbar;
caxis([0.150 0.250]);
set(gca,'ydir','default');
xlabel('X (mm)')
ylabel('Y (mm)')


%% Non local means
i = 0;
for h=1:2:10
    i=i+1;
    mu_FBP_nlm{i} = NLmeansfilter(mu_FBP,h,3,1);
end

% imagesc(mu_FBP_nlm);
figure('position', [0, 0, 1500, 250]);
for j = 1:i
    subplot(1,i,j); imagesc(mu_FBP_nlm{j});
    colormap gray;
    caxis([0.150 0.250]);
    set(gca,'ydir','default');
    xlabel('X (mm)')
    ylabel('Y (mm)')
end