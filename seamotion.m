function [u,v,ifcollide] = seamotion(x,y,t,outstrct)
%{
% Output water current velocity and flag of any collision at the given time
% and location
% INPUT:   
%   x: current longitude [deg] 
%   y: current latitude [deg]
%   t: hours since 1990-01-01 00:00:00 [hour]
%   outstrct:struct containing fileds of data for ocean current
% OUTPUT:
%   u: zonal water current speed at (x,y) when t [m/s]
%   v: meridional current speed at (x,y) when t [m/s]
%   ifcollide: 1 if there's collistion between boat and any land; 0 otherwise

% Date: Oct. 29 2020
% Author: Daisy Zhang
%}

ifcollide = 0;
lat = length(outstrct.latitude);
lon = length(outstrct.longitude);

temp = datetime('19900101','InputFormat','yyyyMMdd');
hour_diff = hours(temp+hours(t)-datetime('19500101','InputFormat','yyyyMMdd')); % hours since 1950-01-01 00:00:00

u = inf; v = inf;

% find the index of current time in file
for i = 1:length(outstrct.time)
    if hour_diff == outstrct.time(i) || (hour_diff > outstrct.time(i) && ...
            hour_diff < outstrct.time(i+1))
        time = i;
    end
end

% find the indexes of latitude and longitude in file, then do bilinear
% interpolation
for j = 1:lat
    for i = 1:lon
        if outstrct.latitude(j) <= y && outstrct.latitude(j+1) >= y ...
            && outstrct.longitude(i) <= x && outstrct.longitude(i+1) >= x
            u = grid_interpol(x,y,time,outstrct,i,j,outstrct.uo);
            v = grid_interpol(x,y,time,outstrct,i,j,outstrct.vo);
            break
        end
    end
    if ~isinf(u) && ~isinf(v) % if u and v are found, break the loop
        break
    end
end 

if isnan(u)||isnan(v) % if any u or v is NaN, collision happens
    fprintf('Land Collision\n')
    u = 0;
    v = 0;
    ifcollide = 1;
end

function u = grid_interpol(x,y,t,outstrct,i,j,uo)
% Bilinear interpolate on the outstrct to find speed at the point (x,y) 
% at given time
% INPUT:
%   x: longtitude coordinate [deg]
%   y: latitude coordinate [deg]
%   t: the index of time approximating to current time so that
%       outstrct.time(t) < current time < outstrct.time(t+1)
%   outstrct: the struct containing data
%   i: the index of longitude so that
%       outstrct.longitude(i) < x < outstrct.longitude(i+1)
%   j: the index of latitude so that
%       outstrct.latitude(i) < y < outstrct.latitude(i+1)
%   uo: the matrix to be interpolated

lo =round([outstrct.longitude(i) outstrct.longitude(i+1)],2);
la = round([outstrct.latitude(j) outstrct.latitude(j+1) ],2);

% create a rectilinear 2d grid for interpolation
u_mat = [uo(i,j,1,t) uo(i+1,j,1,t);uo(i,j+1,1,t) uo(i+1,j+1,1,t)];

[Lo,La] = meshgrid(lo,la);

x = round(x,2);
y = round(y,2);

[Loq,Laq] = meshgrid(lo(1):0.01:lo(2),la(1):0.01:la(2));

% interpolation for 2-D gridded data in meshgrid format
u_mat_q = interp2(Lo,La,u_mat,Loq,Laq,'linear');
Loq = round(Loq,2);
Laq = round(Laq,2);
tol = 0.005; % difference tolerance 
u = u_mat_q((abs(Loq-x)<tol)&(abs(Laq-y)<tol)); 
end

end