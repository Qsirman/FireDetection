close all;clc;clear;

filename = 'test.avi';
vidObj = VideoReader(filename);
writerObj = VideoWriter('testOut.avi');
open(writerObj);
figure(1);

while hasFrame(vidObj)
%     original = imread('test3.jpg');
    original = readFrame(vidObj);
    original_hsv = rgb2hsv(original);
%     subplot(2,3,1);
%     imshow(original);

%     subplot(2,3,2);
%     imshow(original_hsv);

    filter_hsv = (original_hsv(:,:,1))>0.16;
    filter_hsv = filter_hsv.*(original_hsv(:,:,2))>0.5;
    filter_hsv = filter_hsv.*(original_hsv(:,:,2))<0.6;
    filter_hsv = filter_hsv.*(original_hsv(:,:,3))>0.97;

    filter_hsv3(:,:,1) = filter_hsv;
    filter_hsv3(:,:,2) = filter_hsv;
    filter_hsv3(:,:,3) = filter_hsv;

    hsv = double(original).*filter_hsv3;

    hsv = uint8(hsv);

    ratio = 245/180;
    bias = 0.3;

    hsv_gray = rgb2gray(hsv);
    hsv_dilate = im2bw(hsv_gray);

%     hsv_dilate = hsv_binary;

    [B,L] = bwboundaries(hsv_dilate,'noholes');
    max_ = size(B,1);
    filter_hsv_ = filter_hsv;
    Ck_Threshod = 2;
    if max_ ~= 0
%         subplot(2,3,3);
%         imshow(hsv_dilate);
%         hold on;
            % handle every single situation independently
            for iii=1:max_
                boundary = B{iii};
                tempRatio = range(boundary(:,1))/range(boundary(:,2));
                % not in the range
                if tempRatio < ratio*(1-bias) || tempRatio > ratio*(1+bias)
                    selected = (L == iii);
                    selected = ~selected;
                    filter_hsv=filter_hsv.*selected;
%                     plot(boundary(:,2), boundary(:,1),'m','LineWidth',2);
                else
                    plot(boundary(:,2), boundary(:,1),'g','LineWidth',2);
                end
            end

%             filter_hsv3(:,:,1) = filter_hsv;
%             filter_hsv3(:,:,2) = filter_hsv;
%             filter_hsv3(:,:,3) = filter_hsv;
% 
%             hsv = double(original).*filter_hsv3;
% 
%             hsv = uint8(hsv);
% 
%             subplot(2,3,4);
%             imshow(hsv);
    end

    hsv_dilate = hsv_dilate.*filter_hsv;
    hsv_dilate = im2bw(hsv_dilate);
    
    [B,L] = bwboundaries(hsv_dilate,'noholes');
    max_ = size(B,1);
    imshow(original);
    hold on;
    if max_ ~= 0
%         subplot(2,3,5);
        
        for iii=1:max_
            boundary = B{iii};
            stats = regionprops('table',B{iii},'Area','Perimeter');
            Ck = 4*pi*sum(stats.Area)/(sum(stats.Perimeter)).^2;
            if Ck > Ck_Threshod
                selected = (L == iii);
                selected = ~selected;
                filter_hsv=filter_hsv.*selected;
%                 plot(boundary(:,2), boundary(:,1),'r','LineWidth',2);
            else
                plot(boundary(:,2), boundary(:,1),'b','LineWidth',2);
            end
        end
%         filter_hsv3(:,:,1) = filter_hsv;
%         filter_hsv3(:,:,2) = filter_hsv;
%         filter_hsv3(:,:,3) = filter_hsv;
% 
%         hsv = double(original).*filter_hsv3;
% 
%         hsv = uint8(hsv);

%         subplot(2,3,6);
%         imshow(hsv);
    end
    writeVideo(writerObj,getframe);
end
close(writerObj);