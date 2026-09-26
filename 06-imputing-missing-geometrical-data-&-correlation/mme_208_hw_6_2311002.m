% ______________Geochemistry Data (Embedded Directly)______________________
% The data from "Geochemistry Table Part 1.xlsx" is hard-coded below as a
% cell array, so the script no longer needs to read from an external file.
% Missing/blank cells from the original spreadsheet are entered as NaN.

rawData = {
    '', 'Sea water', 'Spreading center', 'Back-arc basin', 'Arc',...
    'Rotokawa', 'Salton Sea', 'Cerro Prieto', 'Reykjanes', ...
    'Ladolam gold deposit', 'Mississippi';
    'Temp (°C)', 2, 350, 282, 268, 320, 330, 337, 296, 275, 107;
    'pH (25 °C)', 7.8, 3.4, 4.1, 2.6, 6.03, 5.1, 8, NaN, 8.01, 5.65;
    'Na (mm)', 469.003, 436.334, 540.637, 449.6, 12.139, 2382.609, ...
    419.98, 393, 1154.697, 76.257;
    'K (mm)', 9.804, 23.021, 24.023, 86.29, 2.046, 453.846, 77.064, 38, 125.641, 17.686;
    'Ca (mm)', 10.204, 16.01, 82.27, 15.009, 0.012, 712.5, 10.059, 47, 0.227, 774.343;
    'Mg (mm)', 52.768, NaN, 0, 0, 0, 2.042, 0.002, 0.39, 0.004, NaN;
    'Mn (mm)', NaN, 0.96, 0.348, 3.117, NaN, 27.273, 0.01, 52000, NaN, 1.163;
    'Fe (mm)', NaN, 1.664, 0.109, 2.404, NaN, 30.536, 0.004, 0.43, NaN, 6.198;
    'Si (mm)', 0.2, 18.01, 15.007, 16.008, 23.409, 9.8, 48.169, 10, 19.238, 0.712;
    'Ba (μm)', 0.14, 8, 17, 91.001, NaN, 2576.642, NaN, 71, NaN, 1056.004;
    'Cu (ppm)', NaN, 2.224, 0.127, 2.288, NaN, 6.8, 0.005, 16.586, 4.45, 0.02;
    'Zn (ppm)', NaN, 6.931, 0.654, 7.52, NaN, 507, 0.006, 24.987, 0.185, 222;
    'Pb (ppm)', NaN, 63.818, 0.829, 1450.4, NaN, 102, 0.005, 0.001, 0.023, 53.2;
    'Mo (ppm)', NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.015, 0.043, NaN;
    'Sn (ppm)', NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.001, 0.84, NaN;
    'Cd (ppm)', NaN, 0.18, NaN, NaN, NaN, 2.3, NaN, 0.135, NaN, 0.83;
    'Ag (ppb)', NaN, 0.037, NaN, NaN, 1100, 1400, 4, 34.626, 6, NaN;
    'Au (ppb)', NaN, NaN, NaN, NaN, NaN, 7.8, 4, 6.106, 16, NaN;
    'As (ppm)', NaN, NaN, NaN, NaN, NaN, 5.4, 2, 0.112, 17, NaN;
    'Sb (ppm)', NaN, NaN, NaN, NaN, NaN, 1.2, 0.4, 0.025, 0.004, NaN;
    'Cl (mm)', 551.626, 497.669, 730.5, 583.889, 14.62, 4500, 526.019, 524, 613.923, 5614.69;
    'Br (mm)', 0.808, 0.855, 1.03, 1, NaN, 1.388, NaN, 0.78, 0.451, 13.029;
    'F (mm)', 0.064, NaN, 0.023, 0.116, 0.3, NaN, NaN, NaN, NaN, 0.042;
    'B (mm)', 0.426, 0.548, 0.24, 1.62, 9, 24.636, 2.22, 0.709, 12.213, 8.049;
    'SO4 (mm)', 22.366, 0.4, 1.88, 0.42, 0.041, 0.552, NaN, NaN, 410.375, 0.187;
    'H₂S (mm)', 0, 7.303, 1.8, 6.803, 7.31, 0.294, 22.617, 0.9, NaN, NaN;
    'HCO₃ (mm)', 2.931, 7.266, 7.649, 40.854, 1.072, 35.909, 1.072, NaN, 48.261, NaN;
};

% Extract the variable names (chemistry components) from the first column.
% We assume the first row contains headers (locations),
% so we start from row 2.
% We convert the cell array of strings into a string array
% and trim whitespace.
varNames = strtrim(string(rawData(2:end, 1)));

% Extract the pure data cells containing numerical values
% or missing indicators.
% This ignores the first column (names) and the first row (headers).
M_cell = rawData(2:end, 2:end);

% Initialize a numerical matrix M with NaNs, having the same size as M_cell.
M = nan(size(M_cell));

% Loop through each cell in M_cell to safely convert it to a double matrix.
for i = 1:size(M_cell, 1)
    for j = 1:size(M_cell, 2)
        val = M_cell{i, j}; % Extract the value of the current cell
        
        % If the cell contains a regular numeric scalar, store it directly
        if isnumeric(val) && isscalar(val)
            M(i, j) = double(val);
            
        % If the cell contains text, try to convert it to a number
        % (e.g., in case numbers are accidentally stored as strings)
        elseif ischar(val) || isstring(val)
            num = str2double(val);
            if ~isnan(num)
                M(i, j) = num;
            end
        end
        % Note: If the cell is genuinely empty or missing, it remains NaN
        % because M was initialized with NaNs.
    end
end

% S_________________Fill Missing Values (8 Trials)_________________________
% Define the 4 algorithms specified in the problem statement
algorithms = {'linear', 'spline', 'makima', 'pchip'};
num_algs = length(algorithms);

% Pre-allocate cell arrays and matrices to store the 
% results of all 8 trials
M_filled_all = cell(8, 1);       
% Stores the 8 filled matrices
trial_names = strings(8, 1);     
% Stores the descriptive name of the trial
nan_counts = zeros(8, 1);        
% Stores the count of remaining NaNs

% Keep track of the current trial index
trial_idx = 1;

% Loop through each of the 4 algorithms to perform the trials
for i = 1:num_algs
    alg = algorithms{i};
    
    % Trial A: Without Logarithmic Transformation (Normal)
    % As per instructions, we transpose M (M'), fill missing values along 
    % the columns (which are now the chemical variables), and transpose back.
    M2_normal = (fillmissing(M', alg))';
    
    % Store the result, name, and the count of remaining NaNs
    M_filled_all{trial_idx} = M2_normal;
    trial_names(trial_idx) = sprintf('Normal - %s', alg);
    nan_counts(trial_idx) = sum(isnan(M2_normal), 'all');
    trial_idx = trial_idx + 1;
    
    % Trial B: With Logarithmic Transformation (Log/Exp)
    % We take the natural logarithm of M, apply the fillmissing function,
    % and then exponentiate the result to revert the log transformation.
    % Note: If there are zeros in M, 
    % log(0) is -Inf. fillmissing handles it.
    
    % Temporarily suppress warnings for log of zero or negative numbers
    % to keep the command window output clean.
    warning('off', 'MATLAB:log:logOfZero');
    
    % Perform the transformation, filling, and reverse transformation
    M2_log = exp(fillmissing(log(M)', alg))';
    
    % Restore warnings
    warning('on', 'MATLAB:log:logOfZero');
    
    % Store the result, name, and the count of remaining NaNs
    M_filled_all{trial_idx} = M2_log;
    trial_names(trial_idx) = sprintf('Log/Exp - %s', alg);
    nan_counts(trial_idx) = sum(isnan(M2_log), 'all');
    trial_idx = trial_idx + 1;
end

% ______________________Identify the Best Trial____________________________

% Find the index of the trial that resulted in the absolute 
% minimum number of NaNs
[min_nans, best_idx] = min(nan_counts);

% Extract the final, best-filled matrix to be used for correlations
best_fill = M_filled_all{best_idx};

% Ensure all data is purely real (in case log/exp generated minor imaginary 
% parts from negative interpolations). 
% This ensures safe correlation calculations.
if ~isreal(best_fill)
    best_fill = real(best_fill);
end

% _________________Correlate the Chemistry Variables_______________________
% Calculate the correlation (r) and p-value (p) 
% between the chemistry variables.
% We use 'rows', 'pairwise' to calculate correlations 
% ignoring any remaining NaNs.
% best_fill' (transpose) ensures we are correlating the chemical variables 
% rather than the locations.
[r, p] = corr(best_fill', 'rows', 'pairwise');

% _________Find and Display Highly Correlated Variable Pairs_______________
% We need to pick unique variable pairs that are more than 99.9% likely to 
% be correlated. This means the probability of being 
% un-correlated (p-value)
% must be less than 0.001 (100% - 99.9% = 0.1% = 0.001).

num_vars = length(varNames);

% Initialize empty arrays to store the highly correlated pairs
correlations = [];
p_values = [];
var1_list = strings(0);
var2_list = strings(0);

% Loop through the upper triangular part of the correlation matrix 
% (j = i+1 to num_vars) to evaluate unique pairs and 
% avoid self-correlation (i=j).
for i = 1:num_vars
    for j = (i+1):num_vars
        % Check if the p-value meets the >99.9% certainty threshold
        if p(i, j) < 0.001
            % Save the correlation coefficient, p-value, and 
            % the variable names
            correlations(end+1) = r(i, j);
            p_values(end+1) = p(i, j);
            var1_list(end+1) = varNames(i);
            var2_list(end+1) = varNames(j);
        end
    end
end

% Sort the identified pairs from highest to lowest certainty of correlation.
% Highest certainty corresponds to the lowest p-value, so we sort ascending.
[sorted_p, sort_idx] = sort(p_values, 'ascend');
sorted_r = correlations(sort_idx);
sorted_var1 = var1_list(sort_idx);
sorted_var2 = var2_list(sort_idx);

% Display the final sorted list of correlated variable pairs side-by-side
fprintf('Highly Correlated Variable Pairs\n');
for i = 1:length(sort_idx)
    % Print using the exact likeness format shown 
    % in the homework instruction:
    % Example format: "Cl (mm) - Ca (mm);r = 0.9922 , p = 1.6043e-08"
    fprintf('"%s - %s; r = %g , p = %g"\n', ...
        sorted_var1(i), sorted_var2(i), sorted_r(i), sorted_p(i));
end