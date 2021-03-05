function [file_name,outstrct] = find_wind_HTTPS(file,strct_in_use,t,iffirst)
%{
% Achieve wind data automatic retrieval via HTTPS server
% INPUT: 
%   file: wind data file name which is used for the simulation right now
%   strct_in_use: strct containing wind data info in use for the simulation
%                 right now           
%   t: hours since 1990-01-01-00:00:00 [hour]
%   iffirst: 1 if no wind data set being automatically downloaded on file, 0 otherwise

% OUTPUT:
%   file_name: the name of the file just being downloaded
%   outstrct: strct containing applicable wind data info

% Date: Oct. 28 2020
% Author: Daisy Zhang
%}

YOUR_CMEMS_USERNAME = ''; % your username to cmems account
YOUR_CMEMS_PASSWORD = ''; % your password to cmems
YOUR_LOCAL_PATH = 'C:\Users\daisy\Desktop\SimTemp CurrentOnly'; % the path for storing downloaded data file
if iffirst
    
    temp = datetime('19900101','InputFormat','yyyyMMdd');
    now = temp+hours(t);
    begin_date = datetime([year(now),month(now),day(now)]);
    
    % 5 months of data is around 1 GB, the maximum size available for 
    % download each time. Can input smaller number for better download success rate.
    end_date = begin_date + calmonths(5); 
    
    % the file format of data file in the dataset
    formatOut =  'yyyy-mm-dd HH:MM:ss';
    begin_date_str = datestr(begin_date,formatOut);
    end_date_str = datestr(end_date,formatOut); 
    % the file format for renaming the downloaded data
    formatOutfile = 'yyyymmddHHMMss';
    begin_date_str_file = datestr(begin_date,formatOutfile);
    end_date_str_file = datestr(end_date,formatOutfile);
    % the name of the downloaded file
    file_name = [begin_date_str_file, end_date_str_file,'.nc'];
    command = ['python -m motuclient --motu http://nrt.cmems-du.eu/motu-web/Motu --service-id WIND_GLO_WIND_L4_NRT_OBSERVATIONS_012_004-TDS --product-id CERSAT-GLO-BLENDED_WIND_L4-V6-OBS_FULL_TIME_SERIE --longitude-min -100 --longitude-max 10 --latitude-min 0 --latitude-max 60 --date-min "' begin_date_str '" --date-max "' end_date_str '" --variable eastward_wind  --variable northward_wind --out-dir "' YOUR_LOCAL_PATH '" --out-name "' begin_date_str_file end_date_str_file '.nc" --user "' YOUR_CMEMS_USERNAME '" --pwd "' YOUR_CMEMS_PASSWORD '"'];
    
    [status,cmdout] = system(command) % open a new cmd window and execute command

    [~,outstrct] = read_nc_file_struct(file_name);
else
    temp = datetime('19900101','InputFormat','yyyyMMdd');
    now = temp+hours(t);
    begin_date = datetime(file(1:14),'InputFormat','yyyyMMddHHmmss');
    end_date = datetime(file(15:28),'InputFormat','yyyyMMddHHmmss');
    if now <= end_date && now >= begin_date % if time is within the time span of current available file  
        outstrct = strct_in_use;
        file_name = file;
    else  % otherwise 
        begin_date = end_date;
        % 5 months of data is around 1 GB, the maximum size available for 
        % download each time. Can input smaller number for better download success rate.
        end_date = begin_date + calmonths(5);
        
        % the file format of data file in the dataset
        formatOut =  'yyyy-mm-dd HH:MM:ss';
        begin_date_str = datestr(begin_date,formatOut);
        end_date_str = datestr(end_date,formatOut); 
        % the file format for renaming the downloaded data
        formatOutfile = 'yyyymmddHHMMss';
        begin_date_str_file = datestr(begin_date,formatOutfile);
        end_date_str_file = datestr(end_date,formatOutfile);
        file_name = [begin_date_str_file, end_date_str_file,'.nc'];
        command = ['python -m motuclient --motu http://nrt.cmems-du.eu/motu-web/Motu --service-id WIND_GLO_WIND_L4_NRT_OBSERVATIONS_012_004-TDS --product-id CERSAT-GLO-BLENDED_WIND_L4-V6-OBS_FULL_TIME_SERIE --longitude-min -100 --longitude-max 10 --latitude-min 0 --latitude-max 60 --date-min "' begin_date_str '" --date-max "' end_date_str '" --variable eastward_wind  --variable northward_wind --out-dir "' YOUR_LOCAL_PATH '" --out-name "' begin_date_str_file end_date_str_file '.nc" --user "' YOUR_CMEMS_USERNAME '" --pwd "' YOUR_CMEMS_PASSWORD '"']; 
        [status,cmdout] = system(command)  % open a new cmd window and execute command
        [~,outstrct] = read_nc_file_struct(file_name);
        delete(file);
        
    end 
end
end
% file_name = file;
% outstrct = strct_in_use;