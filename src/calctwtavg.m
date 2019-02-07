fid    = fopen('~/Desktop/twitter/out/trumptweets.txt');
header = fgets(fid);
header = strsplit(strtrim(header));
%data   = textscan(fid,repmat('%f',[1,numel(header)]));
data   = textscan(fid,'%s %s %f %f %f %f');
fclose(fid);

% Open the file for printing and write header
%fid = fopen('~/Desktop/twitter/out/trumptweets_avg.txt','w');
%fprintf(fid,'%s %11s %10s %9s %9s %10s\n',header{:});

% Compute the daily averages
date   = data(:,1);
for i = 1:numel(date{1})
  d        = strsplit(char(date{1}(i,1)),'-');
  dayoy(i) = dayofyear(str2double(d(1)),str2double(d(2)),str2double(d(3)));
  avg(i)   = data{4}(i)/dayoy(i);

  % Print the values to the file
%  fprintf(fid,'%10s %9s %5d %6d %10.3f %11.2f\n',char(date{1}(i)),char(data{2}(i)),...
%    data{3}(i),data{4}(i),avg(i),data{6}(i));
end

% Close the file
%fclose(fid);
days = unique(dayoy);
ndays = numel(days);

for j = 1:ndays
  idx = find(dayoy == days(j));
  dat = data{4}(idx);
  tot(j) = max(dat);
end

d = data{4};
for i = 1:numel(data{4})-1
  dif = abs(data{4}(i) - data{4}(i+1));
  if dif>50
    d(i+1) = d(i+1) + dif;
    %fprintf('Error Here? %5d %6.0f %6.0f %6.0f\n',i,data{4}(i),data{4}(i+1),dif);
    fprintf('Error Here? \n')
    fprintf('%5d %6.0f %6.0f\n',i,dif,data{4}(i))
    fprintf('%5d %6.0f %6.0f\n',i+1,dif,data{4}(i+1))
    fprintf('%5d %6.0f %6.0f\n',i+2,dif,data{4}(i+2))
    %6.0f %6.0f\n',i,dif,data{4}(i),data{4}(i+1),data{4}(i+2));
  end
end

