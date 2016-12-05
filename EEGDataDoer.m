function [] = EEGDataDoer(usrInput, data)

switch usrInput
    case 'Magnitude-squared Coherence'
        MagSqCohere(data,1,2)
    case 'graphEEG'
        graphEEG(data)
    case 'heatPlot'
        heatPlot(data)
    case 'xCorr'
        xCorrSelAnalysis(data,1,2)
    case 'xCorrConsAll'
        xCorrAnalysis(data)
end

end

function [] = MagSqCohere(data, elec1, elec2)

% s1 = data(elec1, 1:size(data,2));
% s2 = data(elec2, 1:size(data,2));

datam = movmean(data, size(data,2)*.01, 2);

mscohere(double(datam(elec1,:)),double(datam(elec2,:)),hanning(250),100,250,500);

end

function [] = xCorrAnalysis(data)
% goes through the data and cross analyzes the data in consecutive order
numPlot = size(data,1);
analys = zeros(numPlot/2);

p = 0;
for x = 1:2:numPlot
    p = p + 1;
    analys(p) = xcorr(data(x,1:size(data,2)), data(x+1,1:size(data,2)));

end

end

function [] = xCorrSelAnalysis(data, elec1, elec2)
% cross analyzes the designated electrode signal data
s1 = data(elec1, 1:size(data,2));
s2 = data(elec2, 1:size(data,2));

scorrData = xcorr(s1,s2);

end

function [] = graphEEG(data)
%This function plots the inputted data's moving average in one graph

datam = movmean(data, size(data,2)*.01, 2);

xaxis = linspace(0,size(datam,2)/500,size(datam,2));

plot(xaxis,transpose(datam));

legend(eegSession.channelID(1:2));
title('Raw SEEG Traces');
xlabel('time (s)');
ylabel('uV');

end


function [] = heatPlot(data)
%This function creates a heat plot with a colorbar according to the data parameter 

datam = movmean(data, size(data,2)*.01, 2);

imagesc(datam);
colorbar;

title('Raw SEEG Traces');
xlabel('Sample Number');
ylabel('Electrodes');
set(gca,'ytick',[1 2]);
set(gca,'yticklabel',{'LHip1-LHip2','LHip3-LHip4'});

end