% Set up paths to twitty and json parser
addpath(genpath('~/Desktop/twitter/creds'));  % Credentials
addpath(genpath('~/Desktop/twitter/data'));   % Data
addpath(genpath('~/Desktop/twitter/out'));    % Output folder
addpath(genpath('~/Desktop/twitter/json/parse_json')); % Twitty's default json parser
addpath(genpath('~/Desktop/twitter/json/jsonlab-1/jsonlab-1.5')); % JSONlab parser

% Load credentials
load('~/Desktop/twitter/creds/creds.mat');

% Create twitty object
tw = twitty(creds);                 % instantiate a Twitty object
tw.jsonParser = @loadjson;          % specify JSONlab as json parser
tw.batchSize  = 50;                 % set batch size for processing
tw.sampleSize = 50000;              % set sample size for processing

% This id number corresponds to the last tweet of 2017
id1 = 947614110082043904;

% Loop through pages to retrieve most recent 2000 tweets. Need a more
% efficient method in the future
for i = 1:20
    S{i} = tw.userTimeline('screen_name','realDonaldTrump',...
    'since_id',int64(id1),'include_rts','true',...
    'include_entities','true','count',200,'page',double(i));
end
% for i = 1:20
%     S{i} = tw.userTimeline('screen_name','realDonaldTrump',...
%     'include_rts','true','include_entities','true',...
%     'count',200,'page',double(i));
% end
s = horzcat(S{1,:});
% numel(s)
%t = horzcat(s,t);
