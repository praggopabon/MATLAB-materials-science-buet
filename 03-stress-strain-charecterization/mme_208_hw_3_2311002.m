%____________GUIDELINES___________________________________________________
% while using the code, the user needs to change a few places where the
% files get saved. in the lines: 87-88, 134-139
% these are the lines where i have used my own directory
% otherwise, while using the code, the original csv files should be kept
% in the same directory as the m file. thats all i hope. 
%_________________________________________________________________________
% my directory for the m file is: 
% C:\Users\Praggo\Desktop\MATLAB MME208\Assignments\assignment03_2311002.m
% the csv files regarding material tests is also in the same dir: 
% C:\Users\Praggo\Desktop\MATLAB MME208\Assignments

% there are data on 3 materials: BCC W, FCC Al, FCC Pt
% now at first, i will read from the csv files and save the data as 
data1 = readtable("15680_W_bcc_atoms_1108.5K_[110]_0.005_ps-1_" + ...
    "strainrate 1.csv");
data2 = readtable("31360_Al_fcc_atoms_746.8K_[110]_0.002_ps-1_" + ...
    "strainrate 1.csv");
data3 = readtable("32256_Pt_fcc_atoms_1837.35K_[111]_0.02_ps-1_" + ...
    "strainrate 1.csv");

% now extract only the 1st and 2nd columns for the stress strain curve
% and keep them in tables
stress1 = data1(:,2); strain1 = data1(:,1);
stress2 = data2(:,2); strain2 = data2(:,1);
stress3 = data3(:,2); strain3 = data3(:,1);

% now converting the tables into arrays
stress1 = table2array(stress1); strain1 = table2array(strain1);
stress2 = table2array(stress2); strain2 = table2array(strain2);
stress3 = table2array(stress3); strain3 = table2array(strain3);

% converting engineering strain to true strain; true_strain = ln(1+strain) 
t_strain1 = log(1+strain1);
t_strain2 = log(1+strain2);
t_strain3 = log(1+strain3);

% now we make 4 subplots
% from the visuals of the graph, extract yield point, UTS, 
% failure stress and strain
% 3 seperate plots:

%____________plotting BCC W______________________________________________
subplot(2,2,1); plot(t_strain1, stress1); 
title('BCC Tungsten'); xlabel('True Strain'); ylabel('True Stress (GPa)');
hold on; % keeps the curve
% yield-point point out:
plot(0.0975803, 34.3216, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 4);
text(0.0975803, 34.3216, '  Yield', 'Color', 'g', 'FontWeight', 'bold');
% UTS point out:
plot(0.322083, 28.0042, 'r*', 'MarkerSize', 6);
text(0.322083, 28.0042, '  UTS', 'Color', 'r', 'FontWeight', 'bold');
% failure-point point out: 
plot(0.45, 0, 'kx', 'MarkerSize', 3, 'LineWidth', 1);
text(0.45, 5, '  Failure', 'Color', 'k', 'FontWeight', 'bold');
hold off;

%____________plotting FCC Al______________________________________________
subplot(2,2,2); plot(t_strain2, stress2); 
title('FCC Aluminum'); xlabel('True Strain'); ylabel('True Stress (GPa)');
hold on;
% yield-point point out:
plot(0.06274, 1.26385, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 4);
text(0.06274, 1.26385, '  Yield', 'Color', 'g', 'FontWeight', 'bold');
% UTS point out:
plot(0.429507, 2.22974, 'r*', 'MarkerSize', 6);
text(0.429507, 2.22974, '  UTS', 'Color', 'r', 'FontWeight', 'bold');
% could not find out a failure point from the curve
hold off;
%____________plotting FCC Pt______________________________________________
subplot(2,2,3); plot(t_strain3, stress3); 
title('FCC Aluminum'); xlabel('True Strain'); ylabel('True Stress (GPa)');
hold on;
% yield-point point out:
plot(0.0582689, 2.37819, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 4);
text(0.0582689, 2.37819, '  Yield & UTS', 'Color', 'g', 'FontWeight', ...
    'bold');
% failure-point point out: 
plot(0.111094, 0.357079, 'kx', 'MarkerSize', 3, 'LineWidth', 1);
text(0.111094, 0.5, '  Failure', 'Color', 'k', 'FontWeight', 'bold');
hold off;

%_________________the combined plot________________________________________
subplot(2,2,4); plot(t_strain1, stress1, t_strain2, stress2, ...
    t_strain3, stress3);
legend('BCC W','FCC Al','FCC Pt');
title('Combined Stress-Strain Curves'); xlabel('True Strain'); 
ylabel('True Stress (GPa)');

% saving the final plot: 
exportgraphics(gcf, ['C:\Users\Praggo\Desktop\MATLAB MME208' ...
    '\Assignments\Stress_Strain_Plots.png'], 'Resolution', 300);

% we find out the names of the columns
col1 = data1.Properties.VariableNames;
col2 = data2.Properties.VariableNames;
col3 = data3.Properties.VariableNames;

% we delete the columns which has their names starting with 'Var'
% because matlab automatically sets the names of unnamed columns to 'Var'
w1 = startsWith(col1,'Var'); data1(:,w1) = [];
w2 = startsWith(col2,'Var'); data2(:,w2) = [];
w3 = startsWith(col3,'Var'); data3(:,w3) = [];

% now we will add 2 columns which will carry the information of 
% displacement and load
% displacement = (final length) - (original length)
% load = (true stress)*(area at that particular time)

% extracting the dimensions 
% BCC W: Lx1..., FCC Al: Lx2..., FCC Pt: Lx3...
Lx1 = data1.Lx_angstrom; Ly1 = data1.Ly_angstrom; Lz1 = data1.Lz_angstrom;
Lx2 = data2.Lx_angstrom; Ly2 = data2.Ly_angstrom; Lz2 = data2.Lz_angstrom;
Lx3 = data3.Lx_angstrom; Ly3 = data3.Ly_angstrom; Lz3 = data3.Lz_angstrom;

% calculate displacements: 
d1 = Lx1 - Lx1(1); d2 = Lx2 - Lx2(1); d3 = Lx3 - Lx3(1);
% add displacement column in matlab tables: 
data1.displacement_Angs = d1; 
data2.displacement_Angs = d2;
data3.displacement_Angs = d3;

% now we calculate load
% stress is in GPa (10^9 Pa), length is in angstrom (10^-10 m). 
% the output for the load will have a unit of Pa/m^2 or N. then we have to
% multiply out answer with (10^9)*(10^-10)^2 = 10^-11
% moreover, the cross sectional area is choosen as Ly*Lz. Lx is the
% transverse direction
load1 = stress1.*(Ly1).*(Lz1).*(1e-11);
load2 = stress2.*(Ly2).*(Lz2).*(1e-11);
load3 = stress3.*(Ly3).*(Lz3).*(1e-11);

% adding the loads to the table
data1.Load_N = load1; data2.Load_N = load2; data3.Load_N = load3;  

% now create new csv files with clean data: 
% Save directly to your specific assignments folder
writetable(data1, ['C:\Users\Praggo\Desktop\MATLAB MME208\Assignments' ...
    '\new_W_data.csv']);
writetable(data2, ['C:\Users\Praggo\Desktop\MATLAB MME208\Assignments' ...
    '\new_Al_data.csv']);
writetable(data3, ['C:\Users\Praggo\Desktop\MATLAB MME208\Assignments' ...
    '\new_Pt_data.csv']);
