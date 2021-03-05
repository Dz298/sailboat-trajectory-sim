[~, outstrct]=read_nc_file_struct('CERSAT-GLO-BLENDED_WIND_L4-V6-OBS_FULL_TIME_SERIE_1581555950466.nc');
spd =  (1/10).^(0.11).*sqrt(outstrct.eastward_wind.^2+outstrct.northward_wind.^2);
spd = reshape(spd,[],1);
histogram(spd(:,1))
title('Surface Wind Speed Distribution')
xlabel('Wind Speed [m/s]')