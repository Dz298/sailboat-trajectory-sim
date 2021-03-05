function name = find_file_time(t)
path = './wind data';
files = dir (strcat(path,'/*.nc'));
L = length (files);
temp = datetime('19900101','InputFormat','yyyyMMdd');
now = temp+seconds(t*3600);
for i=1:L-1
   t1 = datetime(files(i).name(17:31),'InputFormat','yyyyMMdd_HHmmss');
   t2 = datetime(files(i+1).name(17:31),'InputFormat','yyyyMMdd_HHmmss');
   if now-t1>=0 && now-t2<=0
       name = files(i).name;
   end
end
end