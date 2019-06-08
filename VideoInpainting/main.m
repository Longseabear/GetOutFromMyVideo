% 2/99
pre_image ='temp_frames/frame00000064.jpg';
current_image ='temp_frames/frame00000083.jpg';

pre_mask='temp_frames_mask/frame00000064.jpg';
current_mask='temp_frames_mask/frame00000083.jpg'; 

temp_image = imread(pre_image); % image load for size
[h,w,~] = size(temp_image);
info = get_parameter(h,w);

im_p=double(imread(pre_image));
im_c=double(imread(current_image));

mask_p=double(imread(pre_mask));
mask_c=double(imread(current_mask));

flow_vector = mask_of(im_p, im_c, mask_p, mask_c, info);

im1=imread(pre_image); % 
im2=imread(current_image);
mask=double(imread(pre_mask))./255; % 

flow_warp(im1,im2,flow_vector,1)

I2warped=warp_image(im2,flow_vector(:,:,1),flow_vector(:,:,2));
figure,imshow((1-mask).*double(im1)./255 + mask.*I2warped./255);

