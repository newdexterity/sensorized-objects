%           Author: Geng Gao
%           Date  : June-19-19
%           The University of Auckland
%      This is a script to Visualize and calculate the convex hull trajectories of the NDX-A* inhand
%      manipulation with a rigid sphere. 
%% File Setup
clc;
clear all;
close all;
%% defining file name structure e.g. "surface_object_motion"
hand = 'NDX_A';
surface = 'rigid';
object = 'sphere';
motion = {'pitch_1', 'roll_1','z_1'};
%% importing and windowing data 
% the aperture of the hand is the distance between the two finger tips when
% the hand is fully open. 
aperture = 133;
%cycling through each motion file
for i = 1:length(motion)
    % creating file name to be called
    file = string(strcat(hand,'_',surface, '_', object, '_', motion(i), '.csv'));
    % importing data
    data = csvread(fullfile('..','..','Data','NDX_A',file));

    %setting up start and end points for clipping data
    start = 500;
    len = size(data, 1) - 3500;
    
    %extractig values and converting to metric
    x = 25.4 * data(start:len, 2);
    y = 25.4 * data(start:len, 3);
    z = 25.4 * data(start:len, 4);
    %extractig values and converting to radians
    yaw = deg2rad(data(:, 5));   %rz
    pitch = deg2rad(data(:, 6)); %ry
    roll = deg2rad(data(:, 7));  %rx
    
    %centering coordinate frame of the data 
    %finding minimum and offsetting the data
    roll = roll - min(roll);
    pitch = pitch - min(pitch);
    yaw = yaw - min(yaw);
    x = x - min(x);
    y = y - min(y);
    z = z - min(z);
    %centering the data
    rollMid = (max(roll) - min(roll))/2;
    pitchMid = (max(pitch) - min(pitch))/2;
    yawMid = (max(yaw) - min(yaw))/2;
    roll = roll - rollMid;
    pitch = pitch - pitchMid;
    yaw = yaw - yawMid;
    Xmid = (max(x) - min(x))/2;
    Ymid = (max(y) - min(y))/2;
    Zmid = (max(z) - min(z))/2;
    x = x - Xmid;
    y = y - Ymid;
    z = z - Zmid;
    
    %setting up array of trahectory values
    if (i == 1)
        %translations
        X = x;
        Y = y;
        Z = z;
        %angles
        rz = yaw;
        ry = pitch;
        rx = roll;
    else
        %translations
        X = [X;x];
        Y = [Y;y];
        Z = [Z;z];
        %angles
        rz = [rz;yaw];
        ry = [ry;pitch];
        rx = [rx;roll];
    end 
end

%% plotting translation convex hull
figure,
plot3(X,Y,Z)
[k,vPos] = convhull(X,Y,Z);
tr = triangulation(k,X(:),Y(:),Z(:));
plot3(X,Y,Z, 'o', 'Color', [0.45 0.45 0.45], 'LineWidth', 0.1, 'markersize', 0.15);
hold on 
trisurf(tr,'facecolor',[0 0.4470 0.7410],'facealpha', 0.15, 'edgecolor', [0 0.4470 0.8410],'LineWidth', 0.9)
%title('Convex Hull of Positional Component of NDX Hand Manipulation with Sphere')
xlabel('x [mm]')
ylabel('y [mm]')
zlabel('z [mm]')
upperLimit = max([max(X),max(Y),max(Z)]);
lowerLimit = min([min(X),min(Y),min(Z)]);
axis([lowerLimit upperLimit lowerLimit upperLimit lowerLimit upperLimit])
set(findall(gcf,'-property','FontSize'),'FontSize',16)
axis square
ax = gca
ax.LineWidth = 1

%calculating translation metric motion
mPos = log10(vPos/power(aperture,3));
grid on
%% plotting rotation convex hull 
figure, 
%calculating the rotation metric motion 
[~,vRot] = convhull(rx,ry,rz);
mRot = log10(vRot/power((2*pi),3));
%converting to degrees 
rx = rad2deg(rx);
ry = rad2deg(ry);
rz = rad2deg(rz);
%calculationg convex hull value for plotting
k = convhull(rx,ry,rz);
tr = triangulation(k,rx(:),ry(:),rz(:));
%plotting
plot3(rx,ry,rz, 'o', 'Color', [0.45 0.45 0.45], 'LineWidth', 0.1, 'markersize', 0.15);
hold on 
trisurf(tr,'facecolor',[0 0.4470 0.7410],'facealpha', 0.15, 'edgecolor', [0 0.4470 0.8410],'LineWidth', 0.9)
%title('Convex Hull of rotational Component of NDX Hand Manipulation with Sphere')
xlabel('Rx [deg]')
ylabel('Ry [deg]')
zlabel('Rz [deg]')
upperLimit = max([max(rx),max(ry),max(rz)]);
lowerLimit = min([min(rx),min(ry),min(rz)]);

axis([lowerLimit upperLimit lowerLimit upperLimit lowerLimit upperLimit])

set(findall(gcf,'-property','FontSize'),'FontSize',16)
axis square
ax = gca
ax.LineWidth = 1
grid on