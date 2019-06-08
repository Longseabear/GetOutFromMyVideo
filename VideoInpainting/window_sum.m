function [output] = window_sum(X, window_size)
[~,~,c] = size(X);
sum_filter = ones(window_size,window_size);
for i=1:c
    res = conv2(X(:,:,i), sum_filter);
    output(:,:,i) = res(window_size:window_size:end-window_size+1,window_size:window_size:end-window_size+1);
end

