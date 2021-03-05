function [zdot,ifcollide] = rhs(t,z,p,h,outstrct_w,outstrct_a)
%{
% rhs is the abbreviation for "right hand side" function. i.e. y' = f(t,y)
% It is the system of differential equations to be solved.
% INPUT:    
%   t: hours since 1990-01-01 00:00:00 [hour]
%   z: current coordinates at t; 
%        z(1): current longitude coordinate [deg] 
%        z(2): current latitude coordinate [deg]
%   p: struct created in main
%   h: the handle to the figure showing intergation progress
%   outstrct_w:struct containing fileds of data for ocean current
%   outstrct_a:struct containing fileds of data for wind
% OUTPUT:
%   zdot: boat's velocity at t [deg/s]
%   ifcollide: 1 if there's collistion between boat and any land; 0 otherwise

% Date: Oct. 29 2020
% Author: Daisy Zhang
%}

global DIFF

pos = z(1:2);

[vcx,vcy,ifcollide_sea] = seamotion(pos(1),pos(2),t,outstrct_w); % water velocity rel.to ground [m/s]

if ~ifcollide_sea % if not collide 
    [vax,vay,ifcollide_wind] = windmotion(pos(1),pos(2),t,outstrct_a);% wind velocity rel.to ground [m/s]
else 
    vax = 0; vay = 0;ifcollide_wind = 1;
end

ifcollide = ifcollide_sea||ifcollide_wind; 

if ~ifcollide % if no collision happens
    wind_spd = norm([vax,vay]); % wind speed at 10 m above sea surface
    surface_wind_spd = (.1)^(0.11)*wind_spd; % wind speed at sea surface; check research report for the equation
    [vx,vy] = polar_plot(surface_wind_spd,p,pos(1),pos(2)); % boat velocity rel. to water [m/s]
    zdot = [vcx+vx,vcy+vy]; % boat velocity rel. to ground [m/s]
    R = 6.371*10^6; % radius of Earth
    zdot = [rad2deg(zdot(1)/(R*cos(deg2rad(pos(2)))));rad2deg(zdot(2)/R)]; % convert boat velocity in [m/s] to [deg/s]
else % if any collision happens
    zdot = [0,0];
end

waitbar((t-DIFF-p.t0)/(p.tf-p.t0),h); % update the handle bar
end