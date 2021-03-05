%{
% Main script for the simulation trajectory program
% 
% Date: Oct. 28 2020
% Author: Daisy Zhang
%}

clear % clear all variables including global variables
clear global 

% % ============The code below will open a world map. User can ============
% %   follow the instructions to select the start location and destination
% % =======================================================================
worldmap world
load coastlines
plotm(coastlat, coastlon)
h = gcf;
h.Units = 'normalized';
h.Position = [0.1,0.1,0.8,0.8];
title('Click to Select Your Starting Point, then Click to Select Your End Point')
[lat, lon] = inputm(2);
close gcf
x0 = lon(1); % initial lon * same way measuring lon as wind dataset* 
y0 = lat(1); % initial lat
y_des = lat(2); x_des = lon(2);
% % ============The code above will open a world map. User can ============
% %   follow the instructions to select the start location and destination
% % =======================================================================

% % Start location coordinates
% % x: longtitude AND y:latitude 
% x0 = -59.8683;y0 = 39.0402; % equivalent to 39.0402 degree N, 59.8683 W
% % destination coordinates equivalent to 34.20 degree N, 34.20 W
% x_des = -34.204359486664400; y_des = 34.201656541126450; 

%p is a structure containing all necessary information for the tour
p = struct;
p.des = [x_des,y_des]; % store the destination to p structure

% Initial conditions
spd = 0;
theta0 = 0;
z0 = [x0,y0]';
zdot0 = [spd*cos(theta0),spd*sin(theta0)]'; 

dataStart = datetime('19900101','InputFormat','yyyyMMdd'); % dataset starting date
start = datetime('20190101','InputFormat','yyyyMMdd'); % simulated tour start date

% hours btw 1990-01-01 00:00:00 and 2019-01-01 00:00:00
global DIFF 
DIFF = hours(start-dataStart);

% maximum travel duration (in hours)
% if users want to change the tour end date, just replace 20190301 to the
% desired date
p.tf = hours(datetime('20190301','InputFormat','yyyyMMdd')-start);
% tour state time i.e. the boat will be launched "t0" hours after "start".
p.t0 = 0; 

% trajectory(T+deltaT) = trajectory(T) + velocity*deltaT
% fps = 3600/(deltaT) i.e. times of updates per hour
p.fps =1; 
p.tspan = linspace(p.t0+DIFF,p.tf+DIFF,(p.tf-p.t0)*p.fps);

% struct containing fileds of data for ocean current
% fields include:
% - depth: the depth of the measured ocean current [m]
% - latitude, longtitude: as the name specified [deg] 
%               e.g. -30 in longitude = 30 degrees W; -30 in latitude = 30
%               degrees S.
% - vo, uo: at depth, water current speed in v direction, u direction respectively [m/s]
% - times: the time of the ocean current being measured [hours after 1950-01-01]
% other detailed information can be found in the research report 
% "Simulating the Trajectory for a Directionally Stable Sailboat" by Daisy
% Zhang
[~, outstrct_w]=read_nc_file_struct('./global-analysis-forecast-phy-001-024-3dinst-uovo_1595967643151.nc');

% struct containing fileds of data for ocean current
% fields include:
% - lat, lon: as the name specified [deg] 
%               e.g. -30 in lon = 30 degrees W; -30 in lat = 30
%               degrees S.
% - northward_wind, eastward_wind: at 10 m above sea surface, wind speed in north direction, 
%                                  and east direction respectively [m/s]
% - time: the time of the wind velocity being measured [hours after 1990-01-01]
% other detailed information can be found in the research report 
% "Simulating the Trajectory for a Directionally Stable Sailboat" by Daisy
% Zhang
[~, outstrct_a]=read_nc_file_struct('CERSAT-GLO-BLENDED_WIND_L4-V6-OBS_FULL_TIME_SERIE_1581555950466.nc');

h=waitbar(0,'Sailing...');
% =====================Core of the program ===============================
[t,zarray]=myOde(@rhs,p.tspan,z0,p,h,outstrct_w,outstrct_a,NaN,NaN);
close(h);
% plot the simulated trajectory on map, along with other information 
stats(t,zarray,p)
% ========================================================================

function [t,zarray] = myOde(rhs,tspan,z0,p,h,outstrct_w,outstrct_a,init_strct_in_use,init_wind_file)
% ODE solver that can solve systems of equations of the form y' = f(t,y)
% INPUT:
%   - rhs: the right-hand-side function
%   - tspan: time span
%   - z0: initial conditions
%   - p: sturcture storing tour information
%   - h: the handle to the figure showing intergation progress
%   - outstrct_w: struct storing ocean current data
%   - outstrct_a: struct storing wind data
%   - init_strct_in_use: NaN when the program doesn't use automation
%                   data retrieval; otherwise, init_strct_in_use is the
%                  strct containing wind data for the beginning of the
%                  simulation
%   - init_wind_file: NaN when the program doesn't use automation
%                   data retrieval; otherwise, init_wind_file is the name
%                   of the NetCDF file containing wind data for the
%                   beginning of the simulation
% OUTPUT:
%   - t: tspan
%   - zarray: numerical solution to the integration of rhs over tspan with
%               initial conditions z0
global DIFF
numInt = 1; % number of iterations
t = tspan;
dt = (tspan(2) - tspan(1))*3600;
zarray = z0;
z = zarray(:,end);
i = 1;
while i <= length(tspan)
    time = tspan(i);
    ifcollide = 0; % the boat doesn't collide with land
    for k=1:numInt
% % ============The code below will allow data automation retrieval========
% %             Read find_wind_HTTPS doc before uncommenting the code below
%         [file_name,outstrct] = find_wind_HTTPS(init_wind_file,init_strct_in_use,time,double(i==1));
%         init_wind_file = file_name;
%         init_strct_in_use = outstrct;
% % ============The code above will allow data automation retrieval========
        [zdot,ifcollide]=rhs(time,z,p,h,outstrct_w,outstrct_a);
        z=z+(1/numInt)*dt*zdot;
    end
    if ifcollide % if a collision happens
        idx = find(tspan==time);
        t = tspan(1:idx)-DIFF; % the time when the collision happens
        break % break the loop
    else
    zarray(:,end+1) =z;
    i = i+1;
    end
end
t = t-DIFF; 
end
