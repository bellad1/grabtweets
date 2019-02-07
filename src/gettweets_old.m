% GETTWEETS Retrieves tweet counts from @realDonaldTrump and provides
%           options to post to twitter or just display results
%
%
function [status] = gettweets

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
load('~/Desktop/twitter/data/twtarchive.mat')

% Concatenate all tweets into 1 cell array
% t = horzcat(T{1,:});

% Get the most recent tweet id
new_id = t{1,1}.id;

% Retrieve newest tweets since 'new_id'
S = tw.userTimeline('screen_name','realDonaldTrump',...
'since_id',int64(new_id),'include_rts','true',...
'include_entities','true','count',200);

% Concatenate new and old together
t = horzcat(S,t);

% Save the new archive
save('~/Desktop/twitter/data/twtarchive.mat','t');

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

msg = {sprintf('Date            : %s\n',c{1});...
       sprintf('Time            : %s\n',c{2});...
       sprintf('Total tweets    : %d\n',tw.data.tweetscnt);...
       sprintf('Original tweets : %d\n',tw.data.originalcnt);...
       sprintf('Tweets per day  : %4.3f\n',tw.data.tperd);...
       sprintf('Projected count : %7.2f\n',tw.data.tproj)};
message = sprintf('%s',msg{:});

% Display the statistics before options to post or not
status = message;
clc
fprintf('Current tweet summary for @realDonaldTrump:\n');
fprintf('-------------------------------------------\n');
disp(message)
    
% Menu to reroll or post
choice = local_ASCIImenu( 'What next?', { ...
                          'Exit',                % 1
                          'Post to twitter'} );  % 2

switch choice

  case 1
    fprintf('\n');
    fprintf('Thank you, come again!\n');
    fprintf('\n');

  case 2
    % Generate new tweet message for the posting option
    [newmsg] = updatestatus(tw);
    
    % Find if the hashtag/header has been posted recently
    load('prevmsg.mat');
    while strcmp(newmsg{1,1},prevmsg{1,1}) || strcmp(newmsg{6,1},prevmsg{6,1})
        newmsg = updatestatus(tw);
    end
    
    % Concatenate and display tweet message
    twmsg = sprintf('%s',newmsg{:});
    clc
    fprintf('Post to be tweeted:\n');
    fprintf('----------------------------------------\n');
    disp(twmsg)
    fprintf('\n');
    
    % Use loop and menu to get the desired tweet
    while true 
    	prompt = 'Satisfied with this tweet? y/n:  ';
        str = input(prompt,'s');
        if strcmp(str,'n')
            newmsg = updatestatus(tw);
            twmsg  = sprintf('%s',newmsg{:});
            clc
            fprintf('New tweet:\n');
            fprintf('----------------------------------------\n');
            disp(twmsg)
            fprintf('\n');
        elseif strcmp(str,'y');
            fprintf('\n');
            prompt2 = 'Are you sure you want to post? y/n:  ';
            str2 = input(prompt2,'s');
            if strcmp(str2,'y')
                fprintf('\n');
                fprintf('Posting to twitter...\n');
                status = tw.updateStatus(twmsg,'include_entities','true');
                prevmsg = newmsg;
                save('prevmsg.mat','prevmsg')
                fprintf('Success! Eat it Donny!\n');
                fprintf('\n');
                break
            elseif strcmp(str2,'n')
                fprintf('\n');
                fprintf('Exiting...\n');
                fprintf('\n');
                break
        end
    end
end
end
