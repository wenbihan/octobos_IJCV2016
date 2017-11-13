function [ rgbImage ] = clusterVisual( Image, ClusterMap, classNum, colorCode)
%CLUSTERVISUAL Summary of this function goes here
%   Detailed explanation goes here
rgbImage = cat(3,Image,Image,Image);
rgbImage = uint8(rgbImage);
for layer = 1:3
    imageLayer = rgbImage(:,:,layer);
    imageLayer(ClusterMap == classNum) = colorCode(layer);
    rgbImage(:,:,layer) = imageLayer;
end
end

