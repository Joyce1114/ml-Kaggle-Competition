clear;
clf;
ori = imread('/Users/wangerxiao/Documents/MATLAB/edifice-rex-master/data/Norfolk_01_training.tif');
haha = entropyfilt(ori);
figure(2)
imshow(ori);
[Gx,Gy] = imgradientxy(ori(:,:,1));
[Gmag, Gdir] = imgradient(Gx,Gy);
figure(1)
grey = rgb2gray(ori);
imshow(grey);
R = ori(:,:,1);
figure(7);
image(R), colormap([[0:1/255:1]', zeros(256,1), zeros(256,1)]), colorbar;
%Green Component
G = ori(:,:,2);
figure(3);
image(G), colormap([zeros(256,1),[0:1/255:1]', zeros(256,1)]), colorbar;
%Blue component
figure(11)
thr = imadjust(R,[0.2,0.7],[0,1]);
imshow(thr);
figure(12)
thg = imadjust(R,[0.2,0.7],[0,1]);
imshow(thg)
figure(10)
as = rgb2hsv(ori);
imshow(as);