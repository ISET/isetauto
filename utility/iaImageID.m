function imageID = iaImageID(datastring)
% Create a unique ID based on the current time
%
% Synopsis
%
% Brief Description
%   If datastring is not defined, generate the current time
%   Otherwise convert the datastring to a numeric value.
%
% See also
%

if notDefined('datastring')
    % Generate based on the current time
    datastring  = datestr(now,30);
    datastring  = erase(datastring,'T');

    % if the number of digits is larger than 9, the matlab rounds the number
    % cocoapi allow only number as image id, not a string.
    imageID  = str2double(datastring(5:end));
else 
    imageID  = str2double(datastring);
end


end