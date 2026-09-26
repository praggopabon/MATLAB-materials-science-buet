% Steady-state temperature field inside a laser-heated cylindrical rod 
% obtained with a 2D Finite Difference Method (FDM) solver.

% Physical Setup:
% Rod geometry: radius Rrod, length Lrod
% A laser hits the z=0 face: total optical power Ppow, focused onto a spot 
% of radius sspot (sspot <= Rrod). The far end z=Lrod is clamped at ambient 
% temperature Tamb. Convective cooling with coefficient hconv and ambient
% temperature Tamb happens on: 
% a. the outer curved surface r = Rrod
% b. the front face z = 0, but only outside the laser spot, 
% i.e. for r > sspot

% non-dimentional variables:
% (rr = r/Rrod, zz = z/Lrod, TT = T/Tamb):
% governing pde (dimensionless form):
% (1/rr)*d/drr(rr*dTT/drr) + shapeRatio^2*d^2TT/dzz^2 = 0
% valid over 0<=rr<=1, 0<=zz<=1

% boundary condition:
% (five conditions total: two along r, two along z, plus the symmetry 
% condition at the axis):

% (BC1) zz=0, rr<=spotFrac:
% dTT/dzz = -powNum/spotFrac^2
% [heat flux delivered by the laser]

% (BC2) zz=0, rr>spotFrac:
% dT/dzz = (biotNum/shapeRatio)*(TT-1)
% [convective loss on the un-lit part of the face]

% (BC3) zz=1:
% TT = 1 (pinned at ambient temperature)
% [Dirichlet condition at the cold base]

% (BC4) rr=0:
% dTT/drr = 0 [axial symmetry, i.e. no radial flux through the centerline]

% (BC5) rr=1:
% dTT/drr = -biotNum*(TT-1)
% [Robin condition — convective loss on the lateral surface]

% Dimensionless group origins:
% shapeRatio = Rrod/Lrod
% geometric aspect ratio [0, +inf]
% spotFrac= sspot/Rrod
% fraction of the face lit by the laser spot [0,1]
% biotNum = hconv*Rrod/kcond
% Biot number[0, +inf]
% powNum= Ppow*Lrod/(kcond*Tamb*pi*Rrod^2)
% dimensionless laser power[0, +inf]

% Boundary Condition derivation:
% BC1:-kcond*dT/dz|z=0 =Ppow/(pi*sspot^2)
% or, dTT/dzz = -Ppow*Lrod/(kcond*Tamb*pi*sspot^2)
% =-[Ppow*Lrod/(kcond*Tamb*pi*Rrod^2)]/(sspot/Rrod)^2 =-powNum/spotFrac^2

% BC2:kcond*dT/dz|z=0 = hconv*(T-Tamb)   [for r>sspot]
% or, dTT/dzz = hconv*Lrod/kcond * (TT-1)
% =(biotNum/shapeRatio)*(TT-1)

% BC5:-kcond*dT/dr|r=Rrod = hconv*(T-Tamb)
% or, dTT/drr|rr=1 = -(hconv*Rrod/kcond)*(TT-1) = -biotNum*(TT-1)

% dTT/dzz is discontinuous at zz=0, 
% right at the laser-spot edge rr = spotFrac.

% FDM scheme building:
% 1. a uniform mesh is used:
% rr_i = (i-1)/(Nrad-1), zz_j = (j-1)/(Nax-1)
% 2. interior nodes use central differences along both rr and zz
% at rr=0, an L'Hopital limit combined with a ghost node 
% (T_{0,j} = T_{2,j}) removes the singularity
% Neumann/Robin edges use first-order one-sided differences
% everything is assembled into a sparse linear system  
% Amat*Tflat = bvec  and solved directly

% figures produced:
% Case 1: sweep shapeRatio = Rrod/Lrod  over 5 levels
% Case 2: sweep spotFrac   = sspot/Rrod over 5 levels
% Case 3: sweep biotNum    = hconv*Rrod/kcond over 5 levels
% Case 4: sweep powNum     over 5 levels
% Each of Cases 1-4 is laid out as a 2x3 grid: five contour maps
% (one per swept value) plus a sixth "trend" subplot tracking how
% the max / average / standard-deviation of the temperature rise
% (T'-1) change as the swept parameter moves, plotted on a log-x
% axis since the sweeps span more than one order of magnitude.

clear; clc; close all;

% grid points along rr (rr in [0,1]), along zz (zz in [0,1])
nRadPts = 121; nAxPts = 121;   

% __________________________CASE 0_________________________________________
% BASELINE RUN: every dimensionless number = 1
% Reminder: spotFrac = 1 means the laser spot covers the whole front face 
% (the beam radius equals the rod radius). Per the assignment, we first run
% everything at 1 and plot that case on its own before sweeping.

fprintf('Solving Case 0 (baseline, all parameters = 1)...\n');
paramsBase = struct('shapeRatio',1, 'spotFrac',1, 'biotNum',1, 'powNum',1);
Tbase = solveRodTemperature(paramsBase, nRadPts, nAxPts);

% ______________________CASE 1_____________________________________________
% sweep shapeRatio = Rrod/Lrod (the aspect ratio), 5 levels spanning
% below and above 1. Everything else stays fixed at 1: spotFrac=1, 
% biotNum=1, powNum=1.

fprintf('Solving Case 1 (sweeping shapeRatio, 5 levels)...\n');
shapeRatioList = [0.25, 0.5, 1, 2, 4];
runSweepCase(2, paramsBase, 'shapeRatio', '\alpha', shapeRatioList, ...
    '\beta=1, Bi=1, \Phi=1', nRadPts, nAxPts);

% _________________________CASE 2__________________________________________
% sweep spotFrac = sspot/Rrod (laser spot fraction), 5 levels from a
% small spot down to full coverage. Everything else stays fixed at 1: 
% shapeRatio=1, biotNum=1, powNum=1. This is the case where the 
% discontinuity in dTT/dzz at zz=0, rr=spotFrac, becomes visible.

fprintf('Solving Case 2 (sweeping spotFrac, 5 levels)...\n');
spotFracList = [1, 0.75, 0.5, 0.25, 0.1];
runSweepCase(3, paramsBase, 'spotFrac', '\beta', spotFracList, ...
    '\alpha=1, Bi=1, \Phi=1', nRadPts, nAxPts);

% ____________________________CASE 3_______________________________________
% sweep biotNum = hconv*Rrod/kcond (the Biot number), 5 levels spanning
% conduction-dominated to convection-dominated regimes. Everything else 
% stays fixed at 1: shapeRatio=1, spotFrac=1, powNum=1.

fprintf('Solving Case 3 (sweeping biotNum, 5 levels)...\n');
biotNumList = [0.05, 0.5, 1, 5, 50];
runSweepCase(4, paramsBase, 'biotNum', 'Bi', biotNumList, ...
    '\alpha=1, \beta=1, \Phi=1', nRadPts, nAxPts);

% __________________________CASE 4________________________________________
% sweep powNum = Ppow*Lrod/(kcond*Tamb*pi*Rrod^2), 5 levels spanning low
% power input to high power input. Everything else stays fixed at 1: 
% shapeRatio=1, spotFrac=1, biotNum=1.

fprintf('Solving Case 4 (sweeping powNum, 5 levels)...\n');
powNumList = [0.2, 1, 5, 20, 100];
runSweepCase(5, paramsBase, 'powNum', '\Phi', powNumList, ...
    '\alpha=1, \beta=1, Bi=1', nRadPts, nAxPts);

fprintf('All cases have been solved and plotted.\n');

%_______Main Solver Function_______________________________________________
% this builds the sparse finite-difference linear
% system and solves it for the steady-state dimensionless temperature field.

function Tgrid = solveRodTemperature(params, nRadPts, nAxPts)
% this solves for the dimensionless 2D cylindrical Laplace-type equation 
% described above.

% INPUTS:
% params -struct holding the dimensionless numbers:
% .shapeRatio(Rrod/Lrod) .spotFrac (sspot/Rrod)
% .biotNum (hconv*Rrod/kcond) .powNum (Ppow*Lrod/(kcond*Tamb*pi*Rrod^2))
% nRadPts - number of grid points along rr (rr in [0,1])
% nAxPts- number of grid points along zz (zz in [0,1])

% OUTPUT:
% Tgrid-[nRadPts x nAxPts] array holding TT(rr_i, zz_j), where i indexes 
% the radial direction and j indexes the axial direction
% flat indexing: flatIdx = (j-1)*nRadPts + i
% rr_i = (i-1)/(nRadPts-1), zz_j = (j-1)/(nAxPts-1)

shapeRatio = params.shapeRatio;
% Clamp spotFrac away from zero so that dividing by
% spotFrac^2 in BC1 never blows up numerically.
spotFrac = max(params.spotFrac, 1e-12);
biotNum  = params.biotNum;
powNum   = params.powNum;

% grid spacing along each direction
drStep = 1 / (nRadPts - 1);
dzStep = 1 / (nAxPts  - 1);
radialNodes = linspace(0, 1, nRadPts)';   % rr grid vector

% total number of unknowns, plus a helper that maps a
% (radial index, axial index) pair onto a flat index
totalUnknowns = nRadPts * nAxPts;
flatIndex = @(ii, jj) (jj - 1) * nRadPts + ii;
Amat = sparse(totalUnknowns, totalUnknowns);
bvec = zeros(totalUnknowns, 1);

for axIdx = 1:nAxPts
    for radIdx = 1:nRadPts

        thisRow = flatIndex(radIdx, axIdx);
        % dimensionless radial position of this node
        rHere = radialNodes(radIdx);

        % boundary: zz=1 (DIRICHLET, TT=1)
        % This one always wins if it applies, since a fixed-temperature 
        % condition takes priority over everything else.

        if axIdx == nAxPts
            Amat(thisRow, thisRow) = 1; bvec(thisRow) = 1;

        % boundary: zz=0 (two-region Neumann/Robin mix)
        % There's a discontinuity in the BC right at rr = spotFrac:
        % inside the laser spot (rr<=spotFrac): a prescribed heat flux
        % outside the laser spot (rr>spotFrac): convective loss at the 
        % front face

        elseif axIdx == 1
            if rHere <= spotFrac
                % LASER-HEATED ZONE (BC1)
                % Physical form: -kcond*dT/dz|z=0 = Ppow/(pi*sspot^2)
                % Dimensionless form: dTT/dzz = -powNum/spotFrac^2
                % Forward-difference approximation:
                % (T_{i,2}-T_{i,1})/dzStep = -powNum/spotFrac^2
                Amat(thisRow, flatIndex(radIdx,1)) = -1/dzStep;
                Amat(thisRow, flatIndex(radIdx,2)) =  1/dzStep;
                bvec(thisRow) = -powNum / spotFrac^2;

            else
                % CONVECTIVE FRONT FACE (BC2) 
                % Physical form: kcond*dT/dz|z=0 = hconv*(T-Tamb),
                % for r>sspot
                % Dimensionless form:dTT/dzz = (biotNum/shapeRatio)*(TT-1)
                % Forward-difference approximation:T_{i,2}-T_{i,1})/dzStep
                % =(biotNum/shapeRatio)*(T_{i,1}-1)
                Amat(thisRow, flatIndex(radIdx,1)) = ...
                    -1/dzStep - biotNum/shapeRatio;
                Amat(thisRow, flatIndex(radIdx,2)) =  1/dzStep;
                bvec(thisRow) = -biotNum / shapeRatio;
            end

        % boundary: rr=1 (ROBIN — lateral convection, BC5)
        % Physical form: -kcond*dT/dr|r=Rrod = hconv*(T(Rrod,z)-Tamb)
        % Dimensionless form:dTT/drr|rr=1 = -biotNum*(TT-1)
        % Backward-difference approximation: 
        % (T_{Nrad,j}-T_{Nrad-1,j})/drStep = -biotNum*(T_{Nrad,j}-1)
        % which rearranges to:
        % T_{Nrad,j}*(1/drStep + biotNum)
        % - T_{Nrad-1,j}*(1/drStep) = biotNum

        elseif radIdx == nRadPts
            Amat(thisRow, flatIndex(nRadPts,   axIdx)) = ...
                1/drStep + biotNum;
            Amat(thisRow, flatIndex(nRadPts-1, axIdx)) = ...
                -1/drStep;
            bvec(thisRow) = biotNum;

        % boundary: rr=0 (SYMMETRY, L'Hopital limit, BC4)
        % Physically, dTT/drr = 0 at rr=0 because there is no radial flux 
        % through the centerline. As rr -> 0, the term 
        % (1/rr)*d/drr(rr*dTT/drr) approaches 2*d^2TT/drr^2 by L'Hopital's
        % rule, using dTT/drr = 0 at rr = 0.
        % We use a ghost node: T_{0,j} = T_{2,j}, so
        % d^2TT/drr^2|_{rr=0}
        % = (T_{0,j}-2T_{1,j}+T_{2,j}) / drStep^2
        % = 2*(T_{2,j}-T_{1,j}) / drStep^2
        % and therefore, 2*d^2TT/drr^2 = 4*(T_{2,j}-T_{1,j}) / drStep^2
        % Full discretized equation at rr=0:
        % 4*(T_{2,j}-T_{1,j})/drStep^2+shapeRatio^2*(T_{1,j+1}-2*T_{1,j}
        % + T_{1,j-1})/dzStep^2 = 0

        elseif radIdx == 1
            Amat(thisRow, flatIndex(1, axIdx  )) = ...
                -4/drStep^2 - 2*shapeRatio^2/dzStep^2;
            Amat(thisRow, flatIndex(2, axIdx  )) = 4/drStep^2;
            Amat(thisRow, flatIndex(1, axIdx+1)) = shapeRatio^2/dzStep^2;
            Amat(thisRow, flatIndex(1, axIdx-1)) = shapeRatio^2/dzStep^2;

        % interior nodes:
        % PDE:
        % d^2TT/drr^2 + (1/rr)*dTT/drr + shapeRatio^2 * d^2TT/dzz^2 = 0
        % Central-difference approximation in both directions:
        % (T_{i+1,j}-2T_{i,j}+T_{i-1,j})/drStep^2+(T_{i+1,j}-T_{i-1,j})/
        % (2*rHere*drStep)+shapeRatio^2*(T_{i,j+1}-2T_{i,j}+T_{i,j-1}) 
        % / dzStep^2 = 0
        else
            Amat(thisRow, flatIndex(radIdx,   axIdx)) = ...
                -2/drStep^2 - 2*shapeRatio^2/dzStep^2;
            Amat(thisRow, flatIndex(radIdx+1, axIdx)) = ...
                1/drStep^2 + 1/(2*rHere*drStep);
              Amat(thisRow, flatIndex(radIdx-1, axIdx)) = ...
                1/drStep^2 - 1/(2*rHere*drStep);
            Amat(thisRow, flatIndex(radIdx, axIdx+1)) = ...
                shapeRatio^2/dzStep^2;
            Amat(thisRow, flatIndex(radIdx, axIdx-1)) = ...
                shapeRatio^2/dzStep^2;
        end
    end
end

% solve the sparse linear system directly 
Tflat = Amat \ bvec; Tgrid = reshape(Tflat, nRadPts, nAxPts);
end


%________________Sweep / Trend Driver Function_____________________________

function runSweepCase(figNum, baseParams, sweepField, sweepSymbol, ...
        sweepValues, fixedLabelStr, nRadPts, nAxPts)
% runSweepCase Solves the rod temperature field at each value in
% sweepValues (varying only the field named by sweepField, holding every
% other parameter at whatever baseParams already specifies), then lays
% the results out as a 2x3 grid: one contour map per swept value, plus a
% sixth "trend" subplot tracking max/avg/std of the temperature rise
% T'-1 against the swept parameter on a log-x axis.
%
% INPUTS:
%   figNum        - figure number to draw into
%   baseParams    - struct of dimensionless numbers; every field except
%                   sweepField is held fixed at its value here
%   sweepField    - name of the struct field being varied, e.g.
%                   'shapeRatio', 'spotFrac', 'biotNum', or 'powNum'
%   sweepSymbol   - LaTeX-ish label used in subplot/axis titles,
%                   e.g. '\alpha', '\beta', 'Bi', '\Phi'
%   sweepValues   - row/column vector of at least 5 values to sweep
%   fixedLabelStr - string describing the parameters held fixed,
%                   shown in the overall figure title
%   nRadPts, nAxPts - grid resolution passed through to the solver

numLevels = numel(sweepValues);

maxRiseVals = zeros(1, numLevels);
avgRiseVals = zeros(1, numLevels);
stdRiseVals = zeros(1, numLevels);

figure(figNum);
colormap(hot);

for lvlIdx = 1:numLevels

    paramsNow = baseParams;
    paramsNow.(sweepField) = sweepValues(lvlIdx);
    Tnow = solveRodTemperature(paramsNow, nRadPts, nAxPts);

      subplot(2, 3, lvlIdx);
    plotTempContour(Tnow, paramsNow);
    title(sprintf('%s = %.3g', sweepSymbol, sweepValues(lvlIdx)), ...
        'FontSize',9);

    [maxRiseVals(lvlIdx), avgRiseVals(lvlIdx), stdRiseVals(lvlIdx)] = ...
        computeRiseStats(Tnow);
end

% sixth panel: how the temperature rise above ambient trends as the
% swept parameter changes, shown on a log-x axis since these sweeps
% typically span more than one order of magnitude
subplot(2, 3, 6);
plotRiseTrend(sweepValues, maxRiseVals, avgRiseVals, stdRiseVals, ...
    sweepSymbol);

sgtitle(sprintf("T'/T_0  —  sweeping %s   (fixed: %s)", ...
    sweepSymbol, fixedLabelStr), 'FontSize',12,'FontWeight','bold');
end


function [maxRise, avgRise, stdRise] = computeRiseStats(Tgrid)
%computeRiseStats Summarizes the temperature rise above ambient,
%T'-1, over the full solved grid as a max, mean, and standard
%deviation, used to populate the trend subplot in runSweepCase.
riseField = Tgrid - 1;
maxRise = max(riseField(:));
avgRise = mean(riseField(:));
  stdRise = std(riseField(:));
end


function plotRiseTrend(sweepValues, maxVals, avgVals, stdVals, sweepSymbol)
%plotRiseTrend Draws the max/avg/std trend lines of T'-1 against the
%swept parameter on the current axes, using a log-x scale.
semilogx(sweepValues, maxVals, '-o', ...
         sweepValues, avgVals, '-s', ...
         sweepValues, stdVals, '-^', 'LineWidth', 1.2);
grid on;
legend('max','avg','std', 'Location','best');
xlabel(sweepSymbol, 'FontSize',10);
ylabel("T' - 1", 'FontSize',10);
title('Trend: rise above ambient', 'FontSize',9);
end


%________________Plotting Helper Function_________________________________

function plotTempSurface(Tgrid)
% plotTempSurface Draws a 3D surface of TT(rr,zz) on the current axes.
nRadPts = size(Tgrid,1); nAxPts  = size(Tgrid,2);
[axZ, axR] = meshgrid(linspace(0,1,nAxPts), linspace(0,1,nRadPts));
surf(axZ, axR, Tgrid, 'EdgeColor','none');
shading interp; colorbar; view(135, 30);
xlabel("z' = z/L",  'FontSize',10); ylabel("r' = r/R",  'FontSize',10);
zlabel("T' = T/T_0",'FontSize',10);
end

function plotTempContour(Tgrid, params)
% Filled contour plot of TT(rr,zz), with a dashed marker showing where the 
% laser-spot boundary sits (only drawn when spotFrac < 1).
nRadPts = size(Tgrid,1); nAxPts  = size(Tgrid,2);
radVec = linspace(0,1,nRadPts); axVec  = linspace(0,1,nAxPts);
[axZ, axR] = meshgrid(axVec, radVec);

contourf(axZ, axR, Tgrid, 25, 'LineColor','none');
hold on;
contour(axZ, axR, Tgrid, 25, 'LineColor','k', 'LineWidth',0.2);

% only draw the laser-spot boundary line if the spot
% doesn't already cover the whole face
if params.spotFrac < 1.0 - 1e-6
    yline(params.spotFrac, '--w', 'LineWidth', 2.0, ...
        'Label', [' \beta = ', sprintf('%.1f',params.spotFrac)], ...
        'LabelVerticalAlignment','bottom', 'FontSize', 9);
end
hold off; colorbar;
xlabel("z' = z/L", 'FontSize',10); ylabel("r' = r/R", 'FontSize',10);
end