function [Ix, Iy] = gaussDeriv_dir(I)
k = (1/12)*[1 -8 0 8 -1];
Ix = imfilter(I, k,  'replicate');
Iy = imfilter(I, k', 'replicate');
end