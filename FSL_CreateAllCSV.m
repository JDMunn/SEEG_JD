function [] = FSL_CreateAllCSV()

% Location

mainVolLoc = 'Z:\BRAiN_Project\Freesurfer stat text files\FSL_VolumeCSV';

cd(mainVolLoc)

csvDir = dir('*.csv');
csvDirA = {csvDir.name};

allFslTab = table;
for ci = 1:length(csvDirA)
    
    % tmpTable
    tmpTable = readtable(csvDirA{ci});
    % tmpCname
    nParts = strsplit(csvDirA{ci},{'_','.'});
    tcName = nParts{2};
    tmpTable = tmpTable(tmpTable.LabelId ~= 0,:);
    
    % Label List
    labelNum = transpose([10 11 12 13 16 17 18 26 49 50 51 52 53 54 58]);
    labelID = {'Thalamus';'Caudate';'Putamen';'Pallidum';'Brainstem';...
        'Hippocamp';'Amygdala';'Accumbens';'Thalamus';...
        'Caudate';'Putamen';'Pallidum';'Hippocamp';'Amygdala';'Accumbens'};
    
    hemiID = {'L';'L';'L';'L';'B';'L';'L';'L';'R';...
        'R';'R';'R';'R';'R';'R'};
    
    labelColor = [[210 180 140] ; [102 205 170] ; [0 0 128] ; [0 139 139] ;...
        [106 90 205]  ; [221 160 221] ; [233 150 122] ; [255 235 205] ;...
        [34 139 34] ; [248 248 255] ; [245 255 250] ; [255 160 122] ;...
        [144 238 144] ; [173 255 47] ; [128 0 0]]/255;
    fslColors = cell(size(labelColor,1),1);
    for li = 1:size(labelColor,1)
        fslColors{li,1} = labelColor(li,:);
    end
    
    if isequal(labelNum , tmpTable.LabelId)
        tmpTable.LabelName = labelID;
        tmpTable.HemiN = hemiID;
    else
        for labelI = 1:length(labelNum)
            tLabel = labelNum(labelI);
            lInd = tmpTable.LabelId == tLabel;
            tCell = labelID(lInd);
            tmpTable.LabelName(lInd) = tCell{1,1};
        end
    end
    
    tmpTable.LabColor = fslColors;
    
    tmpTable.Properties.VariableNames([3 4 5 6]) = {'NVoxels' , 'Volume_mm3' , 'IMmean' , 'IMstddev'};
    
    PDcases = {'c202','c204','c205','c212','c213','c215','c216','c218','c223',...
        'c225','c227','c228','c232','c233','c235','c237','c246','c252',...
        'c254','c256','c260','c267','c290','c294','c296'};
    
    ETcases = {'c229','c241','c249','c250','c270','c277','c286','c307','c318'};
    
    if ismember(tcName,PDcases)
        tmpTable.Condition = cellstr(repmat('PD',height(tmpTable),1));
    elseif ismember(tcName,ETcases)
        tmpTable.Condition = cellstr(repmat('ET',height(tmpTable),1));
    end
    
    caseCol = cellstr(repmat(tcName,height(tmpTable),1));
    
    tmpTable.caseID = caseCol;
    
    
    
    
    
    
    allFslTab = [allFslTab ; tmpTable]; %#ok<AGROW>
    
end

cd('Z:\BRAiN_Project\FinalSummaryNIfile');
% Subcortical Cortical
save('AllFSLdata.mat','allFslTab');
writetable(allFslTab,'AllFSLdata.csv')




end
