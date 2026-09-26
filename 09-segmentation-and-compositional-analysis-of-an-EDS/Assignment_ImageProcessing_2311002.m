clc, close all
% first, we are opening the image using imread
% mind using your own directory of image while using this command
% you can also use 'import' option
EDS  = imread('C:\Users\Praggo\Downloads\EDS.JPG');
% show the image
imshow(EDS); figure(1);
title('Text included Micrograph of EDS');

% now we crop it using imcrop. we will make it automatic
% because, if we do it manually, then everytime we run the script
% the cropping box will come up. so we will do it once. 

% first we will save the coordinates in a file
c_file = 'coordinates.mat';

% now we will do a if-else section which will check if the file 
% exists, if it does, then it will load the numbers,
% if it does not, we will crop it

if isfile(c_file)
    load(c_file, 'crop');
    disp ('loaded coordinates for crop...');
else 
    disp ('could not load coordinates');
    [~, crop] = imcrop(EDS);
    save (c_file,"crop"); 
    disp ('coordinates saved...');
end

% now we crop the image from the saved coordinates files
% we crop it manually
EDS2 = imcrop (EDS, crop); figure(2);
imshow (EDS2); title("Cropped EDS");

% now that we have cropped EDS, we will work on EDS2
% we used Color Threshold app and used L*a*b* (as we found it
% suitable) to extract yellow part from the cropped EDS
% we also exported a function named it yelloMask.m 
% now we call the function 
bwEDS = yellowMask(EDS2); figure(3);
imshowpair(EDS2, bwEDS, "Montage"); 
title("Comparison between EDS and yellow filtered EDS");

% we do that with other colors too 
% for red/pink
bwEDS2 = redMask(EDS2); figure(4);
imshowpair(EDS2, bwEDS2, "Montage"); 
title("Comparison between EDS and red filtered EDS");

% for green
bwEDS3 = greenMask(EDS2); figure(5);
imshowpair(EDS2, bwEDS3, "Montage"); 
title("Comparison between EDS and green filtered EDS");

% for paste/ aluminum color
bwEDS4 = alMask(EDS2); figure(6);
imshowpair(EDS2, bwEDS4, "Montage"); 
title("Comparison between EDS and paste filtered EDS");

% for blue/Magnesium 
bwEDS5 = blueMask(EDS2); figure(7);
imshowpair(EDS2, bwEDS5, "Montage"); 
title("Comparison between EDS and blue filtered EDS");

% now we will use region props function that will show the properties of
% a certain region in black white etc segmented images
prop1 = regionprops("table", bwEDS, "Area");
prop2 = regionprops("table", bwEDS2, "Area");
prop3 = regionprops("table", bwEDS3, "Area");
prop4 = regionprops("table", bwEDS4, "Area");
prop5 = regionprops("table", bwEDS5, "Area");
% thus we get the total white part in segmented area. we get the sum 
area1 = sum(prop1.Area);
area2 = sum(prop2.Area);
area3 = sum(prop3.Area);
area4 = sum(prop4.Area);
area5 = sum(prop5.Area);
% but this area is in pixels, we need to convert it to mm. 
% for that we again use image tool, there is a ruler there
% we will measure how much is 0.5 mm in pixels
% imtool(EDS); thus we get 173.5 pixels in 0.5 mm.
% so the conversion factor is (173.5/0.5)^2 
cf = (0.5/173.5)^2; 
% so the area of yellow part is: 
disp("Area of S in mm^2");
mmarea1 = area1*cf; disp (mmarea1);

% the rest: 
disp("Area of Ca in mm^2");
mmarea2 = area2*cf; disp (mmarea2);
disp("Area of Si in mm^2");
mmarea3 = area3*cf; disp (mmarea3);
disp("Area of Al in mm^2");
mmarea4 = area4*cf; disp (mmarea4);
disp("Area of Mg in mm^2");
mmarea5 = area5*cf; disp (mmarea5);

% so the total area 
area = mmarea1 + mmarea2 + mmarea3 + mmarea4 + mmarea5;

% fraction of S:
fS = mmarea1/ area; 
disp("Fraction percentage of S: "); disp(fS*100);
% fraction of Ca: 
fCa = mmarea2/ area; 
disp("Fraction percentage of Ca: "); disp(fCa*100);
% fraction of Si: 
fSi = mmarea3/ area;
disp("Fraction percentage of Si: "); disp(fSi*100);
% fraction of Al: 
fAl = mmarea4/ area; 
disp("Fraction percentage of Al: "); disp(fAl*100);
% fraction of Mg: 
fMg = mmarea5/ area; 
disp("Fraction percentage of Mg: "); disp(fMg*100);

% now we do the 3D graph plotting
% for each connected region found in each thresholded mask, find
% the MEAN R,G,B of that region as it appears in the original (unthresholded)
% cropped image EDS2. Then scatter all these per-region average colors in
% 3D RGB space, using the color itself as the marker color. If the masking
% is doing its job, points belonging to the same element should cluster
% tightly together and stay separated from other elements' clusters.
 
masks  = {bwEDS, bwEDS2, bwEDS3, bwEDS4, bwEDS5};
labels = {'S','Ca','Si', 'Al','Mg'};
 
% discard tiny/noise regions (stray pixels from thresholding, thin
% boundary slivers, leftover text/arrow fragments etc.)
minArea = 30;
 
% now we split the original cropped image into channels once 
R = double(EDS2(:,:,1));
G = double(EDS2(:,:,2));
B = double(EDS2(:,:,3));
 
figure(8); hold on;
regionCounts = zeros(1, numel(masks));
 
for k = 1:numel(masks)
    stats = regionprops(masks{k},'PixelIdxList','Area');
    % drops noise regions
    stats = stats([stats.Area]>=minArea);   
    regionCounts(k) = numel(stats);
    nReg = numel(stats);
    regionRGB = zeros(nReg, 3);
 
    for r = 1:nReg
        % linear pixel indices of this region
        idx = stats(r).PixelIdxList;          
        regionRGB(r,:) = [mean(R(idx)), mean(G(idx)), mean(B(idx))] / 255;
    end
 
    % each point is colored by its OWN measured average color, so the
    % plot visually shows clustering without needing a separate legend
    scatter3(regionRGB(:,1), regionRGB(:,2), regionRGB(:,3), 50, ...
        regionRGB, 'filled', 'MarkerEdgeColor', 'k');
end
 
xlabel('Mean R (normalized)');
ylabel('Mean G (normalized)');
zlabel('Mean B (normalized)');
title('3D scatter of per-region average colors (clustering by element)');
legend(labels, 'Location', 'bestoutside');grid on; view(135, 25); hold off;
 
disp('Number of valid regions counted per element:');
for k = 1:numel(masks)
    fprintf('%s: %d regions\n', labels{k}, regionCounts(k));
end