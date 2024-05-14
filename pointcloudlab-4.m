close all

% imshow(color_frame);

figure 
%color_frame itself is 3Dim

mask=create_red_Mask(color_frame); % 2D mask of green 

%mask is a logical matrice

maskmatrice= double(mask); % convert from logical to numeric

imshow(mask)

% size(mask)
% 480 640

% so now our depth matrice matches the image dimensiona
depth1= reshape(depth_data,[480 640]);

% we need to multiply element wise by depth values, so that the only pixels
% that remain in the depth are those indentified by the color mask 
% depth_of_masked= mask.*depth1;
% imshow(depth_of_masked);


% approach number 2
% setting all points except cube as inf 
depth1(~mask)= inf 
depth_of_masked= depth1

%% Create a point cloud using MATLAB library
% Create a MATLAB intrinsics object

% with segmented cloud
intrinsics = cameraIntrinsics([depth_intrinsics.fx,depth_intrinsics.fy],[depth_intrinsics.ppx,depth_intrinsics.ppy],size(depth_of_masked));
% Create a point cloud
ptCloud = pcfromdepth(depth_of_masked,1/depth_scaling,intrinsics,ColorImage=color_frame);

ptCloud1 = removeInvalidPoints(ptCloud)

% with unsegmented cloud
% intrinsics = cameraIntrinsics([depth_intrinsics.fx,depth_intrinsics.fy],[depth_intrinsics.ppx,depth_intrinsics.ppy],size(depth_frame));
% 
% % Create a point cloud
% ptCloud = pcfromdepth(depth_frame,1/depth_scaling,intrinsics,ColorImage=color_frame);




% Display point cloud
figure
pcshow(ptCloud1,'VerticalAxisDir','Down');
title("point cloud")

% figure 
% 
% imshow(color_frame)
% title("color frame")

%  we now have a segmented point cloud according to color
% from this point cloud, we need to fit a plane to the top surface to
% assign a pose


% pcfitplane basically works like linear regression, but for plane 

maxDistance = 0.005; % jo bhi plane find hoga wo points ka us se kya distance hona chaiye
% 0.01 means k plane se 0.01 door ho tou qareebi points milen gai

referenceVector = [0,0,1];

maxAngularDistance = 10 %degrees
%this model is an equation of the plane
% model = pcfitplane(ptCloud,maxDistance,referenceVector, maxangle)

[model1,inlierIndices,outlierIndices] = pcfitplane(ptCloud1,...
            maxDistance,referenceVector,maxAngularDistance);
plane1 = select(ptCloud,inlierIndices);
remainPtCloud = select(ptCloud,outlierIndices);

hold on
plot(model1)


% % from the LINEAR inlier indices, finding the x y z values where the block exists 
% inlierPoints = ptCloud.Location(inlierIndices)


