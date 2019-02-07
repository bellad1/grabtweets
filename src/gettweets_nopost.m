function gettweets_nopost
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

% Loop through pages to retrieve most recent 2000 tweets. Need a more
% efficient method in the future
% for i = 1:10
%     T{i} = tw.userTimeline('screen_name','realDonaldTrump',...
%     'since_id',int64(947614110082043904),'include_rts','true',...
%     'max_id',int64(1019757603570806784),'include_entities','true',...
%     'count',200,'page',double(i));
% end
% save('twtarchive.mat','T')

% Load previous tweets
load('~/Desktop/twitter/data/twtarchive2019.mat')

% Concatenate all tweets into 1 cell array
% t = horzcat(T{1,:});

% Get the most recent tweet id
new_id = t{1,1}.id;

% Retrieve newest tweets since 'new_id'
S = tw.userTimeline('screen_name','realDonaldTrump',...
'since_id',int64(new_id),'include_rts','true',...
'include_entities','true','count',200);

% Concatenate new and old
t = horzcat(S,t);

% Make sure there are no duplicate tweets
[t] = rem_dup_twt(t);

% Save the new archive
save('~/Desktop/twitter/data/twtarchive2019.mat','t');

% Call summary function to get tweet statistics
tweetingSummary(tw,t);

% Call function to print tweet list
twt_doy(t);

% Tweet statistics
doy           = floor(dayofyear);         % Current day of year
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

% c = strsplit(char(datetime));

fprintf('Date            : %s\n',c{1})
fprintf('Time            : %s\n',c{2})
fprintf('Total tweets    : %d\n',tw.data.tweetscnt)
fprintf('Original tweets : %d\n',tw.data.originalcnt)
fprintf('Tweets per day  : %4.3f\n',tw.data.tperd)
fprintf('Projected count : %7.2f\n',tw.data.tproj)

% Write output 
filename = fullfile('~/Desktop/twitter/out','trumptweets2019.txt');
fid2 = fopen(filename,'a');
fprintf(fid2,'%10s %9s %5d %6d %10.3f %11.2f\n',c{1},c{2},...
    tw.data.tweetscnt,tw.data.originalcnt,tw.data.tperd,tw.data.tproj);
fclose(fid2);
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
