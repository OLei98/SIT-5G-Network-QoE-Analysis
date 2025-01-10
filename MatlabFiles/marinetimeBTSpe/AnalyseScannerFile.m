clear all
clc
close all 

%% analyse scanner data
% filename = 'C:\Users\A103764\OneDrive - Singapore Institute Of Technology\Vignesh_OneDrive\QualipocScannerResults\ScannerResult\Example\5G_24.2_test.txt';
filenameScanner = 'C:\Users\MNT\Desktop\OCL_DEMO\GitHub\SIT-5G-Network-QoE-Analysis\ReferenceCode\RS_SIT_PordAreas\scanner_btspe_raw\R&S_SIT_1.txt';
dataScanner = readtable(filenameScanner, 'Delimiter', ';');

%Scanner gNB
gnbScanner = regexp(dataScanner.Name, 'ID:(\d+)', 'tokens', 'once');
gnbScanner = cellfun(@str2double, gnbScanner);
gnbScannerUniq = unique(gnbScanner);

%Scanner PCI
pciScanner = regexp(dataScanner.Name, 'PCI:(\d+)', 'tokens', 'once');
pciScanner = cellfun(@str2double, pciScanner);
pciScannerUniq = unique(pciScanner);

%Scanner PCI, Lat and Long
% Extract corresponding Latitude and Longitude
latitudes = dataScanner.Latitude; % Assuming the column is named 'Latitude'
longitudes = dataScanner.Longitude; % Assuming the column is named 'Longitude'
TableScanner = table(pciScanner, latitudes, longitudes, 'VariableNames', {'PCI', 'Latitude', 'Longitude'});

%% analyse data from smart analytics extract for singtel

% find unique values 
%data_Singtel = readtable('C:\Users\cheny\Desktop\SIT folder\Intern\MNT@SiT\MarineTime_Marina_SouthPier\MarineTime_Singtel.csv', 'VariableNamingRule', 'preserve'); % Load a table from a CSV file
data_Singtel = readtable('C:\Users\MNT\Desktop\OCL_DEMO\GitHub\SIT-5G-Network-QoE-Analysis\ReferenceCode\MarinaSouthPiers\Singtel\MarineTime_Singtel.csv', 'VariableNamingRule', 'preserve'); % Load a table from a CSV file
head(data_Singtel);

pciSingtel = data_Singtel.PCI; 
pciSingtelUniq = unique(pciSingtel);

% finds pci in singtel and in scannerpciScannerUniq
pciFound = intersect(pciSingtelUniq, pciScannerUniq);

% finds pci that are in singtel unique and not in scanner
pciMissing = setdiff(pciSingtelUniq, pciScannerUniq);
percentageOverlap = (length(pciFound) / length(pciScannerUniq)) * 100;


%% analyse data from export2csv extract for m1

% readtable
dataMone1 = readtable('C:\Users\MNT\Desktop\OCL_DEMO\GitHub\SIT-5G-Network-QoE-Analysis\ReferenceCode\MarinaSouthPiers\M1\2024-12-10-10-03-38-0000--007-4384-2898-S.csv', 'VariableNamingRule', 'preserve'); % Load a table from a CSV file
dataMone2 = readtable('C:\Users\MNT\Desktop\OCL_DEMO\GitHub\SIT-5G-Network-QoE-Analysis\ReferenceCode\MarinaSouthPiers\M1\2024-12-10-10-54-18-0000--007-4384-2898-S.csv', 'VariableNamingRule', 'preserve'); % Load a table from a CSV file

% table from qualipoc 
dataMone = [dataMone1; dataMone2];
dataMonePCI = dataMone.PCI

% remove nan
pciMoneClean = dataMonePCI(~isnan(dataMonePCI));

% Unique
pciMoneUniq = unique(pciMoneClean);

% finds gNB in singtel and in scanner
pciMoneFound = intersect(pciMoneUniq, pciScannerUniq);

%% finding M1: gNB using PCI

% Find all the rows that has the PCI
matchRowMone1 = ismember(dataMone1.PCI, pciMoneFound);

% make it unique
gnbMone1 = unique(dataMone1.gNB(matchRowMone1));

% Delete all the null values
gnbMone1Clean = gnbMone1(~isnan(gnbMone1));

gnbFound = intersect(gnbMone1Clean, gnbScannerUniq);

%% Append gnb lat and long to the M1 dataset based on PCI

% Initialize new columns in dataMone
dataMone.gNB_Lat = nan(height(dataMone), 1);
dataMone.gNB_Long = nan(height(dataMone), 1);

% Loop through each row in dataMone to match PCI with TableScanner
for i = 1:height(dataMone)
    % Find the row in TableScanner with matching PCI
    matchIndex = find(TableScanner.PCI == dataMone.PCI(i), 1);
    
    % If a match is found, append Latitude and Longitude
    if ~isempty(matchIndex)
        dataMone.gNB_Lat(i) = TableScanner.Latitude(matchIndex);
        dataMone.gNB_Long(i) = TableScanner.Longitude(matchIndex);
    end
end

%% Define the folder and file name
outputFolder = 'C:\Users\MNT\Desktop\OCL_DEMO\GitHub\SIT-5G-Network-QoE-Analysis\ReferenceCode\MarinaSouthPiers\M1'; % Replace with your desired folder name
outputFileName_csv = 'M1_Combined_updated_append_gNB.csv'; % Replace with your desired file name (.mat or csv)
% outputFileName_mat = 'M1_Combined_updated_append_gNB.mat'; % Replace with your desired file name (.mat or csv)

% Create the folder if it does not exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

writetable(dataMone, fullfile(outputFolder, outputFileName_csv)); % for csv format
% save(fullfile(outputFolder, outputFileName_mat), 'dataMone'); %for mat format