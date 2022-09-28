close all
clear all

% update long exposure picture (1 - 5)
sky_raw = rgb2gray(imread('long_pic_1.png'));   % convert in grey
sky_raw = im2double(sky_raw);                   % resize between [0,1]

figure
imshow(sky_raw)

% sky_raw = sky_raw(100:200,200:end);

% preprocessing
set_prepro.med = 3;
set_prepro.thres = 0.3;
[sky] = prepro(sky_raw,set_prepro);
% sky = imbinarize(sky_raw);
% sky = edge(sky,'canny');
% sky = bwmorph(sky,'thin');

% figure
% imshow(sky)

% Hough Transform Agorithm
[H, T, R] = hough(sky);
P = houghpeaks(H,1);
L = houghlines(sky,T,R,P,'MinLength',5);

% figure
% imshow(H); hold on
% plot(P(1,2),P(1,1),'r*'); hold on

figure
imshow(sky_raw); hold on
plot(L.point1(1),L.point1(2),'g*'); hold on
plot(L.point2(1),L.point2(2),'g*'); hold on









