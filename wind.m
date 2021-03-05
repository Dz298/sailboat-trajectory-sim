function [u,v,ifcollide] = wind(x,y,t)
% NOT IN USE - Dataset being fetched no longer use

path = './wind data';
files = dir (strcat(path,'/*.nc'));
L = length (files);
temp = datetime('19900101','InputFormat','yyyyMMdd');
now = temp+seconds(t*3600);
global wind_data
global i_init
u = NaN;
v = NaN;
ifcollide=0;
global NAME
for i=i_init:L-1
   t1 = datetime(files(i).name(17:31),'InputFormat','yyyyMMdd_HHmmss');
   t2 = datetime(files(i+1).name(17:31),'InputFormat','yyyyMMdd_HHmmss');
   if now-t1>=0 && now-t2<=0
       if i_init == 1 && i>45
               start = i-45;
       elseif i_init == 1 && i<=45
               start = 1;
       elseif i_init ~= 1 
           start = i_init-10;
       end
           for j = start:i
               [~, outstrct]=read_nc_file_struct(strcat(path,'\',files(j).name));
               non_nan = ~isnan(outstrct.wind_speed);
               R = 6.371*10^6;
               [out_x,out_y,out_z] = sph2cart(deg2rad(outstrct.lon(non_nan)),deg2rad(outstrct.lat(non_nan)),R);
               [target_x,target_y,target_z] = sph2cart(deg2rad(x),deg2rad(y),R);
               Non_nan_lon = outstrct.lon(non_nan);
               
               c = (sqrt((out_x-target_x).^2+(out_y-target_y).^2+(out_z-target_z).^2)<=12.5*10^3);
               if any(c(:)~=0)
                   cc = min(Non_nan_lon(abs(outstrct.lat(non_nan)-y)<=0.5))<x && max(Non_nan_lon(abs(outstrct.lat(non_nan)-y)<=0.5))>x;
                   if cc
                       wind_data.lat = outstrct.lat;
                       wind_data.lon = outstrct.lon;
                       wind_data.wind_speed= outstrct.wind_speed;
                       wind_data.wind_dir = outstrct.wind_dir;
                       NAME = strcat(path,'\',files(j).name);
                   end
               end
           end 
    i_init = i;
    break
    end
end
%% radius for choosing the wind data?? also check if old wind_data lat and long can find the wind data needed if new outstrct is not ava.
R = 6.371*10^6;
non_nan = ~isnan(wind_data.wind_speed);
[out_x,out_y,out_z] = sph2cart(deg2rad(wind_data.lon(non_nan)),deg2rad(wind_data.lat(non_nan)),R);
[target_x,target_y,target_z] = sph2cart(deg2rad(x),deg2rad(y),R);
loc = (sqrt((out_x-target_x).^2+(out_y-target_y).^2+(out_z-target_z).^2)<=12.5*10^3);
non_nan_spd =  wind_data.wind_speed(non_nan);
non_nan_dir = wind_data.wind_dir(non_nan);
u = non_nan_spd(loc).*cosd(-90-non_nan_dir(loc));
v = non_nan_spd(loc).*sind(-90-non_nan_dir(loc));
% figure
% quiver(out_x(loc),out_y(loc),u,v,'k')
% hold on
% d1=non_nan_dir(loc);
% d1=d1(1)
% d = -90-non_nan_dir(loc);
% d = deg2rad(d(1))
% theta = atan2(v(1),u(1))
% angle = theta+pi-pi/6; 
% vx = 8*cos(angle);
% vy = 8*sin(angle);
% quiver(out_x(loc),out_y(loc),vx*ones(length(u),1),vy*ones(length(v),1),'r')
% title('Velocity of the Boat during Travel\nChecking constant angle between absolute wind and its course heading')
% hold off

% loc = (abs(wind_data.lat-y)<=.5)& (abs(wind_data.lon-x)<=.5);
% any(loc(:)~=0)
% u = wind_data.wind_speed(loc).*cosd(-90-wind_data.wind_dir(loc));
% v = wind_data.wind_speed(loc).*sind(-90-wind_data.wind_dir(loc));
if length(u) > 1
%     fprintf('%.0f loc found.\n',length(u))
%% todo: interpolate
        u = u(1);
        v = v(1);
        
    
end
if isempty(u)||isempty(v)||isnan(u) || isnan(v) 
    fprintf('collision\n')
    u = 0; v = 0;
    ifcollide = 1; 
end