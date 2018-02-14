function figure_keypress(src, event)
% Callback to parse keypress event data to print a figure

switch lower(event.Character)
    case 'x'
        disp('exit command detected...');
    case 'd'
        disp('switching...');
    case 32 % space
        % disp('space!');
end

set(gcf, 'UserData', event.Character);

end