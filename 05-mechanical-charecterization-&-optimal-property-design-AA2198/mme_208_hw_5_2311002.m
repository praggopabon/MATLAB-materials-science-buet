function mme_208_hw_5_2311002()
% main execution function for homework assignment 5

%_____________data: true stress vs true strain___________________________
    % define the four heat-treatment conditions as a cell array of strings
    conditions = {'As Quenched', 'Under-aged', 'Over-Aged', 'Peak-aged'};
    
    % initialize a structure array to store the raw experimental data
    data(1).name = 'As Quenched';
    data(1).strain_pct = [0.00899, 0.00899, 0.00899, 0.03838,...
        0.07044, 0.07044, 0.07044, 0.09983, 0.12922, 0.15861, 0.188,...
        0.24678, 0.30555, 0.42578, 0.54334, 0.69296, 0.8399, 1.0483, ...
        1.37425, 1.75899, 2.14372, 2.49906, 2.91585, 3.24181, 3.59715,...
        4.04066, 4.51623, 5.04791, 5.49409, 6.05783, 6.6189, 7.21203, ... 
        7.77577, 8.33951, 8.96202, 9.52576, 10.23645, 10.7708, ...
        11.39332, 12.30973, 13.19942];
    data(1).stress_MPa = [2.08485, 9.91293, 22.5802, 35.24747,...
        47.77241, 58.87406, 63.57091, 68.41009, 74.67256, 77.80379, ...
        80.93503, 84.06626, 88.90545, 92.03668, 95.16791, 99.86477, ...
        104.70395, 110.96642, 118.7945, 129.89615, 139.43219, ...
        147.26027, 156.79631, 164.62439, 172.45248, 183.55413, ...
        193.09016, 204.04949, 213.58552, 222.97922, 232.51526, ...
        243.47458, 253.01061, 260.8387, 270.37473, 275.07158, ...
        284.60761, 290.87008, 295.56694, 305.10297, 312.93106];
    
    data(2).name = 'Under-aged';
    data(2).strain_pct = [0.00899, 0.00899, 0.00899, 0.03838, 0.07044, ...
        0.07044, 0.09983, 0.09983, 0.09983, 0.12922, 0.15861, 0.21739, ...
        0.21739, 0.24678, 0.27616, 0.30555, 0.367, 0.367, 0.42578, ...
        0.45517, 0.48456, 0.48456, 0.51395, 0.54334, 0.54334, 0.54334, ...
        0.60212, 0.63151, 0.69296, 0.81051, 0.92807, 1.28341, 1.60937, ...
        1.96738, 2.29334, 2.61929, 2.97463, 3.56776, 4.24906, 4.98913, ...
        5.79066, 6.53073, 7.15325, 7.80516, 8.60668, 9.37614];
    data(2).stress_MPa = [0.51923, 14.75211, 35.24747, 47.77241, ...
        57.30844, 68.41009, 82.50065, 95.16791, 109.4008, 123.63368, ...
        142.56342, 161.49316, 180.4229, 199.35263, 221.41361, ...
        245.04019, 265.67788, 289.30447, 314.49667, 342.96244, ...
        361.89218, 372.99383, 380.82192, 385.51877, 388.65, 391.92357, ...
        395.0548, 396.62042, 398.18604, 399.75165, 402.88289, ...
        410.85331, 413.98454, 421.81263, 426.65181, 432.91428, ...
        437.61113, 447.14716, 454.97525, 464.51128, 470.77375, ...
        475.4706, 483.44102, 486.57225, 491.26911, 494.40034];
    
    data(3).name = 'Over-Aged';
    data(3).strain_pct = [0.00899, 0.00899, 0.00899, 0.03838, 0.03838,...
        0.03838, 0.07044, 0.07044, 0.09983, 0.12922, 0.15861, 0.188, ...
        0.24678, 0.30555, 0.33494, 0.39639, 0.42578, 0.48456, 0.54334, ...
        0.60212, 0.63151, 0.6609, 0.69296, 0.72235, 0.78113, 0.89868, ...
        1.01891, 1.16586, 1.37425, 1.60937, 1.93799, 2.35211, 2.79562, ...
        3.44753, 4.04066, 4.6044, 5.22692, 6.08722, 6.88607, 7.4792];
    data(3).stress_MPa = [5.21608, 17.88335, 32.11623, 41.50994, ...
        51.04597, 60.43968, 69.97571, 87.33983, 104.70395, 123.63368, ...
        148.82589, 177.29166, 202.48387, 234.08087, 263.96993, ...
        300.40612, 330.29518, 361.89218, 406.01412, 440.74236, ...
        451.84401, 456.54087, 464.51128, 470.77375, 472.33937, ...
        473.90499, 475.4706, 477.03622, 478.60184, 481.8754, 489.70349, ...
        494.40034, 502.37076, 510.19884, 518.16926, 521.30049, ...
        527.56296, 535.53338, 537.099, 540.23023];
    
    data(4).name = 'Peak-aged';
    data(4).strain_pct = [0.00899, 0.00899, 0.03838, 0.07044, 0.09983, ...
        0.15861, 0.21739, 0.24678, 0.30555, 0.33494, 0.39639, 0.42578, ...
        0.48456, 0.54334, 0.60212, 0.63151, 0.6609, 0.69296, 0.69296, ...
        0.72235, 0.75174, 0.81051, 0.92807, 1.07769, 1.28341, 1.55059, ...
        1.87654, 2.2025, 2.55784, 2.88646, 3.32997, 3.59715, 3.98188, ...
        4.36661, 4.75135, 5.16814, 5.61165, 5.96699, 6.29295, ...
        6.6189, 6.85668];
    data(4).stress_MPa = [5.21608, 27.27705, 51.04597, 80.93503, ...
        110.96642, 139.43219, 178.85728, 210.45428, 241.90896, ...
        271.94035, 300.40612, 333.42641, 365.02342, 407.57974, ...
        444.01593, 473.90499, 485.00664, 491.26911, 495.96596, ...
        500.80514, 507.06761, 510.19884, 511.76446, 514.8957, ...
        518.16926, 519.73488, 522.86611, 530.6942, 533.96776, ...
        540.23023, 543.36147, 546.4927, 551.18955, 554.46312, ...
        557.59435, 560.72558, 563.85682, 566.98805, 568.55367, ...
        571.82724, 571.82724];
    
%_____________ compute all properties__________________________________
    % initialize result structure array
    R = struct();
    
    % loop through every material condition to extract mechanical properties
    for i = 1:length(conditions)
        cond = conditions{i};
        
        % clean and sort the data for proper mathematical operations
        [eps, sig] = prepare_data(data(i).strain_pct, data(i).stress_MPa);
        
        % calculate young's modulus using initial elastic region
        E = youngs_modulus(eps, sig, 0.004);
        
        % calculate yield strength at 0.2% engineering offset
        [YS, ys_strain] = yield_strength_02(eps, sig, E, 0.002);
        
        % extract ultimate tensile properties
        uts = ultimate_tensile(eps, sig);
        
        % hollomon curve fitting performed here for full plastic region
        [K_full, n_full] = hollomon_fit(eps, sig, eps(2), uts.epsT_UTS);
        
        % hollomon curve fitting performed here specifically after yielding
        [K_y, n_y] = hollomon_fit(eps, sig, ys_strain, uts.epsT_UTS);
        
        % integration performed here to calculate toughness area.
        % note: integrating the entire array up to final recorded strain 
        % inherently satisfies the assumption of failure soon after uts.
        Tough = trapz(eps, sig);
        
        % identify elongation as the final strain point
        elongation = eps(end);
        
        % store all evaluated parameters back into struct for plotting
        R(i).name = cond;
        R(i).strain = eps;
        R(i).stress = sig;
        R(i).E = E;
        R(i).YS = YS;
        R(i).ys_strain = ys_strain;
        R(i).UTS_eng = uts.UTS_eng;
        R(i).sigmaT_UTS = uts.sigmaT_UTS;
        R(i).epsT_UTS = uts.epsT_UTS;
        R(i).K = K_full;
        R(i).n = n_full;
        R(i).K_yield = K_y;
        R(i).n_yield = n_y;
        R(i).Toughness = Tough;
        R(i).Elongation = elongation;
    end
    
%________________print computed properties_______________________________
    % header for the terminal readout
    fprintf('computed properties\n');
    fprintf('%-12s %8s %9s %8s %10s %8s %6s %8s %6s %9s %8s\n', ...
        'condition', 'e(gpa)', 'ys(mpa)', 'uts_t', 'epst_uts', ...
        'k', 'n', 'k_y', 'n_y', 'tough', 'elong');
        
    % iterate and print formatted data rows
    for i = 1:length(conditions)
        fprintf(['%-12s %8.2f %9.2f %8.2f %9.3f%% %8.2f %6.3f ' ...
            '%8.2f %6.3f %9.2f %7.3f%%\n'], ...
            R(i).name, R(i).E/1e3, R(i).YS, R(i).sigmaT_UTS, ...
            R(i).epsT_UTS*100, R(i).K, R(i).n, R(i).K_yield, ...
            R(i).n_yield, R(i).Toughness, R(i).Elongation*100);
    end
    
    % visualization figure to verify data integrity
    figure('Name', 'raw true stress-strain curves', ...
        'Position', [100, 100, 800, 500]);
    hold on; box on; grid on;
    colors = lines(4);
    
    % plot raw data points
    for i = 1:length(conditions)
        plot(R(i).strain * 100, R(i).stress, '-o', 'Color', colors(i,:), ...
             'MarkerSize', 4, 'LineWidth', 1.5, ...
             'DisplayName', conditions{i});
    end
    xlabel('true strain (%)'); ylabel('true stress (mpa)');
    title('aa2198 alloy - experimental true stress-strain curves');
    legend('Location', 'best');
    
%___________figure 1 : bar charts________________________________________
    % generate the first required figure containing the bar charts
    figure('Name', 'figure 1 - calculated material properties', ...
        'Position', [150, 150, 1000, 600]);
        
    % list of fields to extract for the 5 subplots
    properties = {'YS', 'sigmaT_UTS', 'Toughness', 'K', 'n'};
    
    % pre-formatted cell array for multi-line titles without hacking strsplit
    labels = {{'yield strength (0.2% offset)', '[mpa]'}, ...
              {'true stress at uts', '[mpa]'}, ...
              {'toughness', '[mpa]'}, ...
              {'strength coefficient k', '[mpa]'}, ...
              {'strain-hardening exponent n', ''}};
    
    % create 5 subplots
    for i = 1:5
        subplot(2, 3, i); hold on; grid on;
        vals = [R.(properties{i})];
        b = bar(categorical(conditions), vals, 'FaceColor', 'flat');
        b.CData = lines(4);
        ylabel(labels{i}{1});
        title(labels{i});
        
        % add text labels above each bar
        for j = 1:length(vals)
            text(j, vals(j), sprintf('%.1f', vals(j)), ...
                'HorizontalAlignment', 'center','VerticalAlignment', ...
                'bottom', 'FontSize', 9);
        end
    end
    
    % add summary text block in the empty 6th subplot space
    subplot(2, 3, 6); axis off;
    text(0.5, 0.5, sprintf(['aa2198 alloy\n4 heat-treatment ' ...
        'conditions\n5 calculated properties']),'HorizontalAlignment', ...
        'center', 'FontSize', 12, 'EdgeColor', 'k', ...
        'BackgroundColor', '#f0f0f0');
    sgtitle(['figure 1 - calculated material properties for ' ...
        '4 conditions'], 'FontWeight', 'bold');
    
%_____________figure 2 : property-pair log-log fits_______________________
    % collect property arrays across all 4 treatments
    YS_arr = [R.YS];
    UTS_arr = [R.sigmaT_UTS];
    T_arr = [R.Toughness];
    
    % define nested cells of the 3 pairs requested for log-log regression
    pairs = {{'ys vs uts', YS_arr, UTS_arr, 'ys [mpa]', ['true stress ' ...
        'at uts [mpa]']}, {'ys vs toughness', YS_arr, T_arr, ...
        'ys [mpa]', 'toughness [mpa]'},{'uts vs toughness', UTS_arr, ...
        T_arr, 'true stress at uts [mpa]', 'toughness [mpa]'}};
         
    figure('Name', 'figure 2 - property-pair correlations', 'Position', ...
        [200, 200, 1200, 400]);
        
    % tracking variables to find the best correlation
    best_r2 = -Inf; best_pair_idx = 1;
    fit_res = struct();
    
    for i = 1:3
        p_data = pairs{i};
        
        % curve fitting performed here for power law relationships
        [a, b_val, r2] = fit_power_law(p_data{2}, p_data{3});
        
        % store fitting results
        fit_res(i).name = p_data{1}; fit_res(i).a = a; ...
            fit_res(i).b = b_val; fit_res(i).r2 = r2;
        
        % check if this is the highest r-squared value so far
        if r2 > best_r2
            best_r2 = r2; best_pair_idx = i;
        end
        
        % create log-log subplot
        subplot(1, 3, i);
        loglog(p_data{2}, p_data{3}, 'o', 'MarkerSize', 8, ...
            'MarkerFaceColor', colors(1,:), 'DisplayName', 'data');
        hold on; grid on; set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on');
        
        % generate theoretical power-law curve to plot
        xfit = logspace(log10(min(p_data{2})*0.9), ...
            log10(max(p_data{2})*1.1), 200);
        yfit = a * xfit.^b_val;
        
        % overlay best fit line
        loglog(xfit, yfit, '--', 'Color', colors(2,:), 'LineWidth', 2, ...
               'DisplayName', sprintf(['fit: y = %.3f * ' ...
               'x^{%.3f}\nr^2 = %.4f'], a, b_val, r2));
        xlabel(p_data{4}); ylabel(p_data{5}); title(p_data{1});
        legend('Location', 'best');
    end
    
    % justification: the property pair with the highest r^2 value on 
    % a log-log scale 
    % indicates the strongest power-law relationship, making it the 
    % 'best' fit for a straight-line model.
    
    sgtitle(sprintf(['figure 2 - property-pair correlations on ' ...
        'log-log scale\nbest straight-line fit: ''%s'' (r^2 = %.4f)'], ...
        fit_res(best_pair_idx).name, fit_res(best_pair_idx).r2), ...
        'FontWeight', 'bold');
        
    % print log-log fit results to terminal
    fprintf('\nproperty-pair fits (log-log, y = a*x^b):\n');
    for i = 1:3
        fprintf('  %-20s: a = %.4f, b = %.4f, r^2 = %.4f\n', ...
            fit_res(i).name, fit_res(i).a, fit_res(i).b, fit_res(i).r2);
    end
    fprintf(['best straight-line fit on log-log scale: ''%s'' ' ...
        '(r^2 = %.4f)\n'], fit_res(best_pair_idx).name, ...
        fit_res(best_pair_idx).r2);

%________interpolation + optimization (toughness vs ys)_________________
    % pull secondary property arrays
    EL_arr = [R.Elongation];
    E_arr = [R.E];
    K_arr = [R.K];
    n_arr = [R.n];
    
    fprintf('interpolation & optimization (toughness vs ys)');
    
    % numerical optimization performed here to find the absolute 
    % maximum toughness
    [YS_opt, T_opt_at_YS] = find_optimal_x_for_max_toughness...
    (YS_arr, T_arr);
    fprintf('  optimal ys for max toughness = %.3f mpa\n', YS_opt);
    fprintf('  max interpolated toughness   = %.3f mpa\n', T_opt_at_YS);
    
    fprintf('\n--- linear fits vs ys (y = m*ys + c) ---\n');
    
    % curve fitting performed here to predict all sub-properties 
    % vs optimal ys
    [UTS_pred, UTS_fit] = predict_property(YS_opt, YS_arr, UTS_arr);
    [EL_pred, EL_fit] = predict_property(YS_opt, YS_arr, EL_arr);
    [E_pred, E_fit] = predict_property(YS_opt, YS_arr, E_arr);
    [K_pred, K_fit] = predict_property(YS_opt, YS_arr, K_arr);
    [n_pred, n_fit] = predict_property(YS_opt, YS_arr, n_arr);
    
    % summarize linear fit parameters
    names = {'uts', 'elongation', 'e', 'k', 'n'};
    fits = {UTS_fit, EL_fit, E_fit, K_fit, n_fit};
    preds = [UTS_pred, EL_pred, E_pred, K_pred, n_pred];
    for i = 1:5
        fprintf(['  %-11s: m = %.4e, c = %.4e, r^2 = %.4f, ...' ...
            'predicted at ys_opt = %.4f\n'], names{i}, fits{i}.m, ...
            fits{i}.c, fits{i}.r2, preds(i));
    end
    
    % generate continuous simulated data curve for ideal ys
    [eps_A, sig_A, tough_A] = build_stress_strain_curve(YS_opt, ...
        UTS_pred, K_pred, n_pred, E_pred, EL_pred);
    
%_______repeat with uts as primary independent variable________________
    fprintf('interpolation & optimization (toughness vs uts)');
    
    % numerical optimization performed here to find maximum toughness 
    % based on uts
    [UTS_opt, T_opt_at_UTS] = find_optimal_x_for_max_toughness(UTS_arr, ...
        T_arr);
    fprintf('  optimal uts for max toughness = %.3f mpa\n', UTS_opt);
    fprintf('  max interpolated toughness    = %.3f mpa\n', T_opt_at_UTS);
    
    fprintf('\n--- linear fits vs uts (y = m*uts + c) ---\n');
    
    % curve fitting performed here to predict all sub-properties 
    % vs optimal uts
    [YS_pred2, YS_fit2] = predict_property(UTS_opt, UTS_arr, YS_arr);
    [EL_pred2, EL_fit2] = predict_property(UTS_opt, UTS_arr, EL_arr);
    [E_pred2, E_fit2] = predict_property(UTS_opt, UTS_arr, E_arr);
    [K_pred2, K_fit2] = predict_property(UTS_opt, UTS_arr, K_arr);
    [n_pred2, n_fit2] = predict_property(UTS_opt, UTS_arr, n_arr);
    
    names2 = {'ys', 'elongation', 'e', 'k', 'n'};
    fits2 = {YS_fit2, EL_fit2, E_fit2, K_fit2, n_fit2};
    preds2 = [YS_pred2, EL_pred2, E_pred2, K_pred2, n_pred2];
    for i = 1:5
        fprintf(['  %-11s: m = %.4e, c = %.4e, r^2 = %.4f, predicted ' ...
            'at uts_opt = %.4f\n'], names2{i}, fits2{i}.m, fits2{i}.c, ...
            fits2{i}.r2, preds2(i));
    end
    
    % generate continuous simulated data curve for ideal uts
    [eps_B, sig_B, tough_B] = build_stress_strain_curve(YS_pred2, ...
        UTS_opt, K_pred2, n_pred2, E_pred2, EL_pred2);
    
%____________figure 3 - ideal stress-strain curves_____________________
    % spawn the third and final figure window
    figure('Name', 'figure 3 - hypothetical ideal curves', ...
        'Position', [250, 250, 800, 500]);
    hold on; box on; grid on;
    
    % plot continuous generated curves
    plot(eps_A * 100, sig_A, '-', 'LineWidth', 2.5, 'Color', ...
        colors(1,:), 'DisplayName', sprintf(['max-toughness via ' ...
        'ys (curve a)\n  ys = %.1f mpa, toughness = %.1f mpa'], ...
        YS_opt, tough_A));
    plot(eps_B * 100, sig_B, '-', 'LineWidth', 2.5, 'Color', colors(2,:), ...
        'DisplayName', sprintf(['max-toughness via uts (curve b)\n  ' ...
        'uts = %.1f mpa, toughness = %.1f mpa'], UTS_opt, tough_B));
    
    % embed explicitly annotated text labels near the curves
    text(eps_A(end)*100*0.35, max(sig_A)*0.85, sprintf(['max toughness ' ...
        '(curve a)\n= %.2f mpa'], tough_A), 'Color', colors(1,:), ...
        'FontWeight', 'bold');
    text(eps_B(end)*100*0.55, max(sig_B)*0.75, sprintf(['max toughness ' ...
        '(curve b)\n= %.2f mpa'], tough_B),'Color', colors(2,:), ...
        'FontWeight', 'bold');
         
    xlabel('true strain (%)'); ylabel('true stress (mpa)');
    title(sprintf(['figure 3 - stress-strain curves for hypothetical ' ...
        'ideal materials\n(maximum-toughness designs derived from ' ...
        'ys-based and uts-based fits)']));
    legend('Location', 'southeast', 'FontSize', 10);
    
%___________________summary________________________________________________
    % print final values to easily check rubric requirements
    fprintf('summary\n');
    fprintf('best log-log pair: %s  (r^2 = %.4f)\n', ...
        fit_res(best_pair_idx).name, fit_res(best_pair_idx).r2);
    fprintf('optimal ys: %.3f mpa   -> max toughness = %.3f\n', ...
        YS_opt, T_opt_at_YS);
    fprintf('optimal uts: %.3f mpa  -> max toughness = %.3f\n', ...
        UTS_opt, T_opt_at_UTS);
    fprintf('toughness (curve a): %.3f mpa   (ys-driven)\n', tough_A);
    fprintf('toughness (curve b): %.3f mpa   (uts-driven)\n', tough_B);
    
    % declare convention statement required by the prompt instructions
    fprintf(['\nstress-strain convention: true stress and true strain ' ...
        'conventions were used for all data and calculations.\n']);
    
end

% helper functions
function [uniq_s, uniq_t] = prepare_data(strain_pct, stress_MPa)
    % force inputs to be column vectors to prevent matrix expansion issues
    s = strain_pct(:) / 100.0;
    t = stress_MPa(:);
    
    % sort values based on ascending strain
    [s, sort_idx] = sort(s);
    t = t(sort_idx);
    
    % isolate unique strain values to prevent integration/fit errors
    [uniq_s, ~, ic] = unique(s);
    uniq_t = accumarray(ic, t, [], @max);
end

function E = youngs_modulus(strain, stress, limit)
    % isolate initial elastic region points
    mask = strain < limit;
    if sum(mask) < 3
        % fallback if not enough points exist under limit
        mask = false(size(strain));
        mask(1:min(5, length(mask))) = true;
    end
    s = strain(mask); t = stress(mask);
    best_E = 0; best_r2 = -Inf;
    
    for k = 3:length(s)
        % curve fitting performed here to extract modulus
        p = polyfit(s(1:k), t(1:k), 1);
        pred = polyval(p, s(1:k));
        ss_res = sum((t(1:k) - pred).^2);
        ss_tot = sum((t(1:k) - mean(t(1:k))).^2);
        if ss_tot > 0
            r2 = 1 - ss_res / ss_tot;
        else
            r2 = 0;
        end
        % iteratively find the highest linear r2 for elastic modulus
        if r2 > best_r2 && p(1) > 0
            best_r2 = r2; best_E = p(1);
        end
    end
    
    % assign the final calculated value to the output variable
    E = best_E;
end

function [YS, ys_strain] = yield_strength_02(strain, stress, E, offset)
    % set default offset to 0.002
    if nargin < 4, offset = 0.002; end
    
    % determine the vertical difference between data and offset line
    diff = stress - E * (strain - offset);
    
    % find indices where difference crosses zero
    crossings = find(diff(1:end-1) > 0 & diff(2:end) ...
        < 0 | diff(1:end-1) < 0 & diff(2:end) > 0);
    
    if isempty(crossings)
        % fallback to closest distance if no clean intersection
        [~, i] = min(abs(diff));
        YS = stress(i); ys_strain = strain(i);
        return;
    end
    
    % linearly interpolate exact coordinates of the intersection
    i = crossings(1);
    t_interp = -diff(i) / (diff(i+1) - diff(i));
    ys_strain = strain(i) + t_interp * (strain(i+1) - strain(i));
    YS = stress(i) + t_interp * (stress(i+1) - stress(i));
end

function uts = ultimate_tensile(strain, stress)
    % convert given true stress to engineering stress
    sigma_eng = stress .* exp(-strain);
    
    % differentiation performed here to find uts location by 
    % identifying the peak engineering stress point
    d_sigma_eng = gradient(sigma_eng, strain);
    [~, i_eng] = max(sigma_eng);
    
    % store the values occurring at the point of necking
    uts.UTS_eng = sigma_eng(i_eng);
    uts.sigmaT_UTS = stress(i_eng);
    uts.epsT_UTS = strain(i_eng);
    uts.d_sigma_eng_at_UTS = d_sigma_eng(i_eng);
end

function [K, n] = hollomon_fit(strain, stress, eps_lo, eps_hi)
    % filter data bounds exclusively inside plastic region
    mask = strain >= eps_lo & strain <= eps_hi & strain > 0 & stress > 0;
    if sum(mask) < 3
        K = NaN; n = NaN;
        return;
    end
    % calculate logarithmic inputs
    ls = log(strain(mask));
    lt = log(stress(mask));
    
    % curve fitting performed here to extract k and n
    p = polyfit(ls, lt, 1);
    
    % convert linear fit coefficients to hollomon constants
    n = p(1);
    K = exp(p(2));
end

function [a, b_val, r2] = fit_power_law(xs, ys)
    % curve fitting performed here for log-log power law relationship
    p = polyfit(log(xs), log(ys), 1);
    b_val = p(1);
    a = exp(p(2));
    
    % calculate statistical fit variance
    log_pred = polyval(p, log(xs));
    ss_res = sum((log(ys) - log_pred).^2);
    ss_tot = sum((log(ys) - mean(log(ys))).^2);
    if ss_tot > 0
        r2 = 1 - ss_res / ss_tot;
    else
        r2 = 0;
    end
end

function [x_opt, max_val] = find_optimal_x_for_max_toughness(x_arr, t_arr)
    % setup interpolation space with sorted arrays
    [x_arr_sorted, sort_idx] = sort(x_arr);
    t_arr_sorted = t_arr(sort_idx);
    
    % objective function to minimize using interp1 to guarantee 
    % interpolation compatibility 
    obj_fun = @(x) -interp1(x_arr_sorted, t_arr_sorted, x, 'spline');
    
    % numerical optimization bounds search over full defined range
    [x_opt, min_val] = fminbnd(obj_fun, min(x_arr), max(x_arr));
    max_val = -min_val;
end

function [pred, fit_struct] = predict_property(x_target, x_arr, y_arr)
    % curve fitting performed here for secondary property linear fits
    p = polyfit(x_arr, y_arr, 1);
    m = p(1); c = p(2);
    
    % predict continuous parameter behavior
    pred = polyval(p, x_target);
    
    % calculate fit statistics
    ss_res = sum((y_arr - polyval(p, x_arr)).^2);
    ss_tot = sum((y_arr - mean(y_arr)).^2);
    if ss_tot > 0
        r2 = 1 - ss_res / ss_tot;
    else
        r2 = 0;
    end
    
    fit_struct.m = m; fit_struct.c = c; fit_struct.r2 = r2;
end

function [eps, sig, tough] = build_stress_strain_curve(YS, ~, K, n, ...
    E, elongation)
    n_points = 500;
    
    % identify transition point between elastic and plastic behavior
    strain_y = YS / E;
    
    % create partitioned domain arrays
    n_el = max(20, floor(n_points / 10));
    eps_el = linspace(0, strain_y, n_el);
    eps_pl = linspace(strain_y, elongation, n_points - n_el + 1);
    
    % drop the duplicate point at yield
    eps_pl = eps_pl(2:end); 
    
    % apply extrapolated hollomon constants
    sig_pl_hollomon = K * (eps_pl.^n);
    
    % ensure c0 continuity at yield point by shifting the plastic curve
    % to account for independent linear predictions of k and n
    shift = YS - sig_pl_hollomon(1);
    sig_pl = sig_pl_hollomon + shift;
    
    % assemble the global discrete curve
    eps = [eps_el, eps_pl];
    sig = [E * eps_el, sig_pl];
    
    % integration performed here to compute hypothetical curve toughness
    tough = trapz(eps, sig);
end