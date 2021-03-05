path = './wind data';
files = dir (strcat(path,'/*.nc'));
L = length (files);
h = figure(1);
i=1;
while ishandle(h)
   drawwind(strcat(path,'\',files(i).name));
   axis equal
    pause(0.5)
    i=i+1;
end
% 
% h2=plot(295,40,'rs','markersize',5,'linewidth',2);
function drawwind(file)
[~, outstrct]=read_nc_file_struct(file);
% u = outstrct_atemp.wind_speed.*cosd(-90-outstrct_atemp.wind_dir);
% v = outstrct_atemp.wind_speed.*sind(-90-outstrct_atemp.wind_dir);
% quiver(outstrct_atemp.lon,outstrct_atemp.lat,u,v)
non_nan = ~isnan(outstrct.wind_speed);
% figure(1)
plot(outstrct.lon(~non_nan),outstrct.lat(~non_nan),'r.');
hold on
plot(outstrct.lon(non_nan),outstrct.lat(non_nan),'b.');
axis equal
% 
% title('Positions of All Data Points from Wind Data')
% xlabel('Longtitude')
% ylabel('Latitude')
% figure(2)
% [x,y,z] = sph2cart(deg2rad(outstrct.lon(non_nan)),deg2rad(outstrct.lat(non_nan)),6.4*10^6);
% stem3(x,y,z,'linestyle','none','marker','.')
% 
% title('Positions of All Data Points from Wind Data in Spherical Coord')
end