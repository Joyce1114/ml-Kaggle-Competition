clear;
clf;
figure(1)
img = imread('/Users/wangerxiao/Documents/MATLAB/edifice-rex-master/data/Norfolk_01_training.tif');
imshow(img);
% create a 3 by 3 Gaussian filter
h = fspecial('gaussian',[3 3]);
newimg = imfilter(img,h,'replicate');
% visualization
figure(2)
imshow(newimg);
% compute gradient directions and values
% Right now, just using imgradientxy, wondering if we should use conv2
% If so, what is the 2 by 2 matrix should we use ([1,1;1,1] or others)?
% Also, since imgradient only works for two dimentsions, should we compute
% the gradient individually for r, g and b channel
gray = rgb2gray(newimg);
% Red channel
[Gx, Gy] = imgradientxy(gray);
[Gmag, Gdir] = imgradient(Gx, Gy);
figure(3)
imagesc(Gmag);

%%%%%%%%%%%%%%%%Line Detection

%Calculate Hough Transform
[H,T,R] = hough(Gmag);
%Specify number of extrema
P = houghpeaks(H,10);

%Plot hugh transform
figure
imshow(imadjust(mat2gray(H)),[],...
'XData',T,...
'YData',R,...
'InitialMagnification','fit');
xlabel('\theta (degrees)')
ylabel('\rho')
axis on
axis normal
hold on
colormap(hot)

x = T(P(:,2));
y = R(P(:,1));
plot(x,y,'s','color','black');
%Calculate fit lines
lines = houghlines(Gmag,T,R,P);

%Plot fit lines
figure, imshow(img), hold on
max_len = 0;
for k = 1:length(lines)
xy = [lines(k).point1; lines(k).point2];
plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

% Plot beginnings and ends of lines
plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

% Determine the endpoints of the longest line segment
len = norm(lines(k).point1 - lines(k).point2);
if ( len > max_len)
max_len = len;
xy_long = xy;
end
end
%Create plot of lines and add axis labels
imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit')
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
plot(T(P(:,2)),R(P(:,1)),'s','color','white')

