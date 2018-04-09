%d = importdata('~/tfMRI_output/test1_0329/test1_0329_Scanner_ABCD_AB_FaceMatching_2018_Mar_29_0836.log');
d = importdata('~/tfMRI_output/test0405_ST/test0405_ST_Scanner_ABCD_AB_FaceMatching_2018_Apr_05_1650.log');

%%
trigger_str = 'Keypress: 5';
start_str = 'Keypress: q';
trial = 'New trial';
nentries = size(d,1);
trial_startA = [];
trial_startB = [];
LOOKFORTRIGA = 1;
LOOKFORTRIGB = 1;
for e=1:nentries
    thisrow = d{e};
    if LOOKFORTRIGA
        if ~isempty(strfind(thisrow, trigger_str)) % first trigger
            split_row = strsplit(thisrow, ' ');
            trig_timeA = str2num(split_row{1});
            LOOKFORTRIGA = 0;
        end
    end
    if ~isempty(strfind(thisrow, start_str)) && ~LOOKFORTRIGA
        frontind = 0;
        while LOOKFORTRIGB
            frontind = frontind + 1;
            frontrow = d{e+frontind};
            if ~isempty(strfind(frontrow,trigger_str))
                split_row = strsplit(frontrow, ' ');
                trig_timeB = str2num(split_row{1});
                LOOKFORTRIGB = 0;
            end
        end
    end
    % now get every trial start
    if ~isempty(strfind(thisrow, trial))
        split_row = strsplit(thisrow, ' ');
        AB = split_row{8};
        if ~isempty(strfind(AB,'A')) % then in the A run
            trial_startA(end+1) = str2num(split_row{1});
        elseif ~isempty(strfind(AB,'B'))
            trial_startB(end+1) = str2num(split_row{1});
        end
    end
    %             % now get that trigger
    %             frontind = 0;
    %             while LOOKFORTRIGB
    %                 backind = backind + 1;
    %                 backrow = d{e-backind};
    %                 if ~isempty(strfind(backrow, 'Keypress: q'))
    %                     %split_row = strsplit(backrow, ' ');
    %                     %trig_timeB = str2num(split_row{1});
    %                     LOOKFORTRIGB = 0;
    %                 end
    %                 trigrow = d{e-backind + 1};
    %                 split_row = strsplit(trigrow, ' ');
    %                 trig_timeB = str2num(split_row{1});
    %             end
    %         end
end
%% now convert to TR numbers
convertTR(trig_timeA,trial_startA,2)
convertTR(trig_timeB,trial_startB,2)