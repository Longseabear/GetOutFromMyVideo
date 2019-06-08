fid = fopen("train_frame.txt","r");

Fs = {};

current_file_name = fgetl(fid);

file_split = strsplit(current_file_name, "/");
current_idx = file_split{end-1};

while true
    previous_file_name = fgetl(fid);
    if ~ischar(previous_file_name)
        save(sprintf("training_set/%s.mat", current_idx), "Fs")
        clear Fs
        break
    end
    file_split = strsplit(previous_file_name, "/");
    previous_idx = file_split{end-1};
    
    if strcmp(previous_idx, current_idx)==0
        save(sprintf("training_set/%s.mat", current_idx), "Fs")
        clear Fs
        Fs = {};
        current_file_name = previous_file_name;
        current_idx = previous_idx;
        continue
    end
    pre_name = "."+strtok(previous_file_name," ");
    cur_name = "."+strtok(current_file_name," ");
    
    im_p=double(imread(pre_name));
    im_c=double(imread(cur_name));
    
    [F, warped_image] = make_trainingset(im_p, im_c);
    Fs{end+1} = F;
    current_file_name = previous_file_name;
    current_idx = previous_idx;
end

fclose(fid);