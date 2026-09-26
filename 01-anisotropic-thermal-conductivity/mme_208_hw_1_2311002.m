clc, clear

% _______________________RMS CALCULATION_____________________________
% for a hexagonal system, properties on the basal plane are isotropic
% so k_xx=k_yy
% putting the two equations relating k_xx, k_yy and k_zz to solve: 
syms l m; 
[k_xx_sol, k_zz_sol] = vpasolve([(2*l)+m==800, (l^2)*m==225^3],l,m);
% now we will have 3 answers each for k_xx_sol and k_zz_sol
% graphite conducts more heat on its basal plane rather accross it
% because it's basal plane has covalent bonding
% but on the Z-axis, its weak van der waals bond
% so we take the root where k_xx is significantly larger than k_zz 
% we do the picking from the answers:
k_xx = k_xx_sol(1); 
k_yy = k_xx_sol(1); 
k_zz = k_zz_sol(1);
% now we take the RMS value of of this: 
RMS = sqrt((k_xx^2 + k_zz^2 + k_yy^2)/3); %360.470086
disp("RMS Value of k_xx, k_yy and k_zz: ");
disp(double(RMS) + " W/(m.K)");
fprintf("\n");

%___________________GRADIENT CALCULATION____________________________
% given lattice parameters: 
a = 2.47E-10; b = 2.47E-10; c = 7.8E-10;
%alpha = pi/2; beta = pi/2; gamma = 2*pi/3;
% originally, graphite's hexagonal lattice has gamma = 120 degree
% but for simplicity of calculation,
% x,y,z are treated as orthogonal 
% direction vector along [2 0 1] direction: 
v = [2*a 0*b 1*c];
% unit vector along [2 0 1]:
unit = v/norm(v);
% heat flux vector along [2 0 1]
q = 3000*unit;
% according to Fourier's Law: q =-k*(temperature gradient)
grad_x = -q(1)/k_xx; % -4.52484998 K/m
grad_y = -q(2)/k_yy; % 0
grad_z = -q(3)/k_zz; % -28.0003633 K/m 

disp("dT_dz: "+double(grad_z)+" K/m");
disp("dT_dy: "+double(grad_y)+" K/m");
disp("dT_dx: "+double(grad_x)+" K/m");
fprintf("\n");

%___________________MAX-MIN GRADIENT____________________________
% overall magnitude of the thermal gradient will be 
% grad = sqrt(grad_x^2 + grad_y^2 + grad_z^2)
% it can be also written as:
% we got to know, grad = q_total/sqrt(k_xx^2 + k_yy^2 + k_zz^2)
% from this, we can say that grad_max comes when k has the lowest value
% grad_min comes when k has the highest value 

% along x-y plane, as k_xx = k_yy has the highest value and k_zz = 0: 
grad_min = 3000/sqrt(k_xx^2); %8.4568402
% corresponding directions: all, situated on the x-y plane
% as all x and y directions are valid, it is NOT UNIQUE
disp("Minimum Gradient Value =" + double(grad_min));
disp("NOT UNIQUE, Dir: X-Y Plane directions");
fprintf("\n");

% along z plane, k_xx and k_yy value has lowest value: 
grad_max = 3000/sqrt(k_zz^2); %33.143621
% corresponding direction: [0 0 1] and [0 0 -1]
% as only along z-axis, it is UNIQUE
disp("Maximum Gradient Value =" + double(grad_max));
disp("UNIQUE, Dir: Z-axis");
fprintf("\n");

%________________GRADIENT MAGNITUDE VARIATION ___________________
% we need to calculate for the arbitrary directions for both angles
% theta: angle with heat flux and z-axis
% phi: angle with heat flux and x-y basal plane 
% first we take vectors defining 6 angles between 0 to 90:
theta = linspace(0, 90, 6); phi = linspace(0,90,6);
% make a meshgrid out of them: 
[Theta, Phi] = meshgrid(theta, phi);

% now we will measure the magnitude of thermal component 
% for all possible angle combinations created by the meshgrid, in degrees
% q_z = 3000*cosd(theta), q_x = 3000*sind(theta)*cosd(phi)
% q_y = 3000*sind(theta)*sind(phi)
q_x = 3000.*sind(Theta).*cosd(Phi);
q_y = 3000.*sind(Theta).*sind(Phi);
q_z = 3000.*cosd(Theta);

% now we calculate the gradient magnitude using Fouriers equation
% it has to be done elementwise, so we get all the magnitudes
grad_mag = sqrt((q_x./k_xx).^2 + (q_y./k_yy).^2 + (q_z./k_zz).^2);

% now we display it, here,
% Rows: Phi change in X-Y plane
% Columns: Theta change in Z axis 
disp("Table of Thermal Gradient Magnitudes:");
disp(grad_mag);