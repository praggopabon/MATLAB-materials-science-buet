clear; clc; close all;

%____________________physical constants and parameters___________________ 
% number of cubical shells (taking 1000)
N = 1000; 
% Lattice parameter, unit: meter (m) 
a = 5.6413e-10; 
% theoretical scaling factor (J/mol)
C_scale = 2.46285E5;

%__________________using symmetry for optimization_______________________
% preallocating arrays for higher speed
shell = zeros(1, N);
time = zeros(1,N);

tic;
for i = 1:N
    sum_i = 0;
    
    % iterate through 1/48th of the current cubical shell
    for j = 0:i
        % k is vectorized for speed
        k = 0:j; 
        % initializing weights for interior points which is shared by 
        % 1 triangle
        w = 48*ones(1,length(k));
        % The geometric boundaries of the 1/48th wedge are k=0, j=i, 
        % and j=k. weights for lines shared by 2 triangles
        % for line k=0
        w(k==0) = 24; 
        % for line j=i
        if j==i
            w(:)=24;       
        end
        % for line j=k
        w(k==j) = 24;      
        
        % weights for vertices which overrides lines
        if j==0
            % point (i,0,0) shared by 8
            w(k==0) = 6;   
        end
        if j == i
            % point (i,i,0) shared by 4
            w(k == 0) = 12;  
            % point (i,i,i) shared by 6
            w(k == i) = 8;   
        end
        
        % energy term for the slice and summation of i
        sign =(-1).^(i + j + k);
        dists =sqrt(i^2 + j^2 + k.^2);
        sum_i =sum_i + sum(w.*sign./dists);
    end
    shell(i)=sum_i;
    time(i)=toc;
end

%_____________________error and convergence_______________________________
% cumulative energy
E_cum = -C_scale*cumsum(shell);

% probable sum
% it is the moving average to find the center of the alternating series
E_prob = (E_cum(1:end-1)+E_cum(2:end))/2;
x_prob = 1.5:1:N;
% best estimate of converged value
E_true = E_prob(end); 

% extracting peaks and valleys for bounds
is_odd = mod(1:N, 2) ~= 0;
x_odd = find(is_odd);
x_even = find(~is_odd);

% ensuring we only fit the stabilizing tail of the series
start_fit = 20;

% upper bound fit
valid_odd = x_odd>start_fit & E_cum(x_odd)>E_true;
x_fu = x_odd(valid_odd);
y_fu = log(E_cum(x_fu) - E_true);
p_up = polyfit(log(x_fu), y_fu, 1);
fit_upper = exp(p_up(2))*(1:N).^p_up(1) + E_true;

% lower bound fit
valid_even = x_even > start_fit & E_cum(x_even) < E_true;
x_fl = x_even(valid_even);
y_fl = log(E_true - E_cum(x_fl));
p_low = polyfit(log(x_fl), y_fl, 1);
fit_lower = E_true - exp(p_low(2))*(1:N).^p_low(1);

% fitting absolute error trend 
err = abs(E_cum-E_true);
x_fit_err = start_fit:N;
p_err = polyfit(log(x_fit_err), log(err(x_fit_err)), 1);
fit_err = exp(polyval(p_err, log(1:N)));

% fitting cumulative time
c_time = mean(time(x_fit_err) ./ (x_fit_err.^3));
fit_time = c_time*(1:N).^3;

% extrapolation for higher accuracy
sig_figs=2:5;
ext_text = cell(length(sig_figs), 1);

for idx = 1:length(sig_figs)
    k = sig_figs(idx);
    % standard definition: relative error limit for k sig figs
    target_err = abs(E_true) * 0.5 * 10^-k; 
    
    % solving error equation: target = exp(b)*x^m 
    % x = exp((ln(target)-b) / m)
    steps = exp((log(target_err) - p_err(2)) / p_err(1));
    req_time = c_time * steps^3;
    
    ext_text{idx} = sprintf(['For %d signf. place accuracy, ~ ' ...
        '%d steps (%.2f s) needed'], k, round(steps), req_time);
    disp(ext_text{idx});
end

% ________________plot generation_________________________________________ 
fig = figure('Units', 'normalized', 'Position', [0.1 0.1 0.85 0.55]);

% left one
subplot(1, 2, 1);
yyaxis left
plot(1:N, E_cum,'-','Color', [0.7 0.7 0.7]);hold on;
plot(1:N, fit_upper, '--g', 'LineWidth', 1);
plot(1:N, fit_lower, '--r', 'LineWidth', 1);
set(gca, 'XScale', 'log');
ylabel(['N_A Z_1 Z_2 e^2/(4\pi\epsilon_0 a) \Sigma_{|i,j,k| \leq x} ' ...
    '-(-1)^{i+j+k}(i^2+j^2+k^2)^{-1/2}']);
xlabel('Neighbor shells counted (x)');
grid on;

yyaxis right
plot(1:N, err, '.', 'Color', [0.8 0.8 0], 'MarkerSize', 8); hold on;
plot(1:N, fit_err, '--k', 'LineWidth', 1.5);
set(gca, 'YScale', 'log');
ylabel('error');

% dynamic legends
str_up = sprintf('upper bound: %.3e*x^{%.3f} + %.3e', exp(p_up(2)), ...
    p_up(1), E_true);
str_low = sprintf('lower bound: -%.3e*x^{%.3f} + %.3e', exp(p_low(2)), ...
    p_low(1), E_true);
str_err = sprintf('Error fit: ln \\epsilon = %.2f %+.2f ln(x)', ...
    p_err(2), p_err(1));
legend('cumulative sum', str_up, str_low, 'Error (\epsilon)', str_err, ...
    'Location', 'southwest');
title('Convergence of Energy Sum');

% right one
subplot(1, 2, 2);
yyaxis left
plot(x_prob, E_prob / 1000, 'o', 'Color', [0.4 0.6 1], ...
    'MarkerSize', 4); hold on;
plot(1:N, repmat(E_true/1000, 1, N), '--b');
set(gca, 'XScale', 'log');
ylabel('probable sum of Energy term (kJ/mol)');
xlabel('Neighbor shells (x) with probable sum or elapsed time');
% zooming in axis
ylim([(E_true/1000 - 5), (E_true/1000 + 5)]); 
grid on;

yyaxis right
plot(1:N, time, 'b-', 'LineWidth', 1.5); hold on;
plot(1:N, fit_time, '--', 'Color', [0 0 0.5], 'LineWidth', 1);
set(gca, 'YScale', 'log');
ylabel('total elapsed time (s)');

% legends and title
str_time = sprintf('cumulative time fit: %.3e * x^3', c_time);
legend('Distribution of Mean', 'cumulative sum', 'cumulative time', ...
    str_time, 'Location', 'southeast');
% calculate standard deviation of the stabilizing tail
sigma_val = std(E_prob(start_fit:end)) / 1000;
title(sprintf(['NaCl: E_{mol} \\sim %.2f kJ/mol after ' ...
    '%d terms\n( median %.3f kJ/mol, \\sigma = %.3f kJ/mol ) ' ...
    'in %.2f s'], ...
    E_true/1000, N, median(E_prob)/1000, sigma_val, time(end)));


% output: it takes longer in the first run 
% For 2 signf. place accuracy, ~ 66 steps (0.01 s) needed
% For 3 signf. place accuracy, ~ 660 steps (6.57 s) needed
% For 4 signf. place accuracy, ~ 6651 steps (6707.45 s) needed
% For 5 signf. place accuracy, ~ 66980 steps (6850519.20 s) needed