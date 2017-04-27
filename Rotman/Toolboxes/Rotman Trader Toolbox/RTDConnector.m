classdef RTDConnector < handle
    %RTDCONNECTOR connects MATLAB(R) to an Excel(R) compatible Real-Time Server
    %
    %   RTS = RTDCONNECTOR(RTDPROGID) creates a connection to an
    %   Excel compatible Real-Time Data Server defined by the
    %   program id in RTDPROGID.  RTS is a connection object.
    %
    %
    %   Example
    %   rts = RTDConnector('RIT2.RTD');
    %
    
    % Auth/Revision:  Stuart Kozola
    %                 Copyright 2015 The MathWorks, Inc.
    %                 $Id$
    
    
    properties (SetAccess = private)
        RTDProgID;
        topic;
        alive = false;
    end % properties
    
    properties (Access = private)
        rtdServer;
    end % private properties
    methods
        function this = RTDConnector(RTDProgID)
            %
            
            %TODO: Add RTDServer call for off local machine use
            
            % is .NET available
            assert(NET.isNETSupported,'RTDConnector:isNetSupported','Microsoft .NET Framework not found.  You need to install a supported .NET Framework to connect to and RTD Server.  Please see the documentation on how to call .NET libraries for more information.')
            
            % Find the RTDProgID in registry and create server instance
            rtdID = System.Type.GetTypeFromProgID(RTDProgID);
            assert(~isempty(rtdID),'RTDConnector:noProgramID','Program ID could not be found in Windows Registry');
            this.rtdServer = System.Activator.CreateInstance(rtdID);
            
            % Create the callback class
            switch computer('arch')
                case 'win64'
                    dll = 'RTDConnector64.dll';
                    netLoc = which('RTDConnector64.net');
                    if ~isempty(netLoc)
                        movefile(netLoc,fullfile(fileparts(netLoc),'RTDConnector64.dll'));
                    end
                case 'win32'
                    dll = 'RTDConnector32.dll';
                    netLoc = which('RTDConnector32.net');
                    if ~isempty(netLoc)
                        movefile(netLoc,fullfile(fileparts(netLoc),'RTDConnector32.dll'));
                    end
                otherwise
                    error('RTDConnector can only run on Windows 32 or 64 bit systems')
            end
            p = which(dll);
            NET.addAssembly(p);
            updateEvent = RTDConnector.UpdateEvent;
            
            % Start the RTD server
            ret = ServerStart(this.rtdServer,updateEvent);
            assert(ret == 1,'RTD Server failed to start');
            
            this.RTDProgID = RTDProgID;
            this.alive = true;
            this.topic = containers.Map('KeyType','int32','ValueType','char');
            
        end% RTDConnector Constructor
        
        function tf = canConnect(this)
            %CANCONNECT E checks if the server is alive and available
            %
            %   tf = canConnect(RTDConnector) returns true/1 if the server
            %   is available and false/0 otherwise.
            %
            %   Example:
            %   rts = RTDConnector('RIT2.RTD');
            %   tf = canConnect(rts)
            
            tf = logical(Heartbeat(this.rtdServer));
        end % isalive
        
        function [data,n] = updateTopics(this,topicCounts)
            %UPDATETOPICS retrieves updates to topics
            %
            %  data = updateTopics(RTDConnector) updates the
            %  all data from the subscribed topics.
            %
            %  data = updateTopics(RTDConnector,TOPICCOUNTS) updates
            %  subscribed topics from 1 to TOPICCOUNTS.
            %
            %  [data,n] = updateTopics(...) returns in N the number of
            %  topics updated.
            %
            %  Example:
            %   rts = RTDConnector('RIT2.RTD');
            %   subscribe(rts,{'TRADERNAME'; {'CRZY','LAST'}});
            %   [data,n] = updateTopics(rts)
            
            if ~exist('topicCounts','var')
                topicCounts = max(cell2mat(this.topic.keys));
            end
            
            [data, n]  = RefreshData(this.rtdServer,topicCounts);
            data = net2ml(data);
        end % updateTopics
        
        function ret = subscribe(this,newTopics)
            %SUBSCRIBE adds the topic to list of topics to monitor
            %
            %   topicList = subscribe(RTDConnector,topics) adds the topics to the list
            %   of subscrived topics for the data server to update.  Topics
            %   is a cell array of strings that list the topics by rows.
            %   TopicList returns the suscription as a string.
            %
            %   Example:
            %   rts = RTDConnector('RIT2.RTD');
            %   topic = subscribe(rts,{'TRADERNAME'; {'CRZY','LAST'}})
            
            if ~this.alive
                error('RTDCONNECTOR:ServerStopped','Server must be started to add topics.  Issue start(...) to restart the connection.')
            end
            if ischar(newTopics)
                newTopics = {newTopics};
            end
            if istable(newTopics)
                newTopics = newTopics(:,{'Field1','Field2','Field3'});
            end
            [r,~] = size(newTopics);
            
            % update topicIDs and add them to the server
            ret = cell(r,1);
            mxTopic = max(cell2mat(keys(this.topic)));
            if isempty(mxTopic)
                mxTopic = 0;
            end
            for t = 1:r
                id = mxTopic+t;
                aTopic = newTopics{t,:};
                if ischar(aTopic)
                    aTopic = {aTopic};
                end
                str = NET.createArray('System.String',length(aTopic));
                for i = 0:str.Length-1
                    str.Set(i,num2str(aTopic{i+1}));
                end
                [retVal, retStr, newval] = ConnectData(this.rtdServer,id,str,true);
                ret{t} = char(retVal);
                % check for duplicate subscriptions by return value
                if ismember(ret{t},this.topic.values)
                    % remove it since it already exists
                    this.topic(id) = 'unsubscribing';
                    unsubscribe(this,id);
                else
                    % does not exist so create it
                    this.topic(id) = ret{t};
                end
            end
        end % subscribe
        
        function start(this)
            %START starts the server with subscibed topics if any
            %
            %   START(RTDConnector) starts the server and subscirves to
            %   topics, if defined.
            %
            %   Example:
            %   rts = RTDConnector('RIT2.RTD');
            %   start(rts)
            topics = values(this.topic);
            this = RTDConnector(this.RTDProgID);
            if ~isempty(topics)
                subscribe(this,topics(:));
            end
        end % start
        
        function stop(this)
            %STOP shuts down the RTD server connection
            ServerTerminate(this.rtdServer);
            this.alive = false;
        end % stop
        
        function unsubscribe(this,topicID)
            %UNSUBSCRIBE removes a topic from subscription list
            %
            %   UNSUBSCRIBE(RTDConnector,topicID) removes the topic by
            %   topicID from the subscription list.
            %
            %   Example:
            %   rts = RTDConnector('RIT2.RTD');
            %   subscribe(rts,{'TRADERNAME'; {'CRZY','LAST'}});
            %   unsubscribe(rts,1)
            %   rts.topic.keys
            
            remove(this.topic,num2cell(topicID));
            
            for id = 1:length(topicID)
                try
                    DisconnectData(this.rtdServer,topicID(id));
                catch e
                    if ~strcmpi(class(e.ExceptionObject),'System.Collections.Generic.KeyNotFoundException')
                        rethrow(e);
                    else
                        warning('TOPICID:NOTFOUND','Topic with id %d was not found in subscription',topicID(id))
                    end
                end
            end
        end % unsubscribe
        
        function delete(this)
            stop(this);
        end % stop
        
    end % methods
end % RTDConnector