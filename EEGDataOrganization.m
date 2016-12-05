%testy Summary of this function goes here
% This function organzies a user inputted ASCII file of Nihon Kohdon 1200 Version 1.00
% .EEG data into a structure array complete with the following information about the EEG data:
% timePoints - number of samples taken from the EEG signals
% numChannels - number of waveforms being read
% beginSweep - time(ms) the sweep started
% samplingInterval - frequency(ms/interval) the samples were taken at
% numBinsTouV - number of bins per microvolt
% sessionLength - length in h:m:s EEG data recorded
% electrodeData - a cell array filled with the SEEG data in Hz, each row of
% data correlates directly to each column in channelID
% channelID - a one dimensional array of all channelIDs
% *CONDITIONAL if the file has trigger points* triggerPoints -  the point where the trigger occured during
% the recording
function [] = EEGDataOrganization()
 
mes = inputdlg('Please type the ASCII file would you like to analyze (Nihon Kohdon 1200 Version 1.00 EEG Data)');
file = mes{:}; 

asc_Name = file;

[fid, ~] = fopen(asc_Name, 'r');

sel = inputdlg('How many channels?', '# Channels?', 1, {'1'});
numOutChan = str2double(sel{1});

seshInfo = fgetl(fid);

eegSession = struct; 

%creates cell array 
iArray = strsplit(seshInfo,{'=', ' '});

eegSession.timePoints = iArray{2};
eegSession.numChannels = iArray{4};
eegSession.beginSweep = iArray{6};
eegSession.samplingInterval = iArray{8};
eegSession.numBinsTouV = iArray{10};
eegSession.sessionLength = iArray{12};

seshInfo = fgetl(fid);
seshInfo = strtrim(seshInfo);

eegSession.channelID = strsplit(seshInfo);

numChan = size(eegSession.channelID, 2); %number of channels 

numSamp = str2double(eegSession.timePoints); %number of samples per electrode

%precisely allocated amount of space for the large amounts of data stored
eegSession.data = zeros(numOutChan, numSamp, 'int16');

seshInfo = fgetl(fid); %first line of data

% Iterates through each line of EEG data, stores the data as a 16 bit
% integer and stores the modified data into the eegSession.data struct as a
% row
rCount = 0;

if eegSession.channelID{numChan} == 'Trigger'
    eegSession.triggerPoint = [];
    
    while ischar(seshInfo)
        rCount = rCount + 1;

        rawData = strsplit(strtrim(seshInfo)); %cell array of unmodified EEG data w/ blanks trimmed out
        roundedData =  int16(round(str2double(rawData{1,numChan})*100)); 
        
        if roundedData ~= 0
            eegSession.triggerPoint = [eegSession.triggerPoint;roundedData];
            
        end
        
        rawData = rawData(1,1:numOutChan);
        roundedData =  int16(round(str2double(rawData)*100)); 

        eegSession.data(1:numOutChan,rCount) = roundedData; %line count in data doesn't include the first line of data in the ASCII file

        seshInfo = fgetl(fid);

    end
    
else
    while ischar(seshInfo)
        rCount = rCount + 1;

        rawData = strsplit(strtrim(seshInfo)); %cell array of unmodified EEG data w/ blanks trimmed out
        rawData = rawData(1,1:numOutChan);
        roundedData =  int16(round(str2double(rawData)*100)); 

        eegSession.data(1:numOutChan,rCount) = roundedData; %line count in data doesn't include the first line of data in the ASCII file

        seshInfo = fgetl(fid);

    end
end

fclose(fid);

save 'DesiredChannels.mat', 'eegSession';

end



