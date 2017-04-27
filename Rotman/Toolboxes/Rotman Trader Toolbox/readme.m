%% Rotman Trader Toolbox
% This document will help you get set up and running with the
% |roatmanTrader| functionality for connecting to Rotman Interactive Trader.

% Copyright 2015 The MathWorks, Inc.

%% System Requirements
% You need to be on a windows 32-bit or 64-bit operating system with .NET
% Framework installed.  You will also need to have the RTD and API
% libraries installed as well as Rotman Interactive Trader.  More
% information on Rotman Interactive Trader software can be found here:
% http://rit.rotman.utoronto.ca/software.asp.
%
%% Required Dependencies
% To use |rotmanTrader| you need to have the appropriate DLLs installed to
% communicate to Rotman Interactive Trader.  Run the |installRIT| script to
% check for the appropriate files and download and install any missing
% librariries.  It will also rename RTDConnectorXX.net to a DLL.
installRIT

%% Read the Examples
% To get started using |rotmanTrader| read the two examples in the html
% folder. <tradingExample.html> and <streamingDataExample.html> or step
% through the matlab files |tradingExamples| or |streamingDataExamples|

%% Student Competition
% If you are using this functionality as part of the Rotman International
% Student Competition, you can request MATLAB software and view additional
% resources at http://www.mathworks.com/academia/student-competitions/rotman-trading/index.html
