function [para] = get_parameter(h,w)
%% image information
para.h=h;
para.w=w;

%% fixed point information
para.alpha=0.5; % weight of smoothness term.
para.s = 1.5; % enlarge the gaussian kernel by s when smoothing...
para.outer_iter = 1; % outer fixed point iteration
para.inner_iter = 15; % inner fixed point iteration
para.sor_iter = 25; % iteration of successive over relaxation
para.downsampling = 0.5; % down sampling by 2;
para.sigma = 1/sqrt(2*para.downsampling);  % used for pyramid construction and smooth the derivatives

para.patch_size = 4; % patch_size
% para.level = ceil(log2(min(para.h, para.w)/para.patch_size)); % 

para.downsampling = 0.95;   % downsampling rate
% para.sigma = 1.3;
para.sigma = 1/sqrt(2*para.downsampling);  % used for pyramid construction and smooth the derivatives
para.level = ceil((log(10)-log(para.h))/log(para.downsampling));            % levels of pyramid.:we need 70 for very large displacements

%% etcg
para.w = 1.99;
para.median_filtering=1;
para.medianx=5;
para.mediany=5;
para.margsz=[5 5];
para.use_mask = true;

para.verbose = 1;
end

