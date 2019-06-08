function [F, warped_image, valid_mask] = make_trainingset(pre_image,current_image)
% mask 0~1
% image 0~255

% 2/99
[h,w,~] = size(pre_image);
info = get_parameter(h,w);

info.verbose = 0;
info.use_mask=false;

pre_mask = zeros(h,w);
current_mask = zeros(h,w);

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
mask2_warped(mask2_warped<0.5)=0;
mask2_warped(mask2_warped~=0)=1;

valid_mask = mask-mask2_warped;
valid_mask(valid_mask<0) = 0;
valid_mask = uint8(valid_mask);
end

