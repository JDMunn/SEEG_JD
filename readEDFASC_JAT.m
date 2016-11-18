function [dataOut] = readEDFASC_JAT(edf_Name)
% result=readEDFASC(fname, readPos, automatic)
% Read an EDF file or an ASC file.
% 1) If filename ends with '.edf' (case sensitive), run edf2asc - this needs to
%    be on the path!
% 2) Open resulting '.asc' file (or the specified '.asc' file) and read the
%    data. If readPos is 1, then store all the eye location points in an
%    array called 'pos'.
% 3) Saccade events translated into [startTime endTime duration startX startY endX
%    endY ? ?]
% 4) Fixation events translated into [startTime endTime duration avX avY ?]
% 5) MSG events recorded: first word (message name) becomes a fieldname in the
%    structure, appended with _m (a string containing the message) or _t
%    (the time of the message).

% fstem = fname(1:end-4);


asc_Name = [edf_Name(1:end-4) '.asc'];

if ~exist(asc_Name,'file')
    [~,~]=dos(['edf2asc ' edf_Name], '-echo');
    rehash path
end

[fid, ~] = fopen(asc_Name, 'r');

tLine = fgetl(fid);
allLines = {};
dataOut = struct;
lCount = 1;
fiLine = 1;
eyeMSG = 1;
eyeLine = 1;

% ADD SAMPLES

while ischar(tLine)
%     disp(tLine)
    allLines{lCount} = tLine; %#ok<AGROW>
    
    if isempty(tLine) || length(tLine) < 5
        tLine = fgetl(fid);
        continue
    elseif strcmp(tLine(1:2),'**') && length(tLine) > 5;
        dataOut.FileInfo{fiLine,1} = tLine;
        fiLine = fiLine + 1;
    elseif strcmp(tLine(1:3),'MSG')  
        dataOut.EyeInfo{eyeMSG,1} = tLine;
        eyeMSG = eyeMSG + 1;
    elseif strcmp(tLine(1:5),'START')
        dataOut.StartTime = tLine;
    elseif ~isempty(regexp(tLine(1:7),'^[0-9]{7}$','ONCE')) || ~isempty(regexp(tLine(1:6),'^[0-9]{6}$','ONCE')) % Exactly 7 digits of any order
        dataOut.SampleS{eyeLine,1} = tLine;
        eyeLine = eyeLine + 1;
    elseif strcmp(tLine(1:3), 'END');
        dataOut.EndTime = tLine;
    elseif strcmp(tLine(1:7),'SAMPLES')
        dataOut.SampInfo = tLine;
    end
    tLine = fgetl(fid);
    lCount = lCount + 1;
end

fclose(fid);


% Parse info

for di = 1:length(dataOut.FileInfo);
    
    tItem = dataOut.FileInfo{di};
    
    if strfind(tItem,'CONVERTED')
        continue
    elseif strfind(tItem,'DATE')
        tdate = strsplit(tItem);
        
        monthNum = parser(tdate{4},'month');
        
        if length(monthNum) == 1;
            monthNum2use = ['0',num2str(monthNum)];
        else
            monthNum2use = num2str(monthNum);
        end
        
        RecDate = [monthNum2use,tdate{5},tdate{7}];
        
    else
        continue
    end
    
end

dataOut = rmfield(dataOut,'FileInfo');
dataOut.FileInfo.RecordDate = RecDate;

ts = 1;
for mi = 1:length(dataOut.EyeInfo);
    
    mItem = dataOut.EyeInfo{mi};
    if strfind(mItem,'MSG')
        tdate = strsplit(mItem);

        findMSG = any(ismember(tdate,{'BEGINEXPERIMENT','TRIALSTART'}));
        
        if findMSG
            if ismember('BEGINEXPERIMENT',tdate);
                
               if isempty(regexp(tdate(2),'^[0-9]{7}$','ONCE'))
                   TimeStamps.BeginExp = cellstr(regexp(tdate{2},'[0-9]{7}','match'));
               else
                   TimeStamps.BeginExp = cellstr(regexp(tdate{2},'[0-9]{6}','match'));
               end
                
            elseif ismember('TRIALSTART',tdate);
                
                if isempty(regexp(tdate(2),'^[0-9]{7}$','ONCE'))
                    
                    TimeStamps.TrialStart{ts,1} = cellstr(regexp(tdate{2},'[0-9]{7}','match'));
                    ts = ts + 1;
                    
                else
                    TimeStamps.TrialStart{ts,1} = char(cellstr(regexp(tdate{2},'[0-9]{6}','match')));
                    ts = ts + 1;
                    
                end
            end
        else
            continue
        end
    end
        
end

dataOut = rmfield(dataOut,'EyeInfo');
dataOut.FileInfo.TimeStamps = TimeStamps;

% Start exp time
startParts = strsplit(dataOut.StartTime);
dataOut.FileInfo.TimeStamps.ExpStart = startParts{2};
dataOut = rmfield(dataOut,'StartTime');
% End exp time
endParts = strsplit(dataOut.EndTime);
dataOut.FileInfo.TimeStamps.ExpEnd = endParts{2};
dataOut = rmfield(dataOut,'EndTime');

% Sample frequency
sampParts = strsplit(dataOut.SampInfo);
sampHz = str2double(sampParts{6});

dataOut = rmfield(dataOut,'SampInfo');
dataOut.SampRate = sampHz;


sampIDlabs = {'SampleTime','LeftX','LeftY','LeftPupilSize','RightX','RightY','RightPupilSize'};

TrialSamples = zeros(length(dataOut.SampleS),7);
for ssi = 1:length(dataOut.SampleS);
    
    tss = dataOut.SampleS{ssi};
    
    sampParts = strsplit(tss);
    
    convertParts  = cell2mat(cellfun(@(x) str2double(deblank(x)),...
                             sampParts, 'UniformOutput',false));
    
    TrialSamples(ssi,:) = convertParts(1,1:7);
    
    
end

eyeDatTable = array2table(TrialSamples,'VariableNames',sampIDlabs);

dataOut = rmfield(dataOut,'SampleS');
dataOut.tSamples = eyeDatTable;


% fileSaveName = [patientID,'_',dataOut.FileInfo.RecordDate,'_EyeData.mat'];
% 
% save(fileSaveName,'dataOut');


end







function selOut = parser(input, category)


switch category
    
    case 'month'
        probMon = zeros(1,12);
        tMon = upper(input);
        allMons = {'January','February','March','April','May','June','July',...
                   'August','September','October','November','December'};
        for im = 1:12
            
            monVec = ismember(upper(allMons{im}(1:3)),tMon);
            probMon(im) = sum(monVec)/length(monVec);
            
        end
        
        [~, selOut] = max(probMon);
 
end







end
        
        


























