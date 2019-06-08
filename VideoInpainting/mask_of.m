function [F] = mask_of(im_p,im_c,mask_p,mask_c,para)
%% image load

if para.use_mask
    back_ground_p = not(mask_p(:,:,1));
    back_ground_c = not(mask_c(:,:,1));
end
%% parameter setting
out_iter = para.outer_iter;
in_iter = para.inner_iter;
level = para.level;
patch_size = para.patch_size;
inds_outofimage = [];

%% pyramid setting
% I1s=getGaussianPyramid(im_p,para.level);
% I2s=getGaussianPyramid(im_c,para.level);

if para.use_mask
%     I1_bgs=getGaussianPyramid(back_ground_p,para.level);
%     I2_bgs=getGaussianPyramid(back_ground_c,para.level);
    I1_bgs=getImPyramid(back_ground_p,para.sigma,para.downsampling,para.level);
    I2_bgs=getImPyramid(back_ground_c,para.sigma,para.downsampling,para.level);

end
I1s=getImPyramid(im_p,para.sigma,para.downsampling,para.level);
I2s=getImPyramid(im_c,para.sigma,para.downsampling,para.level);


%% fixed point iteration
for i = level:-1:1
    fprintf("current step [%d/%d]\n",level-i+1, level);
    
    I1=I1s{i};
    I2=I2s{i};
    if para.use_mask
        I1_bg=I1_bgs{i};
        I2_bg=I2_bgs{i};
    end
    [height, width, dim] = size(I1);
    [ys,xs]=ndgrid(1:height,1:width);
    
    patch_num_h = floor(height/patch_size);
    patch_num_w = floor(width/patch_size);
    
    if i == level
        % initial value. They are updated after every level
        u0 = zeros(patch_num_h, patch_num_w);
        v0 = zeros(patch_num_h, patch_num_w);
    end
    
    for out = 1:out_iter
        du = zeros(patch_num_h, patch_num_w);
        dv = zeros(patch_num_h, patch_num_w);
        
        % compute the derivatives, smoothing considering the directions
        [Ix1, Iy1] = gaussDeriv_dir(I1); % 이미지 기울기
        [Ix2, Iy2] = gaussDeriv_dir(I2);
        
        u0_expand = repeat_and_interp(u0,patch_size,height,width);
        v0_expand = repeat_and_interp(v0,patch_size,height,width);
        
        Ix2_warped = warp_image(Ix2, u0_expand, v0_expand); % why deviation interp?
        Iy2_warped = warp_image(Iy2, u0_expand, v0_expand); % 기울기를 현재 벡터로 워핑
        
        %estimate derivative direction by mixing i1 and i2 deivatives
        Ix_warped = 0.5*(Ix2_warped+Ix1); % 1의
        Iy_warped = 0.5*(Iy2_warped+Iy1); %
        
        I2_warped = warp_image(I2,u0_expand,v0_expand); % 진짜 이미지를 보간
        Iz_warped = I2_warped-I1; % Z축의 차이(intencity 차이)
        
        if para.use_mask
            I2_bg(I2_bg<0.5)=0;
            I2_bg(I2_bg~=0)=1;

            I2_bg_warped = warp_image(I2_bg, u0_expand, v0_expand);
            I2_bg_warped(I2_bg_warped>=0.9)=1;
            I2_bg_warped(I2_bg_warped~=1)=0;
        end
        
        % wp point calcul
        wp = get_normalized_weight(I1);
        if para.use_mask
            wp = wp.*I1_bg.*I2_bg_warped;
        end
        % wp = get_wp(Ix1, Iy1);
        wp_sum = window_sum(wp, patch_size);
        wp_sum_expand = repeat_and_interp(wp_sum,patch_size,height,width);
        
        % fix point inner iteration
        for iter = 1:in_iter
            du_c = repmat(du,[1,1,dim]);
            dv_c = repmat(dv,[1,1,dim]);
            
            du_c_expand = repeat_and_interp(du_c,patch_size,height,width);
            dv_c_expand = repeat_and_interp(dv_c,patch_size,height,width);
            
            wp_psi = window_sum(wp.*(Iz_warped+Ix_warped.*du_c_expand+Iy_warped.*dv_c_expand), patch_size);
            wp_psi_expand = repeat_and_interp(wp_psi, patch_size,height,width);
            
            wp_Ix = window_sum(wp.*Ix_warped, patch_size);
            wp_Ix_expand = repeat_and_interp(wp_Ix, patch_size,height,width);
            wp_Iy = window_sum(wp.*Iy_warped, patch_size);
            wp_Iy_expand = repeat_and_interp(wp_Iy, patch_size,height,width);
            wp_Iz = window_sum(wp.*Iz_warped, patch_size);
            wp_Iz_expand = repeat_and_interp(wp_Iz, patch_size,height,width);
            
            Psi_data = psiDeriv(window_sum(wp.*(Iz_warped+Ix_warped.*du_c_expand+Iy_warped.*dv_c_expand - (wp_psi_expand./wp_sum_expand)).^2,patch_size));
            [Psi_smooth_x, Psi_smooth_y] = get_psi_smooth(u0+du,v0+dv);
            
            du=du_c(:,:,1);
            dv=dv_c(:,:,1);
            
            data_term_Ix_warped = (Ix_warped - (wp_Ix_expand./wp_sum_expand));
            data_term_Iy_warped = (Iy_warped - (wp_Iy_expand./wp_sum_expand));
            data_term_Iz_warped = (Iz_warped - (wp_Iz_expand./wp_sum_expand));
            
            data_term_Ix_Ix_warped = window_sum(wp.*data_term_Ix_warped.*data_term_Ix_warped,patch_size);
            data_term_Ix_Iy_warped = window_sum(wp.*data_term_Ix_warped.*data_term_Iy_warped,patch_size);
            data_term_Ix_Iz_warped = window_sum(wp.*data_term_Ix_warped.*data_term_Iz_warped,patch_size);
            
            data_term_Iy_Iy_warped = window_sum(wp.*data_term_Iy_warped.*data_term_Iy_warped,patch_size);
            data_term_Iy_Iz_warped = window_sum(wp.*data_term_Iy_warped.*data_term_Iz_warped,patch_size);
            
            data_term_Ix_Ix_warped(isnan(data_term_Ix_Ix_warped))=0;
            data_term_Ix_Iy_warped(isnan(data_term_Ix_Iy_warped))=0;
            data_term_Ix_Iz_warped(isnan(data_term_Ix_Iz_warped))=0;
            data_term_Iy_Iy_warped(isnan(data_term_Iy_Iy_warped))=0;
            data_term_Iy_Iz_warped(isnan(data_term_Iy_Iz_warped))=0;
            Psi_data(isnan(Psi_data))=0;
            
            sor_warping_flow_multichannel_LDOF_MY(data_term_Ix_Ix_warped, data_term_Ix_Iy_warped, data_term_Ix_Iz_warped, ...
                Psi_data, Psi_smooth_x, Psi_smooth_y, du, ...
                dv,u0(:,:,1),v0(:,:,1),size(data_term_Ix_Ix_warped,1),...
                size(data_term_Ix_Ix_warped,2),size(data_term_Ix_Ix_warped,3),para.alpha,...
                para.sor_iter,para.w,data_term_Iy_Iy_warped,data_term_Iy_Iz_warped);
            
            %         inds_outofimage=find((xs+u0+temp_du<1 | xs+u0+temp_du>width | ys+temp_dv+v0<1 | ys+temp_dv+v0>height));
            
            if iter==in_iter && para.median_filtering
                du = medfilt2(du, [para.medianx para.mediany]);
                dv = medfilt2(dv, [para.medianx para.mediany]);
            end
            if para.verbose && iter==in_iter
                u = u0+du;
                v = v0+dv;
                temp_u = imresize(u, [height, width], 'bilinear');
                temp_v = imresize(v, [height, width], 'bilinear');
                
                flow_warp(I1,I2,cat(3,temp_u,temp_v),1)
                %check_flow_correspondence(I1,I2,cat(3,u,v));
                % flow_edge_map(I1,I2,cat(3,u,v),1);
                title(['pyramid level ' num2str(i)])
            end
        end
        
        % update the optical flow
        u = u0+du;
        v = v0+dv;
        u0 = u;
        v0 = v;
    end
    if i > 1
        % interpolate to get the initial value of the finner pyramid level
        [h_f,w_f,~] = size(I1s{i-1});
        next_patch_num_h = floor(h_f/patch_size);
        next_patch_num_w = floor(w_f/patch_size);
        
        u0 = imresize(u, [next_patch_num_h, next_patch_num_w], 'bilinear');
        v0 = imresize(v, [next_patch_num_h, next_patch_num_w], 'bilinear');
%         u0 = u0 .* 2;
%         v0 = v0 .* 2;
    else
        u = imresize(u, [height, width], 'bilinear');
        v = imresize(v, [height, width], 'bilinear');
    end
end
%% end

F=cat(3,u,v);
fprintf('done!\n');
end
%% function
function A = fix_margin(A, inds)
if isempty(inds)
    return;
end
[p,q,r]=size(A);
for i=1:r
    A(inds+(i-1)*p*q)=0;
end
end

