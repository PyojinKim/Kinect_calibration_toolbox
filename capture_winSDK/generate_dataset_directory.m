function [saveColorDir, saveDepthDir] = generate_dataset_directory(saveDir)

% name the rgb, depth directories
saveColorDir = [saveDir '/rgb'];
saveDepthDir = [saveDir '/depth'];


% check existence of folder
if (~exist(saveColorDir, 'dir'))
    mkdir(saveColorDir);
end
if (~exist(saveDepthDir, 'dir'))
    mkdir(saveDepthDir);
end


end

