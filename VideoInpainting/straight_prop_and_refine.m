function straight_prop_and_refine(img_folder_path, mask_folder_path, out_img_path, out_mask_path, direction, all_zero_mask)

disp('strait_prop_and_refine')
%% direction 1 -> forward // direction -1 backward
[inum,~] = size(dir(strcat(img_folder_path,'/*.jpg')));

assert(direction==1 || direction==-1)
if direction == 1
    range = 0:inum-2;
else
    range = inum:-1:1;
end

first_bit = 0;
for i=range
    disp(sprintf("Current -> %d", i));
    
    cur_idx = i;
    pre_idx = i+direction;
    cur_name = sprintf("%s/frame%08d.jpg", img_folder_path, cur_idx);
    pre_name = sprintf("%s/frame%08d.jpg", img_folder_path, pre_idx);
    cur_mask = sprintf("%s/frame%08d.jpg", mask_folder_path,cur_idx);
    pre_mask = sprintf("%s/frame%08d.jpg", mask_folder_path,pre_idx);
    
    if first_bit==0
        im_p=double(imread(pre_name));
        im_c=double(imread(cur_name));
        
        mask_p=double(imread(pre_mask))/255.;
        mask_p(mask_p>0.5)=1;
        mask_p(mask_p~=1)=0;

        mask_c=double(imread(cur_mask))/255.;
        first_bit = 1;
    else
        im_p=double(imread(pre_name));
        mask_p=double(imread(pre_mask))/255.;
        mask_p(mask_p>0.5)=1;
        mask_p(mask_p~=1)=0;
    end
    if all_zero_mask
        mask_c(mask_c~=0) = 0;
    end
    
    [isMask, ~] = size(mask_p(mask_p>0));

    if isMask>0
        [~, warped_image, valid_mask] = main_batch(im_p, im_c, mask_p,mask_c);
        im_c = (1-valid_mask).*uint8(im_p) + valid_mask.*uint8(warped_image);
        imwrite(im_c,sprintf("%s/frame%08d.jpg", out_img_path,pre_idx));
        mask_c = mask_p - double(valid_mask);
        imwrite(mask_c,sprintf("%s/frame%08d.png", out_mask_path, pre_idx));
    else
        im_c = uint8(im_p);
        imwrite(im_c,sprintf("%s/frame%08d.jpg", out_img_path,pre_idx));
        mask_c = mask_p;
        imwrite(mask_c,sprintf("%s/frame%08d.png", out_mask_path, pre_idx));
    end 
end
end