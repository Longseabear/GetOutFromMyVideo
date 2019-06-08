function [wp] = get_normalized_weight(I)
% compute the diffusivity of the four neighbors of all the pixels.
% Here we only compute the south and east neighbors.
% These computation is based on Brox's two-point diffusivity computation

% compute discretization
k1 = [-1,1];
ux1 = imfilter(I, k1, 'replicate');
uy1 = imfilter(I, k1', 'replicate');

k2 = [-0.5, 0, 0.5];
ux2 = imfilter(I, k2, 'replicate');
uy2 = imfilter(I, k2', 'replicate');

k3 = [0.5, 0.5];
uxsq = ux1.^2 + imfilter(uy2, k3, 'replicate').^2;    % delta_u(i+1/2, j)
uysq = uy1.^2 + imfilter(ux2, k3', 'replicate').^2;    % delta_u(i, j+1/2)

% get psi derivation
Psi_smooth_east = uxsq;
Psi_smooth_south = uysq;

Psi_smooth_east(:,end) = 0; 
Psi_smooth_south(end,:) = 0;

wp = get_wp(Psi_smooth_east, Psi_smooth_south);
