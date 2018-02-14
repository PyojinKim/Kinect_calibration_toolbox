function [ newdata ] = remap_disparity( data, curval )
cls = class(data);

switch cls
    case 'uint16'
        % map from set {0,1,...,2047} to set {0,1,...,maxval}
        % maxval = 2^n - 1
        n = log2(curval+1);
        newdata = bitshift(data,16-n);
    otherwise
        newdata = data; % do nothing
end

end

