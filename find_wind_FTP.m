function outstrct = find_wind_FTP(t)
%{
% Achieve wind data automatic retrieval via FTP server
% Extremely slow - do not recommend 
% INPUT:    
%   t: hours since 1990-01-01-00:00:00 [hour]

% OUTPUT:
%   outstrct: strct containing applicable wind data info

% Date: Oct. 28 2020
% Author: Daisy Zhang
%}

YOUR_CMEMS_USERNAME = ''; % your username to cmems account
YOUR_CMEMS_PASSWORD = ''; % your password to cmems
DATA_PATH = './Core/WIND_GLO_WIND_L4_NRT_OBSERVATIONS_012_004/CERSAT-GLO-BLENDED_WIND_L4-V6-OBS_FULL_TIME_SERIE'; % the path to data file in FTP driver
ftpobj = ftp('nrt.cmems-du.eu',YOUR_CMEMS_USERNAME,YOUR_CMEMS_PASSWORD,'System','WINDOWS','LocalDataConnectionMethod','passive');
cd(ftpobj,DATA_PATH);

temp = datetime('19900101','InputFormat','yyyyMMdd');
now = temp+hours(t);
if month(now)<10 % if the month is from Jan to Sep (01-09)
    folder = sprintf('./%i/0%i',year(now),month(now));
else % otherwise (10-12)
    folder = sprintf('./%i/%i',year(now),month(now));
end
cd(ftpobj,folder); % move to the folder containing the month of data
listing = dir(ftpobj); % listing all files inside the folder
file = NaN;
for i = 1:length(listing)-1
    file_date = listing(i).name(1:10); % parse the date
    file_date = datetime(file_date,'InputFormat','yyyyMMddHH');
    file_date_next = listing(i+1).name(1:10); % parse the date
    file_date_next = datetime(file_date_next,'InputFormat','yyyyMMddHH');
    if file_date==now || (file_date<now && now < file_date_next) 
        file = listing(i).name;
    end
end

if isnan(file)
    file = listing(end).name;
end

file_name = mget(ftpobj,file); % download the file
[finfo outstrct] = read_nc_file_struct(file_name{1}); % convert the NetCDF file to struct
close(ftpobj);
end