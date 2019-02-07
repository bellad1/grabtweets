% GETTWEETS Retrieves tweet counts from @realDonaldTrump and provides
%           options to post to twitter or just display results
%
%
function gettweets

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
load('~/Desktop/twitter/data/twtarchive2019.mat')

% Get the most recent tweet id
new_id = t{1,1}.id;

% Retrieve newest tweets since 'new_id'
S = tw.userTimeline('screen_name','realDonaldTrump',...
'since_id',int64(new_id),'include_rts','true',...
'include_entities','true','count',200);

t = horzcat(S,t);                                  % Concatenate new/old 

% Ensure there are no duplicate tweets
[t] = rem_dup_twt(t);

save('~/Desktop/twitter/data/twtarchive2019.mat','t'); % Save the new archive
tweetingSummary(tw,t);  % Call summary function to get tweet statistics
twt_doy(t);             % Call function to print tweet list

% Tweet statistics
doy           = floor(dayofyear);                  % Current day of year
tw.data.tperd = tw.data.originalcnt/doy;           % Tweets per day

% Projected number of tweets
if ~isleapyear
    tw.data.tproj = ((365-doy)*tw.data.tperd)+tw.data.originalcnt;
else
    tw.data.tproj = ((366-doy)*tw.data.tperd)+tw.data.originalcnt;
end

msg     = screenmsg(tw);
message = sprintf('%s',msg{:});

% Display the statistics before options to post or not
clc
fprintf('Current tweet summary for @realDonaldTrump:\n');
fprintf('-------------------------------------------\n');
disp(message)

% Menu to reroll or post
choice = local_ASCIImenu('What next?',...
    {'Exit',...                                % 1
     'Select header and hashtag then post',... % 2
     'Post with random header/hashtag'});      % 3

switch choice
%========== Case 1: Exiting ==========%
  case 1
    fprintf('\n');
    fprintf('Thank you, come again!\n');
    fprintf('\n');

%========== Case 2: Select header and hashtag ==========%
  case 2
    % Select from headers
    [header,hashtag] = headerhashtag; 
    header           = vertcat('Custom Header',header); clc
    headerchoice = local_ASCIImenu('Choose a header',header);
    clc
    if headerchoice == 1
      finalheader = enterheader;
      clc
      fprintf('Selected Header: %s\n',char(finalheader));
    else
      finalheader  = header(headerchoice);
      fprintf('Selected Header: %s\n',char(finalheader));
    end

    % Select from hashtags
    hashtag    = vertcat('Custom Hashtag',hashtag);
    hashchoice = local_ASCIImenu('Choose a hashtag',hashtag);
    if hashchoice == 1
      [finalhash] = enterhash;
    else
      finalhash   = hashtag(hashchoice);
    end

    % Create/display the tweet
    status = create_tweet(tw,finalheader,finalhash);
    disp_tweet(tw,finalheader,finalhash);

    while true
      prompt = 'Satisfied with this tweet? y/n:   ';
      str = input(prompt,'s');
      if strcmp(str,'y')
        fprintf('\n');
        fprintf('Posting to twitter...\n'); 
        tw.updateStatus(status,'include_entities','true');
        fprintf('Success! Eat it Donny!\n');
        fprintf('\n');
        break
      elseif strcmp(str,'n')
        clc
        headerchoice = local_ASCIImenu('Choose a different header',header);
        if headerchoice == 1
          finalheader = enterheader;
        else
          finalheader  = header(headerchoice);
        end
        clc
        
        hashchoice = local_ASCIImenu('Choose a different hashtag',hashtag);
        if hashchoice == 1
          finalhash = enterhash;
        else
          finalhash = hashtag(hashchoice);
        end
        
        status = create_tweet(tw,finalheader,finalhash);
        clc
        disp_tweet(tw,finalheader,finalhash);
        prompt2 = 'Satisfied now??? y/n:  ';
        str2 = input(prompt2,'s');
        if strcmp(str2,'y')
          fprintf('\n');
          fprintf('Posting to twitter...\n');
          tw.updateStatus(status,'include_entities','true');
          fprintf('Success! Eat it Donny!\n');
          fprintf('\n');
          break
        elseif strcmp(str2,'n')
          fprintf('\n');
          fprintf('Try again later or something then...\n');
          break
        end
      end
    end
%========== Case 3: Select a random hashtag and header ==========%
  case 3
    % Generate new tweet message for the posting option
    [newmsg] = updatestatus(tw);

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
                tw.updateStatus(twmsg,'include_entities','true');
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
end

function [finalheader] = enterheader
  headprompt  = 'Enter your header (under ~70 characters)\n';
  finalheader = input(headprompt,'s'); 
  if length(finalheader) >= 70
    fprintf('Header is too long! (%d char)\n',length(finalheader));
    finalheader = input(headprompt,'s');
  end
  
  if strcmp(finalheader(1),'@')
    finalheader = ['.',finalheader];
  end
end

function [finalhash] = enterhash
  hashprompt = 'Enter your hashtag\n';
  finalhash  = input(hashprompt,'s');
  finalhash  = finalhash(~isspace(finalhash)); % Remove any spaces
  % Make sure # is included
  if ~strcmp(finalhash(1),'#')
    finalhash = ['#',finalhash];
  end
end

function [msg] = screenmsg(tw)
  time        = datetime;                     % Get time
  time.Format = 'yyyy-MM-dd_H:mm:ss';         % Set time format
  c           = strsplit(char(time),'_');     % Split to extract desired part

  % Create screen message of tweet statistics
  msg = {sprintf('Date            : %s\n',c{1});...
         sprintf('Time            : %s\n',c{2});...
         sprintf('Total tweets    : %d\n',tw.data.tweetscnt);...
         sprintf('Original tweets : %d\n',tw.data.originalcnt);...
         sprintf('Tweets per day  : %4.3f\n',tw.data.tperd);...
         sprintf('Projected count : %7.2f\n',tw.data.tproj)};
end

function [status] = create_tweet(tw,finalheader,finalhash)
    a = {sprintf('%s\n',char(finalheader));...
         sprintf('Total (2019)         : %d\n',tw.data.tweetscnt);...
         sprintf('Original (no RTs) : %d\n',tw.data.originalcnt);...
         sprintf('Tweets/day          : %4.3f\n',tw.data.tperd);...
         sprintf('Proj. 2019 total    : %7.2f\n',tw.data.tproj);...
         sprintf('%s\n',char(finalhash))};
    status = sprintf('%s',a{:});
    %clc
    %fprintf('Selected Header : %s\n',char(finalheader));
    %fprintf('Selected Hashtag: %s\n',char(finalhash));
    %fprintf('\n');
    %fprintf('Final tweet:\n');
    %fprintf('----------------------------------------\n');
    %disp(status)
end

function disp_tweet(tw,finalheader,finalhash)
    a = {sprintf('%s\n',char(finalheader));...
         sprintf('Total (2019)        : %d\n',tw.data.tweetscnt);...
         sprintf('Original (no RTs)   : %d\n',tw.data.originalcnt);...
         sprintf('Tweets/day          : %4.3f\n',tw.data.tperd);...
         sprintf('Proj. 2019 total    : %7.2f\n',tw.data.tproj);...
         sprintf('%s\n',char(finalhash))};
    status = sprintf('%s',a{:});
    clc
    fprintf('Selected Header : %s\n',char(finalheader));
    fprintf('Selected Hashtag: %s\n',char(finalhash));
    fprintf('\n');
    fprintf('Final tweet:\n');
    fprintf('----------------------------------------\n');
    disp(status)
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

