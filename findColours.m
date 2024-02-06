function colorArray = findColours(filename)

% Loads an image from the file specified by filename, and returns it as type double.
image = loadImage(filename);

% this function finds the circles in the image and returns its co-ordinates
circleCoordinates = findCircles(image);

%this function undistorts the image by using the circle coordinates from
%the below function
images=correctImage(circleCoordinates,image);
imshow(images)


if contains(filename, 'noise_')|| contains(filename, 'org_')
    %this function getColours returns an array of colours in the
    % given image
    result = getColours(image);
    
else
    disp('The getColors function can be used only on un-distorted images');
    result=0;
end
disp(result)
colorArray = result;
end




% 
% 
% Loads an image from the file specified by filename, and returns it as type double.
function image = loadImage(filename)

% Read in the image using imread
img = imread(filename);

% Convert the image to double precision
image = im2double(img);

end


% 
% 
% find the coordinates of the black circle
function circleCoordinates = findCircles(image)

% Load the image
img = image;

% Changing the given image to grey image
gray_img = rgb2gray(img);

% Thresholding to get a binary image
threshold = graythresh(gray_img);
binary_img = imbinarize(gray_img, threshold);

% inverting the binary image
inverted_binary_img = imcomplement(binary_img);

% Labelling the components that are connected in the inverted_binary_img
cc = bwconncomp(inverted_binary_img);

% Calculating the area of each component
areas = cellfun(@numel, cc.PixelIdxList);

% Sorting in descending order
[sorted_areas, sorted_indices] = sort(areas, 'descend');

% Getting the coordinates of the first four largest black blobs
num_blobs = 5;
blob_coords = zeros(num_blobs, 2);
for i = 2:num_blobs
    blob_indices = cc.PixelIdxList{sorted_indices(i)};
    [rows, cols] = ind2sub(size(inverted_binary_img), blob_indices);
    blob_coords(i, :) = [ mean(cols),mean(rows)];
end
% Removing the first coordinate from the blob_coords matrix
blob_coords(1, :) = [];


% Sort the coordinates in clockwise order starting from bottom-left
sortedCoordinates = sortrows(blob_coords);

if sortedCoordinates(2,2) < sortedCoordinates(1,2)
    % If the second coordinate is below the first, swap them
    sortedCoordinates([1 2],:) = sortedCoordinates([2 1],:);
end

if sortedCoordinates(4,2) > sortedCoordinates(3,2)
    % If the fourth coordinate is above the third, swap them
    sortedCoordinates([3 4],:) = sortedCoordinates([4 3],:);
end

circleCoordinates=sortedCoordinates;

end



%
%
%Correct the distorted images
function outputImage = correctImage(Coordinates, image)

% Define a fixed box with coordinates
boxf = [[0 ,0]; [0 ,480];[480 ,480]; [480 ,0]];

% Calculating the transformation matrix from the given Coordinates to 
% transform the matrix to the fixed box using projective transformation
TF = fitgeotrans(Coordinates,boxf,'projective');

% Create an image reference object with the size of the input image
outview = imref2d(size(image));

% Apply the calculated transformation matrix to the input image
% and create a new image with fill value 255 (white) outside the boundaries of the input image
B = imwarp(image,TF,'fillvalues',255,outputview=outview);

% Crop the image to a size of 480x480
B = imcrop(B,[0 0 480 480]);

% Try to suppress the glare in the image using flat-field correction
B = imflatfield(B,40);

% Adjust the levels of the image to improve contrast
B = imadjust(B,[0.4 0.65]);

% Assign the corrected image to the outputImage variable
outputImage = B;
end



%
%
% gets the array of colours from the image
function colours=getColours(image)

% Convert the image to uint8 format
W=im2uint8(image);

% Median filter to suppress noise
W = medfilt3(W,[7 7 1]);

% Increase contrast
W = imadjust(W,stretchlim(W,0.025));

% Convert the RGB image to grayscale and threshold
Conimage = rgb2gray(W)>20;

% Remove positive specks from binary image
Conimage = bwareaopen(Conimage,100);

% Remove negative specks from binary image
Conimage = ~bwareaopen(~Conimage,100);

% Remove outer white region
Conimage = imclearborder(Conimage);

% Erode image
Conimage = imerode(Conimage,ones(10));

% Segmenting the image
[K O] = bwlabel(Conimage);

% Storing the average color of each region
Concolors = zeros(O,3);

% Getting the average color in each labeled region
for p = 1:O % step through patches
    each_pch = K==p;
    all_pch_areas = W(each_pch(:,:,[1 1 1]));
    Concolors(p,:) = mean(reshape(all_pch_areas,[],3),1);
end

% Normalizing the color values to the required range [0, 1]
Concolors = Concolors./255;

% Snapping centers to grid
Y = regionprops(Conimage,'centroid');
X = vertcat(Y.Centroid);
lim_X = [min(X,[],1); max(X,[],1)];
X = round((X-lim_X(1,:))./range(lim_X,1)*3 + 1);

% Reordering  the color samples
idx = sub2ind([4 4],X(:,2),X(:,1));
Concolors(idx,:) = Concolors;

% Specifing color names
clrnames = {'white','red','green','blue','yellow'};

% declaring a reference colors list in RGB
clrrefs = [1 1 1; 1 0 0; 0 1 0; 0 0 1; 1 1 0];

% measuring distance of colours in RGB
I = Concolors - permute(clrrefs,[3 2 1]);
I = squeeze(sum(I.^2,2));

% finding the nearest match
[~,idx] = min(I,[],2);

% Looking for the colour names in each patch
Colornames = reshape(clrnames(idx),4,4);

% Returns the array color names
colours= Colornames;

end

