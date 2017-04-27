function updatePlotFcn(h,data)
%UPDATEPLOTFCN is an example function for updating a line plot

% Copyright 2015 The MathWorks, Inc.

% update x axis
x = datenum(data.lastUpdate);
h(1).XData(end+1) = x;
h(2).XData(end+1) = x;
h(3).XData(end+1) = x;

% update y axis
h(1).YData(end+1) = data.crzy_bid;
h(2).YData(end+1) = data.crzy_last;
h(3).YData(end+1) = data.crzy_ask;

% update plot format
datetick('x','HH:MM:SS');
xlim('auto');
drawnow;