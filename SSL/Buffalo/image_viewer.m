function[] = image_viewer(image_vec)
% input vector of size n^2 output image that is n X n;


image_size = sqrt(length(image_vec));
image_mat = reshape(image_vec, [image_size image_size]);

image(image_mat);