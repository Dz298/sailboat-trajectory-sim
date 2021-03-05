[~, outstrct]=read_nc_file_struct('./CERSAT-GLO-BLENDED_WIND_L4-V6-OBS_FULL_TIME_SERIE_1580874656933.nc');
f = figure;
i = 1;

[maplat,maplon] = meshgrid(outstrct.lat,outstrct.lon);

% while ishandle(f)
    non_nan = ~isnan(outstrct.wind_speed(:,:,i));
    plot(maplon(~non_nan),maplat(~non_nan),'r.');
    hold on
    plot(maplon(non_nan),maplat(non_nan),'b.');
    axis equal
    pause(0.5);
    i = i+1;
% end