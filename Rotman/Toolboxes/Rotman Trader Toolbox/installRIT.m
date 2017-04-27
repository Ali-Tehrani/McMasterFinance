%% Installation Script for Rotman Interactive Trader
% This script will check for the needed dependencies and install them if
% needed.

%  Copyright 2015, The MathWorks, Inc.

%% Check for Required Software and Operating System
disp('Checking for Rotman Ineteractive Trader API and RTD libraries...')
progIDs = {'RIT2.RTD', 'RIT2.API'};
% RIT2.dll is RIT2.API (win32 and win64)
% RIT2.RTD.dll is RIT2.RTD (win32)
% TTS.RTD.dll is RIT2.RTD (win64)

urls = {'http://www-2.rotman.utoronto.ca/finance/lab/RITv2/support/RIT2.API.RTD.Link-0.0.3.msi';
    'http://www-2.rotman.utoronto.ca/finance/lab/RITv2/support/RIT2.RTD.API.Link.x64-0.0.5.msi';
    'http://rit.306w.ca/client//Client.application';};
switch computer('arch')
    case {'win64','win32'}
        % is .NET available
        assert(NET.isNETSupported,'Microsoft .NET Framework not found.  You need to install a supported .NET Framework to connect to and RTD Server.  Please see the documentation on how to call .NET libraries for more information.')
        % check system for dlls
        for i = 1:length(progIDs)
            didFind = System.Type.GetTypeFromProgID(progIDs{i});
            dll(i) = ~isempty(didFind);
            if ~isempty(didFind)
                fprintf('Found %s (%d of %d)\n',progIDs{i},i,length(progIDs))
            end
        end
    otherwise
        error('This platform is not supported.  Please use a Microsoft Windows operating system')
end

%% Install Needed Files Dependencies
if sum(~dll) > 0
    mkdir download
    cd download
    urls = urls(logical([~dll 1]'));
    for i = 1:length(urls)
        parts = strsplit(urls{i},'/');
        fprintf('Downloading %s...',parts{end})
        websave(parts{end},urls{i});
        fprintf('done.\n Installing %s...',parts{end});
        system(parts{end});
        fprintf('done.\n');
    end
    cd ..
end

%% Test install
disp('Testing ...')
netLoc = which('RTDConnector64.net');
if ~isempty(netLoc)
    movefile(netLoc,fullfile(fileparts(netLoc),'RTDConnector64.dll'));
end
netLoc = which('RTDConnector32.net');
if ~isempty(netLoc)
    movefile(netLoc,fullfile(fileparts(netLoc),'RTDConnector32.dll'));
end

rit = rotmanTrader;
if ischar(rit.lastUpdate)
    disp('All is good')
else
    error('Something went wrong, please try to download and install manually from http://rit.rotman.utoronto.ca/software.asp')
end