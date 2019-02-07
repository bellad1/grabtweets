function test

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
tw.sampleSize = 5000;               % set sample size for processing

% Load previous tweets
load('~/Desktop/twitter/data/twtarchive2018.mat')

% Make sure there are no duplicate tweets
[t] = rem_dup_twt(t);

% Call summary function to get tweet statistics
tweetingSummary(tw,t);

% Tweet statistics
doy           = 365;         % Current day of year
tw.data.tperd = tw.data.originalcnt/doy;  % Tweets per day

% Projected number of tweets
if ~isleapyear
    tw.data.tproj = ((365-doy)*tw.data.tperd)+tw.data.originalcnt;
else
    tw.data.tproj = ((366-doy)*tw.data.tperd)+tw.data.originalcnt;
end

time        = datetime;
time.Format = 'yyyy-MM-dd_H:mm:ss';
c           = strsplit(char(time),'_');

fprintf('Date            : %s\n',c{1})
fprintf('Time            : %s\n',c{2})
fprintf('Total tweets    : %d\n',tw.data.tweetscnt)
fprintf('Original tweets : %d\n',tw.data.originalcnt)
fprintf('Tweets per day  : %4.3f\n',tw.data.tperd)
fprintf('Projected count : %7.2f\n',tw.data.tproj)
end

function [t_out] = rem_dup_twt(t)
% Extract all id numbers
for i = 1:numel(t)
  id(i) = t{i}.id;
end
% Find duplicates
[~,ia,ic] = unique(id);
dup_ind = setdiff(1:max(size(id)),ia);
t(dup_ind) = [];
t_out = t;
end
