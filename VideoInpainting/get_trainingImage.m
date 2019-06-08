fid = fopen("train_frame.txt","r");

depth_min = 1;
depth_max = 1;

total_idx = 0;

current_idx = 'none';
while true
    current_file_name = fgetl(fid);
    file_split = strsplit(current_file_name, "/");
    if ~strcmp(current_idx,file_split{end-1})
        current_idx = file_split{end-1};
        of_file = open(sprintf("./training_set/%s.mat",current_idx));
        flow_vector = cat(4, of_file.Fs{:});
    end 
    current_file_number = str2double(file_split{7}(6:13));
    cur_name = "."+strtok(current_file_name," ");
    
    for next_idx = depth_min:depth_max
        previous_file_name = current_file_name;
        file_dir = file_split + "/";
        pre_name = sprintf(".%sframe%08d.jpg",cat(2,file_dir{1:3}), uint8(current_file_number+next_idx));
        if ~isfile(pre_name)
            break
        end
        warp_vector = sum(flow_vector(:,:,:,current_file_number+1:current_file_number+next_idx),4);
        im_p=double(imread(pre_name));
        im_c=double(imread(cur_name));
        
        warped_image = warp_image(im_c,warp_vector(:,:,1),warp_vector(:,:,2));
        imwrite(uint8(im_p),sprintf("train/%010d_label.jpg", total_idx));     
        imwrite(uint8(warped_image),sprintf("train/%010d_warp.jpg", total_idx));
        total_idx = total_idx + 1;
    end
end

fclose(fid);