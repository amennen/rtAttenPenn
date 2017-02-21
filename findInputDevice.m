% syntax: [device_id, found_inputs] =
%               FINDINPUTDEVICE(input, [device_type], [strict_matching])
%
% This function takes a deviceID, full or partial device name, full serial
% number, or full productID, and searches for a matching device based 
% on the inputs available at runtime. Multiple input devices can be
% specified in a cell array, with preferred devices listed first. This can
% be useful for code designed to run on multiple machines, or laptops where
% external devices may or may not be present.
%
% Loose matching when specifying when specifying a full or partial device
% name requires preliminary info about the device gathered through a call
% to FINDINPUTDEVICE with no parameters.
%
% An optional string or cell array can be provided to limit matching to a
% particular type or set of device types (any of 'keyboard', 'mouse',
% 'keypad', 'gamepad', 'audio', or 'unknown'). Order preference is taken 
% into account for this list as well. Note: device matching in ths way is 
% not guaranteed to produce the correct device of its class.
%
% An optional boolean can be provided for strict matching (case sensitive,
% exact match) rather than loose matching (case insensitive, partial
% match; default case).
%
% If no matches are found, an error is returned. If multiple
% matches are found (due to an ambiguous input name), a best guess at the 
% desired device among the matches will be selected. This guess involves
% preference for devices of the correct category, for devices matching
% encouraging strings, and for attached over internal devices (because it's
% probably attached for a reason). It includes preference against devices
% that match known pitfalls (e.g., "virtual" keyboard on unix). If empty
% input is specified, the default (-1) is returned.
% 
% To produce a list of all currently available inputs, call the function
% without any arguments, i.e., FINDINPUTDEVICE() .
%
% Outputs consists of the validated deviceID, and a table containing 
% detailed information about all matching inputs.
%
%
% EXAMPLE USAGES:
%
% FINDINPUTDEVICE(): print a table of all available input devices.
% [~, available] = FINDINPUTDEVICE(): catch this table.
% [id, available] = FINDINPUTDEVICE([],'mouse'): get a table of all mice, 
%                   returing the first mouse found as an id.
% id = FINDINPUTDEVICE(2): check that 2 corresponds to an available device.
% id = FINDINPUTDEVICE(2,'keyboard'): check that 2 corresponds to an available
%                   keyboard.
% id = FINDINPUTDEVICE('internal','keyboard'): get the device ID of a 
%                   laptop's internal keyboard using partial name matching 
%                   and a little optimism.
% id = FINDINPUTDEVICE('Apple Internal Keyboard Trackpad','keyboard',true):
%                   strict matching to my laptop's internal keyboard.
% id = FINDINPUTDEVICE({'fmri','internal'}): match either an fMRI input or 
%                   internal keyboard, giving priority to the fMRI input, 
%                   so that we choose the scanner's input when it is 
%                   available.
% 
%
% Written by J. Poppenk on May 9, 2015 @ Queen's University

function [input_device_id, all_inputs] = findInputDevice(input, device_type, strict_matching)

    %% initialize
    
    % some of these commands are really noisy, so we'll suppress warnings
    % by default
    Screen('Preference', 'SuppressAllWarnings', 1);
    
    % check to see if no inputs provided (output table)
    if ~exist('input','var') && ~exist('device_type','var') && ~exist('strict_matching','var')
        list_mode = true;
    else list_mode = false;
    end
    
    % prepare input variable
    silent_probe = false;
    if exist('input','var') && ~isempty(input)
        if ~iscell(input),
            hold_this = input; clear input; input{1} = hold_this;
        end
        for i = 1:length(input)
            if i == 1, input_str = num2str(input{i});
            else input_str = [input_str ' or ' num2str(input{i})];
            end
        end

    else
        input = []; input_str = [];
        if ~exist('device_type','var') || isempty(device_type)
            silent_probe = true;
        end
    end
    
    % check for case sensitive matching
    if ~exist('strict_matching','var'), strict_matching = false;
    else trueDat(strict_matching);
    end
    if strict_matching,
        compare_handle = @strcmp;
        strict_string = 'strict matching';
    else
        compare_handle = @strcmpi;
        strict_string = 'loose matching';
    end
    
    % check for specific input types
    valid = {'keyboard','mouse','keypad','gamepad','audio','unknown'};
    dev_str = [];
    if exist('device_type','var') && ~isempty(device_type)
        if ~iscell(device_type),
            hold_this = device_type; clear device_type; device_type{1} = hold_this;
        end
        for i = 1:length(device_type)
            if ~ischar(device_type{i}) || ~any(strcmpi(valid,device_type{i}))
                error(['if specified, device_type must be one or more of ''keyboard'', ' ...
                '''mouse'',''keypad'', or ''gamepad''.']);
            end
            if i == 1, dev_str = [' among ' device_type{i}];
            else dev_str = [dev_str ' + ' device_type{i}];
            end
        end
    else device_type = [];
    end

    % initialize variables
    index = [];
    name = cell(0);
    found_type = cell(0);
    info = cell(0);
    input_device_id = -1;
    device_list = [];
    omni_device = false;
    guess_found = false;
    
    % call InitializePsychSound to avoid potential errors on MS-Windows
    if ispc, InitializePsychSound; end

    
    %% compile a list of all available inputs

    % identify all inputs. we'll bypass the Get* functions so that we can
    % search everything at once.
    if ~IsOSX
        % explicitly select all device classes for Linux/Windows
        LoadPsychHID;
        found = [ PsychHID('Devices',1), PsychHID('Devices',2), PsychHID('Devices',3), ...
            PsychHID('Devices',4), PsychHID('Devices',5) ];
    else
        found = PsychHID('Devices');
    end
    for d = 1:length(found)
        if found(d).usagePageValue==1 && found(d).usageValue == 6
            type = 'keyboard';
        elseif found(d).usagePageValue==1 && found(d).usageValue == 2
            type = 'mouse';
        elseif found(d).usagePageValue==1 && found(d).usageValue == 7
            type = 'keypad';
        elseif IsLinux || (found(d).usagePageValue==1 && (found(d).usageValue == 5 || found(d).usageValue == 4))
            type = 'gamepad';
        else type = 'unknown';
        end
        if isempty(device_type) || any(strcmpi(device_type,type))
            index(end+1) = found(d).index;
            name{end+1} = found(d).product;
            found_type{end+1} = type;
            info{end+1} = found(d);
        end
    end
    
    % identify all audio input devices
    if isempty(device_type) || any(strcmpi(device_type,'audio'))
        found_audio = PsychPortAudio('GetDevices');
        PsychPortAudio('Close'); % return audio device drivers to original state
        for d = 1:length(found_audio)
            index(end+1) = found_audio(d).DeviceIndex;
            name{end+1} = found_audio(d).DeviceName;
            found_type{end+1} = 'audio';
            info{end+1} = found_audio(d);
            % add serialNumber and productID fields to the struct
            info{end}.serialNumber = '';
            info{end}.productID = NaN;
        end
    end
    
    % build table with information on all input devices
    all_inputs = table(index', name', found_type', info', 'VariableNames', ...
        {'id', 'name', 'type', 'info'});

    % extract table rows in an order based on device type preferences
    if ~isempty(device_type)
        device_inputs = table;
        for type = 1:length(device_type)
            device_inputs = [device_inputs; all_inputs(strcmp(found_type, device_type{type}),:)];
        end
        all_inputs = device_inputs;
    end
    
    % report
    if list_mode
        disp(all_inputs); return
    elseif silent_probe, return
    end
    

    
    %% attempt to locate each specified input device within those available
    
    % loop over inputs 
    device_pos = [];
    for i = 1:length(input)

        % "bad" input
        if isempty(input{i}) || any(isnan(input{i})) || any(isinf(input{i})) || any(input{i} == -1)
            device_pos = [];
            if any(input{i} == -1)
                omni_device = true;
            end

        % numeric device specification: check that input exists
        elseif isnumeric(input{i}) && isscalar(input{i}) && input{i} >= -1 && input{i} < 1000
            device_pos = find(all_inputs.id == input{i});

        % location id specification
        elseif isnumeric(input{i}) && isscalar(input{i}) && input{i} >= 1001
            for candidate = 1:length(all_inputs.id);
                if input{i} == all_inputs.info{candidate}.productID, 
                    device_pos = candidate;
                end
            end

        elseif ischar(input{i})
            device_pos = [];
            % assume strings are serial no's at first (more specific)
            for candidate = 1:length(all_inputs.id)
                if compare_handle(all_inputs.info{candidate}.serialNumber, input{i}); % assumes 1-of-a-kind
                    device_pos = candidate;
                end
            end

            % and if that doesn't work, check if there are any matching device names
            if isempty(device_pos)
                if strict_matching, device_pos = find(compare_handle(all_inputs.name, input{i}));
                else device_pos = find(cellfun(@length,strfind(lower(all_inputs.name), lower(input{i}))));
                end
            end
        end % type statement
        
        % capture result
        device_list = [device_list device_pos'];
    end % multiple inputs
    
    %% handle multiple device matches
    
    % in this section we'll be doing some guessing. we can start by
    % defining what is bad:
    known_bad = {'virtual', 'out', 'power', 'webcam', 'video', 'bus'};

    % in this section, we have already matched some devices based on their
    % name or other features, but there is more than one of them.
    found_list = device_list;
    if length(device_list)>1

        % odds are better we'll succeed if we guess against certain devices
        bad = zeros(size(all_inputs.type(device_list)));
        for i = 1:length(known_bad)
            bad = bad + ~cellfun(@isempty,strfind(lower(all_inputs.name(device_list)),known_bad{i})); 
        end
        
%         % only filter out unknown devices if there is a good one remaining
%         if sum(bad) < length(device_list)
%             device_list = device_list(~bad);
%         end
%             
        % prefer attached devices to internal ones
        usb = zeros(length(device_list),1);
        for i = 1:length(device_list)
            this_device = all_inputs.info{device_list(i)};
            if isfield(this_device,'transport')
                usb(i) = strcmpi(this_device.transport,'usb');
            end
        end
        usb = usb | ~cellfun(@isempty, strfind(lower(all_inputs.name(device_list)),'usb'));
        
        % search for guess, and use the result that satisfies our criteria,
        % preferring "not bad", then "candidate" then "usb"
        result = (~bad*2) + (usb*.5);
        [~, good] = max(result);
        if ~isempty(good), guess_found = true; end
        device_list = device_list(good);
        
        % issue warning
        disp(['SPTB-INFO: The specified input, "' input_str '", matched multiple devices. ' ...
                'Using an educated guess for device of known type, giving preference to ' ...
                'external devices. If this does not work, find your target deviceID ' ...
                'manually using findInputDevice().'])
    end
    
    % in this section, we weren't supplied with a device name, and we will
    % do our best to return a good device based on the available info on
    % devices from that category.
    if ~isempty(device_type) && length(all_inputs.id) > 0

        % some reasonable guesses as a function of category
        switch device_type{1}
            case 'keyboard', target = {'keyb'};
            case 'mouse', target = {'mou', 'touch'};
            case 'audio', target = {'mic'};
            case 'gamepad', target = {'joy'};
        end
        
        % search for these reasonable matches among our devices
        candidate = zeros(size(all_inputs.name));
        for i = 1:length(target)
            candidate = candidate + ~cellfun(@isempty,strfind(lower(all_inputs.name),target{i}));
        end

        % odds are better we'll succeed if we guess against certain devices
        bad = zeros(size(all_inputs.type));
        for i = 1:length(known_bad)
            bad = bad + ~cellfun(@isempty,strfind(lower(all_inputs.name),known_bad{i})); 
        end
        
        % only filter out bad devices if there is at least one remaining
        if sum(bad) == length(all_inputs.name), bad = bad*0; end
            
        % prefer attached devices to internal ones
        usb = zeros(length(all_inputs.name),1);
        for i = 1:length(all_inputs.name)
            if isfield(all_inputs.info{i},'transport')
                usb(i,1) = strcmpi(all_inputs.info{i}.transport,'usb');
            end
        end
        % transport info isn't always available, so add devices with 'usb' in their name
        usb = usb | ~cellfun(@isempty, strfind(lower(all_inputs.name),'usb'));
        
        % search for guess, and use the result that satisfies our criteria,
        % preferring "not bad", then "candidate" then "usb"
        result = (~bad*2) + (candidate*1) + (usb*.5);
        [~, good] = max(result);
        if ~isempty(good), guess_found = true; end
    end

    
    %% bless or reject the result
        
    % deal with generic -1 deviceID's
    if omni_device
        input_device_id = -1;
        disp('SPTB-INFO: General deviceID of -1 provided: no device search performed, same deviceID returned.');
        return

    % this looks like a normal list
    elseif ~isempty(device_list),
        input_device_id = all_inputs.id(device_list(1));
        
    % complain about device category-level guess
    elseif isempty(input) && ~isempty(device_type) && guess_found
        input_device_id = all_inputs.id(good);
        disp(['SPTB-INFO: Input type specified only; using an educated guess for device found' dev_str ...
            ' devices, ' all_inputs.name{good} '. If this does not work, find your ' ...
            'target deviceID manually in the second output argument, or using findInputDevice().']);
        
    % deal with non-matched devices
    elseif ~isempty(input_str)
        err_str = ['The specified input, "' input_str '", could not be ' ...
            'found using ' strict_string];
        if ~isempty(device_type)
            err_str = [err_str dev_str ' devices.'];
        else err_str = [err_str '.'];
        end
        error(err_str);
    end
    
    % filter result table
    if ~isempty(found_list)
        all_inputs = all_inputs(found_list,:);
    end
    
    % restore suppressed PTB warnings
    Screen('Preference', 'SuppressAllWarnings', 0);
    
return