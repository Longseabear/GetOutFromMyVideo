function F = variational_descriptor_flow(im1,im2,mask1,mask2,...
    para,verbose)

I1s=getImPyramid(im1,para.sigma,para.downsampling,para.level);
I2s=getImPyramid(im2,para.sigma,para.downsampling,para.level);

gamma = para.gamma;
outer_iter = para.out_iter;
max_iter = para.inner_iter;

downsampling = para.downsampling;
num_level = para.level;
beta=para.beta;
inds_outofimage=[];
patch_size = para.patch_size;

fprintf('\n')
for l = num_level:-1:1
    progress(sprintf('\t\t level \n'),para.level-l+1,para.level);
    I1=I1s{l};
    I2=I2s{l};
    [height, width, dim] = size(I1);
    [ys,xs]=ndgrid(1:height,1:width);
    patch_size_h = floor(height/patch_size);
    patch_size_w = floor(width/patch_size);
    if l == num_level
        % initial value. They are updated after every level
        u0 = zeros(height, width);
        v0 = zeros(height, width);
    end
    
    for outer = 1:outer_iter    
        du = zeros(patch_size_h, patch_size_w);
        dv = zeros(patch_size_h, patch_size_w);
        
        % compute the derivatives, smoothing considering the directions
        [Ix1, Iy1] = gaussDeriv_dir(I1); % 이미지 기울기
        [Ix2, Iy2] = gaussDeriv_dir(I2);
        
        %warp the derivative according to the current displacement
        Ix2_warped = warp_image(Ix2, u0, v0); % why deviation interp?
        Iy2_warped = warp_image(Iy2, u0, v0); % 기울기를 현재 벡터로 워핑
        
        %estimate derivative direction by mixing i1 and i2 deivatives
        Ix_warped = 0.5*(Ix2_warped+Ix1); % 1의 기울기의 평균?
        Iy_warped = 0.5*(Iy2_warped+Iy1); %
        
        I2_warped = warp_image(I2,u0,v0); % 진짜 이미지를 보간
        Iz_warped = I2_warped-I1; % Z축의 차이(intencity 차이)
        
        %second order derivatives
        [Ixx1, Ixy1] = gaussDeriv_dir(Ix1); % 2차 미분
        [~, Iyy1] = gaussDeriv_dir(Iy1); % 2차미분
        [Ixx2, Ixy2] = gaussDeriv_dir(Ix2);
        [~, Iyy2] = gaussDeriv_dir(Iy2);
        
        %warp second order derivatives [ 2차 미분에대한 정리 )
        Ixx_warped = 0.5*(warp_image(Ixx2, u0, v0)+Ixx1);
        Ixy_warped = 0.5*(warp_image(Ixy2, u0, v0)+Ixy1);
        Iyy_warped = 0.5*(warp_image(Iyy2, u0, v0)+Iyy1);
        
        Ixz_warped = Ix2_warped-Ix1;
        Iyz_warped = Iy2_warped-Iy1;
        
        Ixz_warped = fix_margin(Ixz_warped, inds_outofimage);
        Iyz_warped = fix_margin(Iyz_warped, inds_outofimage);
        Ixx_warped = fix_margin(Ixx_warped, inds_outofimage);
        Ixy_warped = fix_margin(Ixy_warped, inds_outofimage);
        Iyy_warped = fix_margin(Iyy_warped, inds_outofimage);
        Iyz_warped = fix_margin(Iyz_warped, inds_outofimage);
        
        % temp
        Ix1 = Ix1(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        Iy1 = Iy1(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        Ix2 = Ix2(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        Iy2 = Iy2(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        
        Ix2_warped = Ix2_warped(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:); % why deviation interp?
        Iy2_warped = Iy2_warped(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:); % 기울기를 현재 벡터로 워핑
        
        %estimate derivative direction by mixing i1 and i2 deivatives
        Ix_warped = Ix_warped(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        Iy_warped = Iy_warped(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        I2_warped = I2_warped(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:); % 진짜 이미지를 보간
        Iz_warped = Iz_warped(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:); % Z축의 차이(intencity 차이)
        
        %second order derivatives
        Ixx1 = Ixx1(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        Ixy1 = Ixy1(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        Iyy1 = Iyy1(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:); % 2차미분
        Ixx2 = Ixx2(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        Ixy2 = Ixy2(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        Iyy2 = Iyy2(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        
        %warp second order derivatives [ 2차 미분에대한 정리 )
        Ixx_warped = Ixx_warped(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        Ixy_warped = Ixy_warped(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        Iyy_warped = Iyy_warped(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        
        Ixz_warped = Ixz_warped(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        Iyz_warped = Iyz_warped(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
       
        patch_u0 = u0(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
        patch_v0 = v0(1:patch_size:end-(patch_size-1),1:patch_size:end-(patch_size-1),:);
%        patch_u0 = imresize(u0,[patch_size_h, patch_size_w],'bilinear')
%        patch_v0 = imresize(v0,[patch_size_h, patch_size_w],'bilinear');
        
        % fix point inner iteration
        for iter = 1:max_iter
            % duplicate du and dv on multiple channels to adapt to color image
            du_c = repmat(du,[1,1,dim]);
            dv_c = repmat(dv,[1,1,dim]);
            
            Psi_data = psiDeriv((Iz_warped+Ix_warped.*du_c+Iy_warped.*dv_c).^2 +... % taylor seriese
                gamma*((Ixz_warped+Ixx_warped.*du_c+Ixy_warped.*dv_c).^2+... % 그래디언트 텀.
                (Iyz_warped+Ixy_warped.*du_c+Iyy_warped.*dv_c).^2)); % pis의 기울기를 구했네
            
            
            [Psi_smooth_x, Psi_smooth_y] = get_psi_smooth(patch_u0+du,patch_v0+dv); % 쓰무스의 기울기
            
            
            
            du=du_c(:,:,1);
            dv=dv_c(:,:,1);
            
            sor_warping_flow_multichannel_LDOF(Ix_warped, Iy_warped, Iz_warped, ...
                Ixx_warped, Ixy_warped, Iyy_warped, Ixz_warped, Iyz_warped, ...
                Psi_data, Psi_smooth_x, Psi_smooth_y, du, ...
                dv,patch_u0(:,:,1),patch_v0(:,:,1),size(Ix_warped,1),...
                size(Ix_warped,2),size(Ix_warped,3),para.alpha,...
                para.gamma,para.sor_iter,para.w,beta);
            
            temp_du = imresize(du, [height, width], 'bilinear');
            temp_dv = imresize(dv, [height, width], 'bilinear');
            inds_outofimage=find((xs+u0+temp_du<1 | xs+u0+temp_du>width | ys+temp_dv+v0<1 | ys+temp_dv+v0>height));  
            
            if iter==max_iter && para.median_filtering
                du = medfilt2(du, [para.medianx para.mediany]);
                dv = medfilt2(dv, [para.medianx para.mediany]);
            end
            if verbose && iter==max_iter
                u = patch_u0+du;
                v = patch_v0+dv;
                temp_u = imresize(u, [height, width], 'bilinear');
                temp_v = imresize(v, [height, width], 'bilinear');
                
                flow_warp(I1,I2,cat(3,temp_u,temp_v),1)
                %check_flow_correspondence(I1,I2,cat(3,u,v));
                % flow_edge_map(I1,I2,cat(3,u,v),1);
                title(['pyramid level ' num2str(l)])
            end
        end
        
        % update the optical flow
        u = patch_u0+du;
        v = patch_v0+dv;
        
        u0 = imresize(u, [height, width], 'bilinear');
        v0 = imresize(v, [height, width], 'bilinear');
    end
    if l > 1
        % interpolate to get the initial value of the finner pyramid level
        scale_next = downsampling^(l-2);
        h_f = round(para.p*(scale_next));
        w_f = round(para.q*(scale_next));
        u0 = imresize(u, [h_f, w_f], 'bilinear');
        v0 = imresize(v, [h_f, w_f], 'bilinear');
        u0 = u0 .* 2;
        v0 = v0 .* 2;
    else
        u = imresize(u, [height, width], 'bilinear');
        v = imresize(v, [height, width], 'bilinear');
    end    
end

F=cat(3,u,v);
fprintf('done!\n');
end
function A = fix_margin(A, inds)
if isempty(inds)
    return;
end
[p,q,r]=size(A);
for i=1:r
    A(inds+(i-1)*p*q)=0;
end
end