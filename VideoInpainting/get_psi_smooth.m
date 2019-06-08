function [Psi_smooth_east, Psi_smooth_south] = get_psi_smooth(u, v)
% compute the diffusivity of the four neighbors of all the pixels.
% Here we only compute the south and east neighbors.
% These computation is based on Brox's two-point diffusivity computation

% compute discretization
k1 = [-1,1];
ux1 = imfilter(u, k1, 'replicate');
uy1 = imfilter(u, k1', 'replicate');
vx1 = imfilter(v, k1, 'replicate');
vy1 = imfilter(v, k1', 'replicate');

k2 = [-0.5, 0, 0.5];
ux2 = imfilter(u, k2, 'replicate');
uy2 = imfilter(u, k2', 'replicate');
vx2 = imfilter(v, k2, 'replicate');
vy2 = imfilter(v, k2', 'replicate');

k3 = [0.5, 0.5];
uxsq = ux1.^2+ imfilter(uy2, k3, 'replicate').^2;    % delta_u(i+1/2, j)
uysq = uy1.^2+ imfilter(ux2, k3', 'replicate').^2;    % delta_u(i, j+1/2)
vxsq = vx1.^2+ imfilter(vy2, k3, 'replicate').^2;    % delta_v(i+1/2, j)
vysq = vy1.^2+ imfilter(vx2, k3', 'replicate').^2;    % delta_v(i, j+1/2)

% get psi derivation
Psi_smooth_east = psiDeriv(uxsq+vxsq);
Psi_smooth_south = psiDeriv(uysq+vysq);

Psi_smooth_east(:,end) = 0; 
Psi_smooth_south(end,:) = 0;