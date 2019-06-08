function im_pyramid=getGaussianPyramid(im,level)
[h,w,~]=size(im);
im_pyramid = cell(level,1);

I = im;
for i=1:level    
    if i>1
        I = impyramid(I, 'reduce');
    end
    im_pyramid{i} = I;
end
end

