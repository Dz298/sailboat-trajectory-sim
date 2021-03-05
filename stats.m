function stats(t,zarray,p)
%{
% Plot the simulated trajectory (or other info if there exists)
% INPUT:   
%   t: tspan
%   zarray: numerical solution to the integration of differential equations
%   p: struct created in main

% Date: Oct. 29 2020
% Author: Daisy Zhang
%}

figure(2);
hold on;
zarray = zarray';
% plot the simulated trajectory
h1=plot(zarray(:,1),zarray(:,2),'linewidth',2,'DisplayName','Trajectory');
% plot start point
h2=plot(zarray(1,1),zarray(1,2),'rs','markersize',5,'linewidth',2,'DisplayName','Start');
text(zarray(1,1),zarray(1,2),'Start')

% plot destination point
h3=plot(p.des(1),p.des(2),'bs','markersize',5,'linewidth',2,'DisplayName','Destination');
text(p.des(1),p.des(2),'Destination')

% labels & title
xlabel('Latitude','fontsize',16);
ylabel('Longtitude','fontsize',16);
h=legend([h1,h2,h3]);
title(sprintf('Trajectory over %0.2f Days',(t(end)-t(1))/24))
set(h,'fontsize',14,'location','best');
axis equal;
axis([-100 25 0 80])

% Plots a google map on the current axes using the Google Static Maps API
plot_google_map('MapType','terrain')
axis([-100 25 0 80])

makescale;
set(h,'fontsize',14,'location','best');
hold off
end