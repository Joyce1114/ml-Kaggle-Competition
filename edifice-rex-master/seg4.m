Seg = load('/Users/wangerxiao/Documents/MATLAB/edifice-rex-master/seg4new.mat');
srManSpec = Seg.srManSpec;
SE= strel('square',3);
imopen(srManSpec,SE);
imclose(srManSpec,SE);
imshow(srManSpec);

srManSpec1 = rgb2gray(srManSpec);
edgeim = edge(srManSpec1,'canny', [0.1 0.2], 1);
edgeim = filledgegaps(edgeim,5);
figure(10), imshow(edgeim);

    
% Link edge pixels together into lists of sequential edge points, one
% list for each edge contour. A contour/edgelist starts/stops at an 
% ending or a junction with another contour/edgelist.
% Here we discard contours less than 10 pixels long.

[edgelist, labelededgeim] = edgelink(edgeim, 20);
% sort the gradient vector
% [Gx, Gy] = imgradientxy(srManSpec2);
% [Gmag, Gdir] = imgradient(Gx, Gy);
% Gfil = zeros(1,length(edgelist));
% for i=1: length(edgelist)
%     for j = 1:length(edgelist{1,i})
%         A = edgelist{1,j};
%         for k = 1:size(A,1)
%         row = A(k,1);
%         col = A(k,2);
%         Gfil(i) = Gfil(i) + Gmag(row,col);
%         end
%     end
% end
% Gfilcop = Gfil;
% sort(Gfilcop);
% 
% for m=1:length(Gfil)
%     if ((Gfil(m) <  1.3510e+04) || (Gfil(m) > 5.7957e+05))
%         edgelist{1,m} = [];
%     end
% end

% Display the edgelists with random colours for each distinct edge 
% in figure 2
figure(11)
edgelist = edgelist(~cellfun('isempty',edgelist))  ;
edgelist = cleanedgelist(edgelist,10);
drawedgelist(edgelist, size(srManSpec1), 1, 'rand', 2); axis off        


        
% Fit line segments to the edgelists
tol = 2;         % Line segments are fitted with maximum deviation from
% original edge of 2 pixels.
seglist = lineseg(edgelist, tol);

% Draw the fitted line segments stored in seglist in figure window 3 with
% a linewidth of 2 and random colours
figure(12)
drawedgelist(seglist, size(srManSpec1), 2, 'rand', 3); axis off




