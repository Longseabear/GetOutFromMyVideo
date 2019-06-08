function [y] = repeat_and_interp(x,patch,h,w)
y = repelem(x,patch,patch);
patch_num_x = floor(w/patch);
patch_num_y = floor(h/patch);
y = padarray(y,[h-patch_num_y*patch w-patch_num_x*patch],'replicate','post');
end

