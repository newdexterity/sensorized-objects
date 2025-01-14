%           Author: Geng Gao
%           Date  : June-19-19
%           The University of Auckland
%      This is a script to visualise and calculate the average repeatability in
%      translation and rotation of a given object manipulation motion. This script has been
%      made for the t42 manipulating a rigid cylinder.
%% File Setup
clc;
clear all;
close all;
%% File name setup
hand = 'T42';
object = 'cylinder';
motion = {'roll_1', 'x_1', 'z_1'};
%% importing and windowing data 
%setting up the start and end points to be used inorder to remove outliers
minDist = [400,600,320];%distance between the peaks 
bestAxis = [3,1,1]; %the best axis to use from the data to find endpoints
startCycle = [1,1,2]; %starting cycles
endCycle = [0,0,1]; %cycle points to remove from the end

%cycling through each motion file
for i = 1:length(motion)
    % creating file name to be called
    file = string(strcat(hand, '_', object, '_', motion(i), '.csv'));
    % importing data
    data = csvread(fullfile('..','..','Data','T42',file), 1, 1);
    
    %settig start of window of the data
    start = 800;
    len = size(data, 1) - 800;

    %extractig values and converting to metric
    x = 1000* data(start:len, 2);
    y = 1000* data(start:len, 3);
    z = 1000* data(start:len, 4);
    yaw = rad2deg(data(start:len, 7));   %rz
    pitch = rad2deg(data(start:len, 6)); %ry
    roll = rad2deg(data(start:len, 5));  %rx

    % removing angle offset for range of motion
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
    rx = roll - rollMid;
    ry = pitch - pitchMid;
    rz = yaw - yawMid;
    Xmid = (max(x) - min(x))/2;
    Ymid = (max(y) - min(y))/2;
    Zmid = (max(z) - min(z))/2;
    x = x - Xmid;
    y = y - Ymid;
    z = z - Zmid;
    
    % finding peaks
    data = [x,y,z,rx,ry,rz];
    [val,num] = findpeaks(data(:,bestAxis(i)),'MinPeakDistance',minDist(i));
    transVal = zeros((length(num)-endCycle(i)),3);
    rotVal = zeros((length(num)-endCycle(i)),3);
    for j = 1:(length(num)-endCycle(i))
        for k = 1:3
            transVal(j,k) = data(num(j),k);
            rotVal(j,k) = data(num(j),k+3);
        end
    end
    
    % getting mean drift vector 
    start = startCycle(i);
    bot = length(num)-endCycle(i);
    transDriftVector = zeros(length(start:bot-1),3);
    rotDriftVector = zeros(length(start:bot-1),3);
    for j = start:(bot-1)
        for k = 1:3
            transDriftVector(j-start+1,k) = transVal(j+1,k) - transVal(j,k);
            rotDriftVector(j-start+1,k) = rotVal(j+1,k) - rotVal(j,k);
        end
    end
    meanTransDrift = mean(transDriftVector);
    meanRotDrift = mean(rotDriftVector);
    
    %removing drift from points
    transNoDriftVal = zeros(length(start:bot),3);
    rotNoDriftVal = zeros(length(start:bot),3);
    for j = start:(bot)
        for k = 1:3
            transNoDriftVal(j-start+1,k) = transVal(j,k)- meanTransDrift(k) * (j-start);
            rotNoDriftVal(j-start+1,k) = rotVal(j,k)- meanRotDrift(k) * (j-start);
        end
    end
    
    %plotting end point distribution with object trajectory
    figure,
    plot3(x,y,z, 'LineWidth', 0.9)
    hold on 
    plot3(transVal(:,1), transVal(:,2), transVal(:,3),'.', 'markersize', 20)
    xlabel('x [mm]')
    ylabel('y [mm]')
    zlabel('z [mm]')
    %setting up the axis 
    upperLimit = max([max(x),max(y),max(z)]);
    lowerLimit = min([min(x),min(y),min(z)]);
    axis([lowerLimit upperLimit lowerLimit upperLimit lowerLimit upperLimit])
    %placing grids and setting the font and graph axis lines  
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    axis square
    ax = gca
    ax.LineWidth = 1
    grid on
    
    %covariance calculation for repeatability 
    transSD(i) = (max(eig(cov(transNoDriftVal))))^0.5
    rotSD(i) = (max(eig(cov(rotNoDriftVal))))^0.5
end 