% Read the sample image in
a = imread('/Users/wangerxiao/Documents/MATLAB/edifice-rex-master/data/Norfolk_01_training.tif');

im = rgb2gray(a);    
% Find edges using the Canny operator with hysteresis thresholds of 0.1
% and 0.2 with smoothing parameter sigma set to 1.
edgeim = edge(im,'canny', [0.1 0.2], 1);
figure(1), imshow(edgeim);

    
% Link edge pixels together into lists of sequential edge points, one
% list for each edge contour. A contour/edgelist starts/stops at an 
% ending or a junction with another contour/edgelist.
% Here we discard contours less than 10 pixels long.

[edgelist, labelededgeim] = edgelink(edgeim, 20);
% sort the gradient vector
[Gx, Gy] = imgradientxy(im);
[Gmag, Gdir] = imgradient(Gx, Gy);
Gfil = zeros(1,length(edgelist));
for i=1: length(edgelist)
    for j = 1:length(edgelist{1,i})
        A = edgelist{1,j};
        for k = 1:size(A,1)
        row = A(k,1);
        col = A(k,2);
        Gfil(i) = Gfil(i) + Gmag(row,col);
        end
    end
end
Gfilcop = Gfil;
sort(Gfilcop);

for m=1:length(Gfil)
    if ((Gfil(m) <  1.3510e+04) || (Gfil(m) > 5.7957e+05))
        edgelist{1,m} = [];
    end
end

% Display the edgelists with random colours for each distinct edge 
% in figure 2
edgelist = edgelist(~cellfun('isempty',edgelist))  ;
drawedgelist(edgelist, size(im), 1, 'rand', 2); axis off        


        
% Fit line segments to the edgelists
tol = 2;         % Line segments are fitted with maximum deviation from
% original edge of 2 pixels.
seglist = lineseg(edgelist, tol);

% Draw the fitted line segments stored in seglist in figure window 3 with
% a linewidth of 2 and random colours
drawedgelist(seglist, size(im), 2, 'rand', 3); axis off

