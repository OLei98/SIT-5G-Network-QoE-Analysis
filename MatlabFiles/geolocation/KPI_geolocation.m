% Main Script

% data = readtable('extracted_data_HONDA_SIT.csv', 'VariableNamingRule', 'preserve'); % Load a table from a CSV file
filePath = 'C:\Users\MNT\Desktop\OCL_DEMO\GitHub\SIT-5G-Network-QoE-Analysis\ReferenceCode\Hondo_SIT\processed\extracted_data_HONDA_SIT.csv'; % Full path to the CSV file
data = readtable(filePath, 'VariableNamingRule', 'preserve'); % Load the table from the CSV file


latId = 'Lat';       % Column name or index for Latitude
lonId = 'Long';      % Column name or index for Longitude

pId = 'Network Thrpt UL';
tstr = ''; % Title string
clim = [min(data{:,pId}), max(data{:,pId})];          % Color bar limits (e.g., RSRP in dBm)

% Call the function to plot
gplotCol(data, latId, lonId, pId, tstr, clim);

% Function Definition
function gplotCol(data, latId, lonId, pId, tstr, clim)
    figure;
    geoscatter(data{:,latId}, data{:,lonId}, 10*ones(size(data{:,latId}))', data{:,pId}, "filled");
    colorbarHandle = colorbar; % Get the handle to the colorbar
    colorbarHandle.Limits = clim;
    colorbarHandle.Label.String = data.Properties.VariableNames{pId};
    colorbarHandle.Label.Interpreter = 'none';
    % title(strcat(tstr, " : ", data.Properties.VariableNames{pId}), 'Interpreter', 'none');
    title(strcat(tstr, data.Properties.VariableNames{pId}), 'Interpreter', 'none');
    
    % Specify the directory and file name for saving the figure
    saveDir = 'C:\Users\MNT\Desktop\OCL_DEMO\GitHub\SIT-5G-Network-QoE-Analysis\MatlabFiles\geolocation_results';
    saveFileName = strcat(data.Properties.VariableNames{pId}, '_Visualization.png'); % Dynamic name based on pId
    saveFile = fullfile(saveDir, saveFileName);

    % Save the figure as a file
    saveas(gcf, saveFile);  % Save as PNG
    % exportgraphics(gcf, saveFile, 'Resolution', 300); % High-res option (optional)
     
    % Save the figure as a file
    saveas(gcf, 'RSRP_Visualization.png');  % Save as PNG
    % exportgraphics(gcf, 'RSRP_Visualization.png', 'Resolution', 300); % High-res option (optional)
end