Fs = {};
for i=0:102
    cur_idx = i;
    pre_idx = i+1;
    cur_name = sprintf("temp_frames/frame%08d.jpg", cur_idx);
    pre_name = sprintf("temp_frames/frame%08d.jpg", pre_idx);
    cur_mask = sprintf("temp_frames_mask/frame%08d.jpg", cur_idx);
    pre_mask = sprintf("temp_frames_mask/frame%08d.jpg", pre_idx);
    
    if i==0        
        im_p=double(imread(pre_name));
        im_c=double(imread(cur_name));
        
        mask_p=double(imread(pre_mask))/255.;
        mask_c=double(imread(cur_mask))/255.;        
    else
        im_p=double(imread(pre_name));
        mask_p=double(imread(pre_mask))/255.;
    end
    [F, warped_image, valid_mask] = main_batch(im_p, im_c, mask_p,mask_c);
    Fs{end+1} = F;
    
    im_c = (1-valid_mask).*uint8(im_p) + valid_mask.*uint8(warped_image);
    imwrite(im_c,sprintf("temp_frames_result/frame%08d.jpg", pre_idx));
    mask_c = mask_p - double(valid_mask);
    imwrite(mask_c,sprintf("temp_frames_resultMask/frame%08d.jpg", pre_idx));
end
save(sprintf("Fs.mat"), "Fs")