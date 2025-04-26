%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Simulation Script for BoundingOverwatch Project with R Integration
% DFT Parameters:
% phi1 - sensitivity to attribute differences (typically 0.5-2)
% phi2 - memory/feedback strength (0-1)
% tau - decision time steps (integer > 0)
% error_sd - noise standard deviation (σ_ε)
% beta - [2×1] attribute weights from R estimation
% w - [2×1] attention weights (default [0.5;0.5])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;

%% Step 1: Import CSV Data
% (reference apolloMain_5 amd apolloMain_6 as example for data manipulation)
% biasData = readtable('user_choices.csv'); % Replace with the path to your data file
% disp('User bias data imported successfully.');
% taskChoice_Data = readtable('user_choices.csv'); % Replace with the path to your data file
% disp('User task choice data imported successfully.');
robotChoice_Data = readtable('G:\My Drive\myResearch\Research Experimentation\Apollo\apollo\data\Bounding_Overwatch_Data\testTrial_Bounding_Overwatch.csv');
disp('User robot choice data imported successfully.');

% Extract and organize robot attributes for all three alternatives
attributes = {'Visibility', 'Traversability'};

% Extract choice data and other metadata
choices = robotChoice_Data.choice;
participant_ids = robotChoice_Data.ID;

%% Step 2: R Bridge Implementation
disp('Initializing R bridge...');

% Configure paths
rscript_path = 'C:\Program Files\R\R-4.4.2\bin\x64\Rscript.exe';
r_script = 'G:\My Drive\myResearch\Research Experimentation\Apollo\apollo\example\DFT_Bounding_Overwatch.R';
csvFile = 'G:\My Drive\myResearch\Research Experimentation\Apollo\apollo\data\Bounding_Overwatch_Data\testTrial_Bounding_Overwatch.csv';
outputDir = 'G:\My Drive\myResearch\Research Experimentation\Apollo\apollo\Output_BoundingOverwatch';

% Verify installations
if ~isfile(rscript_path)
    error('Rscript.exe not found at: %s', rscript_path); 
elseif ~isfile(r_script)
    error('R script not found at: %s', r_script);
elseif ~isfile(csvFile)
    error('Input CSV not found at: %s', csvFile);
elseif ~isfolder(outputDir)
    warning('Output folder does not exist, creating: %s', outputDir);
    mkdir(outputDir);
end

% Execute R with JSON output
try
    % Use proper argument formatting
    cmd = sprintf(['"%s" "%s" ', ...
               '-i "%s" -o "%s"'], ...
               rscript_path, r_script, csvFile, outputDir);

[status,result] = system(cmd);
    
    if status == 0
        % Handle output path (whether directory or file)
        if isfolder(outputDir)
            jsonFile = fullfile(outputDir, 'DFT_output.json');
        else
            jsonFile = outputDir;
        end
        
        % Parse JSON output
        if exist(jsonFile, 'file')
            jsonText = fileread(jsonFile);
            params = jsondecode(jsonText);
            
            % Extract parameters with validation
            phi1 = max(0, validateParam(params, 'phi1', 0.5)); % Ensure non-negative
            phi2 = min(max(0, validateParam(params, 'phi2', 0.8)), 1); % Constrain 0-1
            tau = 1 + exp(validateParam(params, 'timesteps', 0.5));
            error_sd = validateParam(params, 'error_sd', 0.1);
            
            % Extract attribute weights
            beta_weights = [
                params.b_traversability;
                params.b_visibility;
            ];
            
            % Get initial preferences from ASCs
            initial_P = [
                validateParam(params, 'asc_1', 0);
                validateParam(params, 'asc_2', 0);
                validateParam(params, 'asc_3', 0);
                0  % Neutral alternative
            ];
            
            disp('Estimated Parameters:');
            disp(['phi1: ', num2str(phi1)]);
            disp(['phi2: ', num2str(phi2)]);
            disp(['tau: ', num2str(tau)]);
            disp(['error_sd: ', num2str(error_sd)]);
            disp('Initial Preferences (from ASCs):');
            disp(initial_P');
        else
            error('R output file not found');
        end
    else
        error('R execution failed: %s', result);
    end
catch ME
    disp('Error during R execution:');
    disp(getReport(ME, 'extended'));
    [phi1, phi2, tau, error_sd] = getFallbackParams();
    beta_weights = [0.3; 0.2; 0.4; 0; 0.5]; % Default weights
    initial_P = zeros(4,1); % Neutral initial preferences
end

%% Step 3: MDFT Formulation to Calculate Preference Dynamics
% (MDFT calculations based on estimated parameters)
current_trial = 1; % Analyze first trial (can be looped later)

% Create M matrix from current trial's attributes
attributes = {'Visibility', 'Traversability'};
M = [
    robotChoice_Data.vis1(current_trial), robotChoice_Data.trav1(current_trial);
    robotChoice_Data.vis2(current_trial), robotChoice_Data.trav2(current_trial);
    robotChoice_Data.vis3(current_trial), robotChoice_Data.trav3(current_trial);
    0.5, 0.5 % Neutral alternative
];

% Normalize beta weights
beta = beta_weights ./ sum(abs(beta_weights)); 
beta = beta'; % Transpose to make it 1×2 for proper multiplication

% Calculate DFT dynamics with initial preferences
if ~exist('w','var') || isempty(w)
    w = [0.5; 0.5]; % Default equal weights for visibility/traversability
end
[E_P, V_P, choice_probs, P_tau] = calculateDFTdynamics(...
    phi1, phi2, tau, error_sd, beta, M, initial_P,w);

% Display results
disp('=== Current Trial Analysis ===');
disp(['Trial: ', num2str(current_trial)]);
disp(['Participant: ', num2str(participant_ids(current_trial))]);
disp(['Actual Choice: Robot ', num2str(choices(current_trial))]);

disp('M matrix (alternatives × attributes):');
disp(array2table(M, ...
    'RowNames', {'Robot1','Robot2','Robot3','Neutral'}, ...
    'VariableNames', attributes));

% Display DFT results with prediction
disp('DFT Results:');
disp(['E_P: ', num2str(E_P', '%.2f  ')]);
disp(['Choice probabilities: ', num2str(choice_probs', '%.3f  ')]);
[~, predicted_choice] = max(choice_probs); % Get index of highest probability
disp(['Predicted choice: Robot ', num2str(predicted_choice)]);
disp(['Actual choice: Robot ', num2str(choices(current_trial))]);
disp(' ');

% Display match/mismatch
if predicted_choice == choices(current_trial)
    disp('✓ Prediction matches actual choice');
else
    disp('✗ Prediction differs from actual choice');
end

% Plot preference evolution
figure;
plot(0:tau, P_tau);
xlabel('Preference Step (\tau)');
ylabel('Preference Strength');
legend({'Robot1','Robot2','Robot3','Neutral'});
title(sprintf('Preference Evolution (Trial %d)', current_trial));
grid on;
%{
%% Step 4: Output Results
disp('Saving results to CSV...');
output_table = table(E_P, V_P, P_tau(end,:)', ...
                     'VariableNames', {'ExpectedPreference', 'VariancePreference', 'FinalPreferences'});
writetable(output_table, 'results.csv');
disp('Results saved successfully!');
%}
%% Helper Functions
function param = validateParam(params, name, default)
    if isfield(params, name) && isnumeric(params.(name))
        param = params.(name);
    else
        warning('Using default for %s', name);
        param = default;
    end
end

function [phi1, phi2, tau, error_sd] = getFallbackParams()
    phi1 = 0.5 + 0.1*randn();
    phi2 = 0.8 + 0.1*randn();
    tau = 10 + randi(5);
    error_sd = 0.1 + 0.05*rand();
    warning('Using randomized default parameters');
end