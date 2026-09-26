% firstly, before everything, we will change every given value in 
% the same units, so that the calculations will be easier
% the values will be: 

rho_0 = 1e11; G = 26e9; b = 2.86e-10; alpha = 0.3;
epsilon = 1e-3; k1 = 1e8; k2 = 10;

% here, rho_0 is the dislocation density of pure Al
% G is the shear modulus; b is the Burgers vector; 
% alpha is the dimentionless parameter; k1 is the dislocation
% multiplication coefficient; k2 is the recovery coefficient; epsilon is
% the strain rate (originally epsilon dot, but we are using epsilon for
% easy naming. 

%_________________________Part 1___________________________________________
% now we define the differential equation: 
drho_dt = @(t, rho) epsilon*(k1*sqrt(rho)-k2*rho);

% now we define the time span from the reference plot which is t=0 to 1200
timespan = [0 1200];

% we will solve the differential equation, which is an ODE, using ode45
% taking ode45 because this is a nonlinear equation because there exists 
% a sqrt(rho) so we better not use dsolve. but it is also seem not to be
% stiff, taking ode45 is the primary best approach. 

[t, rho] = ode45(drho_dt,timespan,rho_0);

% now we will calcualate stress and strain. 
% strain = strain_rate * time; stress (sigma) equation is given 
% after calculating stress in pascal, we will convert it to megapascal by
% dividing by 1e6

strain = epsilon.*t;
stress = alpha*G*b.*sqrt(rho); stress_MPa = stress/1e6;

% now we plot the results. we will make a subplot of 2 columns and 1 row
figure ('Name','Kocks-Mecking Model Figure 1');

subplot(1,2,1); plot(t,rho,'b-'); grid on;
xlabel('time(s)'); ylabel('dislocation density (m^{-2})');
title ('\rho vs Time');

subplot(1,2,2); hold on;
plot(strain, stress_MPa, 'r-'); grid on; 
xlabel('Plastic Strain (\epsilon)'); ylabel('Stress,\sigma (MPa)');
title('Stress vs Strain');

% we will also draw the horizontal dashed line for the flow stress

% for that we do some calculations. Youngs modulus: we will find it 
% from the initial slope, as it is defined as d(stress)/d(strain)
Y_Pa = (stress(2) - stress(1)) / (strain(2) - strain(1)); 
Y_GPa = Y_Pa / 1e9;

% then we calculate max flow stress. To calculate that, here
% d(rho)/dt = 0, so k1*sqrt(rho) = k2*rho or rho = (k1/k2)^2
rho_ss = (k1/k2)^2;
sigma_max_Pa = alpha*G*b*sqrt(rho_ss);
sigma_max_MPa = sigma_max_Pa/1e6;

% finally, intersection of tangent lines
epsilon_cut = sigma_max_Pa/Y_Pa;

% now we plot.
plot([0, max(strain)], [sigma_max_MPa, sigma_max_MPa], 'k--');
plot([0, epsilon_cut], [0, sigma_max_MPa], 'k--');
legend('Stress vs Strain','\sigma_{flow} ', 'd\sigma_{flow}/d\epsilon_0', ...
    'Location', 'southeast');
hold off;

% we will give a print output of the values we calculated from the graph
fprintf('Youngs Modulus: %.2f GPa\n', Y_GPa);
fprintf('Maximum Flow Stress: %.3f MPa\n', sigma_max_MPa);
fprintf('Effective Flow Strain: %.6f\n', epsilon_cut);


%_____________Part 2_______________________________________________________
% given information: 
Y_target = 70e9;
alphas = [0.01, 0.03, 0.1, 0.3, 1, 3];
% we choose temperature range from the room temperature which is 298K
% Al melting temperature approximately 933K
T = linspace(298, 933, 100); 

figure('Name', 'Figure 2: Parameter Dependence on Temperature');

% now we will loop through each alpha values. For that, we firstly 
% calculate temperature dependent G and rho_ss. as temperature increases, 
% the shear modulus (G) decreases linearly, and the steady state 
% dislocation density (rho_ss) drops exponentially according to the 
% empirical equations provided.

% Then we calculate exact k1 and k2. instead of guessing k1 and k2
% abruptly, we calculate it using the boundary condistions. Here the first
% condition is: at infinity strain, d(rho)/dt = 0. and we also got it
% before that k1 = k2*sqrt(rho_ss). then the second condition is the 
% youngs modulus. then our two main equations become: 
% Y=(alpha*G*b/2)*(k1-k2*sqrt(rho_0)). by substituting , we can get k2.
% then we plug in k2 to find k1. 

% finally, effective flow strain is the intersection of the elastic 
% loading line and the maximum flow stress line.
% for elastic, sigma=E*epsilon and for plastic sigma=sigma_max = 
% alpha*G*b*sqrt(rho_ss). so, E*epsilon_cut=sigma_max

for i = 1:length(alphas)
    alpha = alphas(i);
    
    G_2 = G.*(1-0.5.*(T-300)./933);
    rho_ss = 10^14.*exp(-5.*(T./933-0.3))+1e11;
    
    k2 = (2*Y_target)./(alpha.*G_2.*b.*(sqrt(rho_ss)-sqrt(rho_0)));
    k1 = k2.*sqrt(rho_ss);
   
    sigma_max = alpha.*G_2.*b.*sqrt(rho_ss);
    eps_cut = sigma_max./Y_target;
    
    % now we plot it in 3 subplots
    subplot(1,3,1); hold on; plot(T, k1);
    subplot(1,3,2); hold on; plot(T, k2);
    subplot(1,3,3); hold on; plot(T, eps_cut);
end

% now we again use subplots. here will be 3 subplots.
% we will also use log scale to see all lines clearly

% subplot 1 for k1 
subplot(1,3,1); set(gca, 'YScale', 'log'); title('k_1 vs Temperature');
xlabel('Temperature (K)'); ylabel('Multiplication Coeff (k_1)'); grid on;

% subplot 2 for k2
subplot(1,3,2); set(gca, 'YScale', 'log'); title('k_2 vs Temperature'); 
xlabel('Temperature(K)'); ylabel('Recovery Coeff (k_2)'); grid on;

% subplot 3 for effective strain
subplot(1,3,3); set(gca,'YScale','log'); grid on;
title('\epsilon_{cut} vs Temperature');
xlabel('Temperature (K)');ylabel('Effective Flow Strain (\epsilon_{cut})');

lgd = legend(string(alphas),'Location','best');
title(lgd,'\alpha values');