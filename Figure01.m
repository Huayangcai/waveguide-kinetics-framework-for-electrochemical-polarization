function Figure01()
% -----------------------------------------------------------------
% USAGE / REPRODUCIBILITY NOTES (Figure01)
% -----------------------------------------------------------------
% Purpose:
%   Generates the manuscript figure illustrating flux-based (Scheme A)
%   two-mode waveguide kinetics (cathodic vs anodic) with:
%     - Row 1: bounded current-like proxy \tilde{j}
%     - Row 2: \rho(\tilde{\eta}) derived from forward/backward fluxes
%     - Row 3: power-flow density \Pi_{dens}(\tilde{\eta}) with optima
%
% How to run:
%   1) Ensure this file is on the MATLAB path.
%   2) In the Command Window, run:
%        Figure01
%
% Inputs:
%   None. All parameters are set in the "cfg" section near the top of
%   the main function (\tilde{\eta} range, mode parameters, and the B-family
%   sweep used to draw the gray curves).
%
% Outputs:
%   - Saves a 600-dpi PNG named "Figure01.png" to the current folder.
%   - Creates a figure window (3 x 2 tiled layout).
%
% Requirements:
%   Base MATLAB only (no toolboxes required).
%
% Notes:
%   - Deterministic: no random seeds are used.
%   - For publication, adjust fonts/line widths in the style block if needed.
% -----------------------------------------------------------------

% ===============================================================
% Figure 01 (FLUX-BASED, Scheme A) | Two-mode waveguide kinetics with lambda
% Layout: 3 x 2 (row x col)
%   Row 1:  j_A, j_B(base), j_tot(base) + grey family over B amplitudes
%   Row 2:  rho_A(eta), rho_B(eta), rho_tot(eta)   [Scheme A, flux-based]
%   Row 3:  Pi_dens(eta) for A/B/tot (baseline) on LEFT
%
% Single mode (p=A,B):
%   Jox_p  = alpha_p * exp(  xi_p      * lambda_p * eta )
%   Jred_p = alpha_p * exp( -(1-xi_p)  * lambda_p * eta )
%   U_p = Jox_p + Jred_p
%   S_p = Jox_p - Jred_p
%   beta_p = S_p / U_p = tanh(lambda_p*eta/2)   (independent of alpha, xi)
%   rho_p  = sqrt((1-|beta_p|)/(1+|beta_p|)) = exp(-|lambda_p*eta|/2)
%   j_p = S_p / sqrt(1+S_p^2)  (Row1 display only; bounded power-flow-like proxy)
%
% Two-mode (TRUE power-flow superposition for flux channel):
%   U_tot = U_A + U_B
%   S_tot = S_A + S_B
%   beta_tot = S_tot/U_tot
%   rho_tot  = rho(beta_tot)
%
% Pi (strength-weighted, FINAL CHOICE: no extra |beta| factor):
%   Pi_use  = |j~| * (1-rho^2)
%   Pi_dens = Pi_use/(|eta| + eta0)
% ===============================================================

clear; close all; clc;

%% -------------------- Style --------------------
set(groot,'DefaultTextInterpreter','latex');
set(groot,'DefaultAxesTickLabelInterpreter','latex');
set(groot,'DefaultLegendInterpreter','latex');
set(groot,'DefaultAxesFontName','Helvetica');
set(groot,'DefaultAxesFontSize',13);
set(groot,'DefaultLineLineWidth',2.0);

%% -------------------- Config --------------------
cfg = struct();
cfg.maxExp = 70;
cfg.eta0   = 0.01;
cfg.tiny   = 1e-30;

cfg.Neta = 2600;
cfg.cath_etaMin = -6;   cfg.cath_etaMax =  2;
cfg.anod_etaMin = -2;   cfg.anod_etaMax =  6;

% -------------------- Mode A (fixed) --------------------
cfg.A_cath = struct('alpha',1.0,'xi',0.35,'lambda',1.0);
cfg.A_anod = struct('alpha',1.0,'xi',0.70,'lambda',1.0);

% -------------------- Mode B families: [alpha_B, xi_B, lambda_B] --------------------
cfg.B_cath_list = [0.1 0.25 0.6;
                   0.2 0.25 0.6;
                   0.3 0.25 0.6;
                   0.4 0.25 0.6;
                   0.5 0.25 0.6];

cfg.B_anod_list = [0.1 0.75 0.6;
                   0.2 0.75 0.6;
                   0.3 0.75 0.6;
                   0.4 0.75 0.6;
                   0.5 0.75 0.6];

% Baseline (highlight)  [alpha, xi, lambda]
cfg.B_cath_base = [0.5, 0.25, 0.6];
cfg.B_anod_base = [0.5, 0.75, 0.6];

% Colors
cfg.colA    = [0 0 1];
cfg.colTot  = [0 0 0];
cfg.colFam  = [0.80 0.80 0.80];
cfg.colB_c  = [0.85 0.25 0.15];
cfg.colB_a  = [0.85 0.25 0.15];

%% -------------------- Simulate both systems --------------------
sysCath = simulate_one_system_fluxrho_lambda('Cathodic (reduction)', ...
    cfg.cath_etaMin, cfg.cath_etaMax, cfg.Neta, ...
    cfg.A_cath, +1, cfg.B_cath_list, cfg.B_cath_base, cfg);

sysAnod = simulate_one_system_fluxrho_lambda('Anodic (oxidation)', ...
    cfg.anod_etaMin, cfg.anod_etaMax, cfg.Neta, ...
    cfg.A_anod, -1, cfg.B_anod_list, cfg.B_anod_base, cfg);

%% -------------------- Figure: 3x2 --------------------
fig = figure('Color','w','Units','centimeters','Position',[2 2 26 18]);
tlo = tiledlayout(3,2,'Padding','compact','TileSpacing','compact');

plot_column_lambda(tlo, 1, sysCath, cfg, cfg.colB_c);
plot_column_lambda(tlo, 2, sysAnod, cfg, cfg.colB_a);

out = 'Figure01.png';
print(fig,'-dpng','-r600',out);
disp(['Saved: ' out]);

end

% ===============================================================
% Simulation for one system (flux-based U,S,beta,rho) WITH lambda
% ===============================================================
function sys = simulate_one_system_fluxrho_lambda(name, etaMin, etaMax, Neta, A, sigmaB, B_list, B_base, cfg)

sys = struct();
sys.name   = name;
sys.etaMin = etaMin; sys.etaMax = etaMax;
sys.sigmaB = sigmaB;
sys.A      = A;

eta = linspace(etaMin, etaMax, Neta);
sys.eta = eta(:)';

% Dominant branch (for optimum search)
if sigmaB > 0
    sys.branch = 'neg';  idxMain = (eta <= 0);
else
    sys.branch = 'pos';  idxMain = (eta >= 0);
end
sys.idxMain = idxMain;

% ---- Mode A ----
[JoxA,JredA,UA,SA,betaA,rhoA,jA] = one_mode_flux_US_beta_rho_j_lambda(eta, A.alpha, A.xi, A.lambda, cfg.maxExp);
sys.jA = jA; sys.UA = UA; sys.SA = SA;
sys.betaA = betaA; sys.rhoA = rhoA;

% ---- Mode B family (Row1 uses family totals; Row2/3 use baseline only) ----
nB = size(B_list,1);
sys.B_list = B_list;
sys.jTot_family = nan(nB, numel(eta));
sys.jB_family   = nan(nB, numel(eta));

for k = 1:nB
    alphaB = B_list(k,1);
    xiB    = B_list(k,2);
    lamB   = B_list(k,3);

    [~,~,~,~,~,~,jB] = one_mode_flux_US_beta_rho_j_lambda(eta, alphaB, xiB, lamB, cfg.maxExp);
    sys.jB_family(k,:)   = jB;
    sys.jTot_family(k,:) = jA + sigmaB*jB; % for Row-1 display (system convention)
end

% ---- Baseline B (match by [alpha, xi, lambda]) ----
idxBase = find( abs(B_list(:,1)-B_base(1))<1e-12 & ...
                abs(B_list(:,2)-B_base(2))<1e-12 & ...
                abs(B_list(:,3)-B_base(3))<1e-12, 1, 'first');
if isempty(idxBase), idxBase = 1; end
sys.idxBase = idxBase;

alphaB0 = B_list(idxBase,1);
xiB0    = B_list(idxBase,2);
lamB0   = B_list(idxBase,3);

[JoxB0,JredB0,UB0,SB0,betaB0,rhoB0,jB0] = one_mode_flux_US_beta_rho_j_lambda(eta, alphaB0, xiB0, lamB0, cfg.maxExp);

sys.B_base = struct('alpha',alphaB0,'xi',xiB0,'lambda',lamB0, ...
                    'jB',jB0,'UB',UB0,'SB',SB0,'betaB',betaB0,'rhoB',rhoB0, ...
                    'JoxB',JoxB0,'JredB',JredB0);

sys.jTot_base = sys.jTot_family(idxBase,:); % Row-1 total (system convention)

% ---- TOTAL (flux-based combination: TRUE power-flow; no sigmaB in flux channel) ----
Utot = UA + UB0;
Stot = SA + SB0;

betaT = Stot ./ max(Utot, cfg.tiny);
betaT = max(min(betaT, 1-1e-12), -1+1e-12);
rhoT  = rho_schemeA_from_beta(betaT);

sys.Utot = Utot; sys.Stot = Stot;
sys.betaT = betaT; sys.rhoT = rhoT;

% ---- Pi metrics (FINAL: Pi_use = |j~|*(1-rho^2)) ----
[sys.Pi_use_A, sys.Pi_dens_A, sys.eta_star_A] = compute_Pi_with_rho(eta, abs(jA),           rhoA,  cfg.eta0, cfg.tiny, sys.branch);
[sys.Pi_use_B, sys.Pi_dens_B, sys.eta_star_B] = compute_Pi_with_rho(eta, abs(jB0),          rhoB0, cfg.eta0, cfg.tiny, sys.branch);
[sys.Pi_use_T, sys.Pi_dens_T, sys.eta_star_T] = compute_Pi_with_rho(eta, abs(sys.jTot_base),rhoT,  cfg.eta0, cfg.tiny, sys.branch);

end

% ===============================================================
% Plot one column: Row1 j, Row2 rho, Row3 Pi_dens
% ===============================================================
function plot_column_lambda(tlo, col, sys, cfg, colB)

eta    = sys.eta;
sigmaB = sys.sigmaB;

% ---------- Row 1 ----------
ax1 = nexttile(tlo, col); hold(ax1,'on'); grid(ax1,'on'); box(ax1,'on');

for k = 1:size(sys.B_list,1)
    plot(ax1, eta, sys.jTot_family(k,:), 'Color',cfg.colFam, ...
        'LineWidth',1.0, 'HandleVisibility','off');
end

plot(ax1, eta, sys.jA, '-', 'Color',cfg.colA, ...
    'DisplayName',sprintf('$\\tilde{j}_{\\rm A}$ ($\\lambda_A=%.2g$)', sys.A.lambda));

plot(ax1, eta, sys.B_base.jB, '--', 'Color',colB, ...
    'DisplayName',sprintf('$\\tilde{j}_{\\rm B}$ (base: $\\alpha_B=%.3g,\\,\\xi_B=%.2f,\\,\\lambda_B=%.2g$)', ...
    sys.B_base.alpha, sys.B_base.xi, sys.B_base.lambda));

plot(ax1, eta, sys.jTot_base, '-', 'Color',cfg.colTot, ...
    'DisplayName',sprintf('$\\tilde{j}_{\\rm tot}$ (base, $\\sigma_B=%+d$)', sigmaB));

xline(ax1, 0, 'k-', 'LineWidth',1, 'HandleVisibility','off');
xlabel(ax1, '$\tilde{\eta}$'); ylabel(ax1, '$\tilde{j}$');

jMax = max(max(abs(sys.jTot_family),[],'all'), 1);
ylim(ax1, [-1.08*jMax, 1.08*jMax]);

if col==1
    legend(ax1, 'Location','best', 'Box','off');
else
    legend(ax1, 'off');
end
panel_label(ax1, panel_letter(col,1));

% ---------- Row 2 ----------
ax2 = nexttile(tlo, 2+col); hold(ax2,'on'); grid(ax2,'on'); box(ax2,'on');

plot(ax2, eta, sys.rhoT, '-', 'Color',cfg.colTot, 'LineWidth',1.8, 'DisplayName','$\rho_{\rm tot}$');
plot(ax2, eta, sys.rhoA, '-', 'Color',cfg.colA,   'LineWidth',2.6, 'DisplayName','$\rho_{\rm A}$');
plot(ax2, eta, sys.B_base.rhoB, '--','Color',colB,'LineWidth',2.6, 'DisplayName','$\rho_{\rm B}$');

xline(ax2, 0, 'k-', 'LineWidth',1, 'HandleVisibility','off');
ylim(ax2, [0 1]);
xlabel(ax2, '$\tilde{\eta}$'); ylabel(ax2, '$\rho$');

if col==1
    legend(ax2, 'Location','northwest', 'Box','off');
else
    legend(ax2, 'off');
end
panel_label(ax2, panel_letter(col,2));

% ---------- Row 3 ----------
ax3 = nexttile(tlo, 4+col); hold(ax3,'on'); grid(ax3,'on'); box(ax3,'on');

plot(ax3, eta, max(sys.Pi_dens_A, cfg.tiny), '-',  'Color',cfg.colA,   'DisplayName','$\Pi_{\rm dens,A}$');
plot(ax3, eta, max(sys.Pi_dens_B, cfg.tiny), '--', 'Color',colB,       'DisplayName','$\Pi_{\rm dens,B}$');
plot(ax3, eta, max(sys.Pi_dens_T, cfg.tiny), '-',  'Color',cfg.colTot, 'DisplayName','$\Pi_{\rm dens,tot}$');

mark_opt(ax3, eta, sys.Pi_dens_A, sys.eta_star_A, 'o');
mark_opt(ax3, eta, sys.Pi_dens_B, sys.eta_star_B, 's');
mark_opt(ax3, eta, sys.Pi_dens_T, sys.eta_star_T, 'd');

xline(ax3, 0, 'k-', 'LineWidth',1, 'HandleVisibility','off');
xlabel(ax3, '$\tilde{\eta}$'); ylabel(ax3, '$\Pi_{\rm dens}$');

if col==1
    legend1=legend(ax3, 'Location','best', 'Box','off');
    set(legend1,...
    'Position',[0.0743318331578751 0.217115186025404 0.098276837882349 0.0930147058823529]);
else
    legend(ax3, 'off');
end
panel_label(ax3, panel_letter(col,3));

end

% ===============================================================
% Single-mode WITH lambda: UNSAT fluxes -> U,S -> beta -> rho + bounded j
% ===============================================================
function [Jox, Jred, U, S, beta, rho, j] = one_mode_flux_US_beta_rho_j_lambda(eta, alpha, xi, lambda, maxExp)

a =  xi      * lambda;
b = -(1 - xi)* lambda;

Jox  = alpha .* exp( clip_local(a .* eta, maxExp) );
Jred = alpha .* exp( clip_local(b .* eta, maxExp) );

U = Jox + Jred;
S = Jox - Jred;

eps0 = 1e-30;
beta = S ./ (U + eps0);
beta = max(min(beta, 1-1e-12), -1+1e-12);
rho  = rho_schemeA_from_beta(beta);

% bounded power-flow-like display variable (Row 1 + Pi strength)
j = S ./ sqrt(1 + S.^2);

end

function rho = rho_schemeA_from_beta(beta)
beta = max(min(beta, 1-1e-12), -1+1e-12);
ab = abs(beta);
rho = sqrt( max(0, (1 - ab) ./ (1 + ab)) );
rho(~isfinite(rho)) = 0;
rho = min(max(rho,0),1);
end

function y = clip_local(y, maxExp)
y = max(min(y, maxExp), -maxExp);
end

% ===============================================================
% Pi metrics (FINAL CHOICE):
%   Pi_use  = |j~| * (1-rho^2)
%   Pi_dens = Pi_use/(|eta|+eta0)
% optimum restricted to dominant branch
% ===============================================================
function [Pi_use, Pi_dens, eta_star] = compute_Pi_with_rho(eta, jAbs, rho, eta0, tiny, branch)

jAbs   = max(jAbs, 0);
Pi_use = jAbs .* max(1 - rho.^2, 0);

den     = max(abs(eta) + eta0, tiny);
Pi_dens = Pi_use ./ den;

if strcmp(branch,'neg')
    mask = (eta < 0);
else
    mask = (eta > 0);
end
tmp = Pi_dens;
tmp(~mask) = -Inf;
[~,k] = max(tmp);
eta_star = eta(k);

end

function mark_opt(ax, eta, Pi_dens, eta_star, marker)
y = interp1(eta, Pi_dens, eta_star, 'linear', 'extrap');
plot(ax, eta_star, max(y,1e-30), marker, 'MarkerSize',7, ...
    'MarkerFaceColor','w', 'MarkerEdgeColor','k', 'HandleVisibility','off');
end

% ===============================================================
% Panel letters: (A)-(F)
% ===============================================================
function L = panel_letter(colIdx, rowIdx)
letters = {'A','B'; 'C','D'; 'E','F'};
L = letters{rowIdx, colIdx};
end

function panel_label(ax, letter)
text(ax, -0.14, 0.98, letter, 'Units','normalized', ...
    'FontSize',16, 'FontWeight','bold', 'FontName','Helvetica', ...
    'Interpreter','none', 'HorizontalAlignment','left', ...
    'VerticalAlignment','top', 'Color','k');
end
