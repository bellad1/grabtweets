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

% Loop through pages to retrieve most recent 2000 tweets. Need a more
% efficient method in the future
for i = 1:20
    T{i} = tw.userTimeline('screen_name','realDonaldTrump',...
    'since_id',int64(947614110082043904),'include_rts','true',...
    'include_entities','true','count',200,'page',double(i));
end
t = horzcat(T{1,:});

%Print the tweets
fid = fopen('twttext1.txt','w');
for i = 1:numel(t)
    date = strsplit(t{i}.created_at);
    txt  = char(t{i}.text);
    if numel(txt) < 40
    fprintf(fid,'%4d %5s %5s %3s %10s %6s %43s\n',i,char(date(1)),char(date(2)),...
            char(date(3)),char(date(4)),char(date(6)),txt);
    else 
    fprintf(fid,'%4d %5s %5s %3s %10s %6s %43s\n',i,char(date(1)),char(date(2)),...
            char(date(3)),char(date(4)),char(date(6)),txt(1:40));
    end
end
fclose(fid);

