function [F]=LDOF(imfile1,imfile2,imfile_mask1,imfile_mask2,para,verbose)

im1=imread(imfile1);
im2=imread(imfile2);
im1=double(im1);
im2=double(im2);

mask1=imread(imfile_mask1);
mask2=imread(imfile_mask2);
mask1=double(mask1);
mask2=double(mask2);

F = variational_descriptor_flow(im1,im2,mask1,mask2,...
    para,verbose);