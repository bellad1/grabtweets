% DOY_STATS  function to determine the tweets per day, and 
%            print sorted or not

function twt_doy(t)

    %= Remove all the retweets
    for ii=1:length(t)
        if isfield(t{ii},'entities')
            if ~isfield(t{ii},'retweeted_status')
                orig{ii} = t{ii};
            else
                rtwt{ii} = t{ii};
            end
        end
    end

    %= Remove empty cells
    t    = orig(~cellfun('isempty',orig));
    rtwt = rtwt(~cellfun('isempty',rtwt));
    
    %= Determine the day of year for each tweet
    res = zeros(numel(t),1);                % Allocate
    for i = 1:numel(t)
        date = strsplit(t{i}.created_at);   % Split date/time of tweet
        d    = strcat(char(date{2}),'.',char(date{3}),'.',char(date{6}));
        DV   = datevec(d,'mm.dd.yyyy');
        DV   = DV(:, 1:3);                  % [N x 3] array, no time
        DV2  = DV;
        DV2(:, 2:3) = 0;                    % [N x 3], day before 01.Jan
        DOY  = cat(2, DV(:, 1), datenum(DV) - datenum(DV2));
        DOYt{i} = cat(2, DV(:, 1), datenum(DV) - datenum(DV2));
        res(i) = DOY(2);                    % Day of year
    end
    
    %= Find begin/end date
    df = DOYt{1};
    df = df(2);
    d0 = DOYt{end};
    d0 = d0(2);
    
    %= Compile list to turn to datetime
    dlist  = linspace(1,df,df)';
    yrlist = linspace(2019,2019,df)';
    mlist  = linspace(1,1,df)';
    days   = horzcat(yrlist,mlist,dlist);
    vv     = datetime(days(1:end,:));
   
    [ures,idx] = unique(res);         % Uniqe doy
    tot  = zeros(numel(dlist),1);     % Pre-allocate
    for j = 1:numel(dlist)
        tot(j) = sum(res(:) == dlist(j));   % Calc num twts/doy
    end
    
    %= Get index of sorted totals (descending order)
    [~,sidx]  = sort(tot,'descend');
        
    outdir = ('~/Desktop/twitter/out/');
    
    %= Print num tweets by day (not sorted)
    fid3 = fopen(fullfile(outdir,'doy_tot19.txt'),'w');
    fprintf(fid3,'%11s %4s %10s\n','Date','DOY','NumTwts');
        
    %= Print num tweets by day (sorted)
    fid4 = fopen(fullfile(outdir,'doy_totSort19.txt'),'w');
    fprintf(fid4,'%11s %4s %10s\n','Date','DOY','NumTwts');
    
    %= Flip for printing in reverse order (today to 1/1)
    ww    = flipud(vv);
    wtot  = flipud(tot);
    dlst2 = flipud(dlist);
    
    for k = 1:numel(tot)
        ugh = sidx(k);
        fprintf(fid3,'%11s %4d %10d\n',char(ww(k)),dlst2(k),wtot(k));
        fprintf(fid4,'%11s %4d %10d\n',char(vv(ugh)),dlist(ugh),tot(ugh));
    end

    %= Close all files
    fclose(fid3);
    fclose(fid4);
    
    figdir = ('~/Desktop/twitter/out/figs/');
    
    %= Histogram
    figure(1)
    h = histogram(tot);
    xlim([-1 (max(tot)+1)])
    grid on
    xlabel('Tweets per day')
    ylabel('Count (days)')
    tstring1 = {sprintf('Histogram of @realDonaldTrump tweets/day');...
                        sprintf('(%11s to %11s)',char(vv(1)),char(vv(end)))};
    th1 = title(sprintf('Histogram of @realDonaldTrump tweets/day (%11s to %11s)',...
        char(vv(1)),char(vv(end))));
    titlePos1 = get( th1 , 'position');
    set(th1,'position',titlePos1 + [0 0.4 0]);
    saveas(h,fullfile(figdir,'twthist19.png'))
    
    %= Bar graph
    figure(2)
%     xtic = (1:30:df);
    xtic = [1,32,61,92,122,153,183,214,df];
    b = bar(tot);
    ylim([0 (max(tot)+2)])
    xlim([1 (df+1)])
    ax = gca;
    
    %ax.XTick = xtic;
    %ax.XTickLabels = char(vv(xtic));
    ax.XTickLabelRotation = 45;
    ax.TickLength = [0.01 0.025];
    ax.TickDir = 'both';
    datetick('x','dd-mmm','keepticks')
    grid on
    xlabel('Day of Year')
    ylabel('Tweets per day')
    tstring2 = {'@realDonaldTrump tweets/day';sprintf('(11%s to 11%s)',...
                 char(vv(1)),char(vv(end)))};
    th2 = title(sprintf('@realDonaldTrump tweets/day (%11s to %11s)',...
        char(vv(1)),char(vv(end))));
    titlePos2 = get( th2 , 'position');
    set(th2,'position',titlePos2 + [0 0.4 0]);
    saveas(b,fullfile(figdir,'twtbar19.png'));
end  
