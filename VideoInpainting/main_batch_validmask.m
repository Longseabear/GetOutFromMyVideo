function [F, warped_image, valid_mask, already_refine_mask] = main_batch_validmask(pre_image,current_image,pre_mask,current_mask, already_refine_region)
% mask 0~1
% image 0~255

% 2/99
[h,w,~] = size(pre_image);
info = get_parameter(h,w);

info.verbose = 0;

flow_vector = mask_of(pre_image, current_image, pre_mask, current_mask, info);
F  = flow_vector;

im1=pre_image; %
im2=current_image;
mask=double(pre_mask); %
mask2=double(current_mask);
flow_warp(im1,im2,flow_vector,1)

warped_image = warp_image(im2,flow_vector(:,:,1),flow_vector(:,:,2));
%figure,imshow((1-mask).*double(im1)./255 + mask.*I2warped./255);

mask2_warped = warp_image(mask2, flow_vector(:,:,1), flow_vector(:,:,2));
mask2_warped(mask2_warped<0.1)=0;
mask2_warped(mask2_warped~=0)=1;

valid_mask = mask-mask2_warped;
valid_mask(valid_mask<0) = 0;
valid_mask = uint8(valid_mask);

already_refine_mask = warp_image(already_refine_region, flow_vector(:,:,1), flow_vector(:,:,2));
already_refine_mask(already_refine_mask<0.1)=0;
already_refine_mask(already_refine_mask~=0)=1;

end

