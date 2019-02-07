function k = local_ASCIImenu( xHeader, xcItems )


%---------------------------------------------------------------------
% Calculate the number of items in the menu
%---------------------------------------------------------------------
numItems = length(xcItems);

%---------------------------------------------------------------------
% Continuous loop to redisplay menu until the user makes a valid choic
%---------------------------------------------------------------------
while 1,
    % Display the header
    disp(' ')
    disp(['----- ',xHeader,' -----'])
    disp(' ')
    % Display items in a numbered list
    for n = 1 : numItems
        disp( [ '      ' int2str(n) ') ' xcItems{n} ] )
    end
    disp(' ')
    % Prompt for user input
    k = input('Select a menu number: ');
    % Check input:
    % 1) make sure k has a value
    if isempty(k), k = -1; end;
    % 2) make sure the value of k is valid
    if  (k < 1) | (k > numItems) ...
        | ~strcmp(class(k),'double') | rem(k,1) ~= 0 ...
        | ~isreal(k) | (isnan(k)) | isinf(k),
        % Failed a key test. Ask question again
        disp(' ')
        disp('Invalid selection. Try again.')
    else
        % Passed all tests, exit loop and return k
        return
    end % if k...
end % while 1
