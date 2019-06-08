fid = fopen('train_frame.txt','w');

for i=0:20
    fprintf(fid,'/JPEGImages/temp_frames/frame%08d.jpg /JPEGImages/temp_frames_mask/frame%08d.jpg\n',i,i);
end

fclose(fid)