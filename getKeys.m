function key_positions = getKeys(key)
KbName('UnifyKeyNames');
    % initialize key search
    
    keyCodes = zeros(1,256);
    keyNames = KbName('KeyNames');
    key_positions = [];
    
    % address a problem where on Windows PC's some cells are left blank
    keyNames_len = cellfun(@length,keyNames) == 0;
    keyNames(keyNames_len) = {'Undefined'}; 
    
    % search for this key
    for i = 1:length(keyNames)
        this_key = lower(keyNames{i});
        if strcmp(this_key,key)
            key_positions = [key_positions i];
        elseif (length(this_key) == 2) && ~isempty(strfind(this_key,key)) && ~strcmp(this_key(1),'f')
            key_positions = [key_positions i];
        end
    end
end