function Figure02(matFiles, outPng)
% -----------------------------------------------------------------
% USAGE / REPRODUCIBILITY NOTES (Figure02)
% -----------------------------------------------------------------
% Purpose:
%   Reads multiple saved .mat result files and assembles ONE summary figure
%   (default: 4 rows x 2 columns). Each row corresponds to one dataset/file:
%     - Left panel:  raw data + stored fit curve(s) (no refitting)
%     - Right panel: \Pi_{dens}(\tilde{\eta}) vs \tilde{\eta} with optimum markers
%
% How to run (examples):
%   - Use defaults (expects Figure_data01.mat ... Figure_data04.mat in pwd):
%       Figure02
%   - Specify input files and output name:
%       files = {'Figure_data01.mat','Figure_data02.mat','Figure_data03.mat','Figure_data04.mat'};
%       Figure02(files, 'Figure02_summary.png');
%
% Inputs:
%   matFiles (cellstr, optional):
%       List of .mat files to load. If omitted, defaults are used.
%   outPng (char/string, optional):
%       Output PNG filename. If omitted, a default name is used.
%
% Expected .mat contents:
%   Each file should contain a struct named OUT with (minimum) fields:
%     OUT.RES : array of groups with raw vectors RES(g).eta and RES(g).j
%     OUT.D   : cell array of per-group plotted results, typically containing:
%               etaFine, jFit, eta_t, Pi_dens_t, (optional) etaStar_t, PiStar_t
%   Optional fields used for styling/labels include OUT.colors, OUT.opt, OUT.tag,
%   and OUT.etaTgrid. The code will error if OUT.RES or OUT.D is missing.
%
% Outputs:
%   - Saves the assembled figure as a 600-dpi PNG (outPng).
%   - Creates a figure window (tiled layout) for inspection.
%
% Requirements:
%   Base MATLAB only (no toolboxes required).
% -----------------------------------------------------------------

% Read 4 saved MAT files sequentially and generate ONE big summary figure (4x2).
% Each MAT file contributes ONE ROW with two panels:
%   (1) raw data + stored fit (no refit)
%   (2) Pi_dens vs eta_t + optimum markers (no refit)

clc;
close all;

if nargin < 1 || isempty(matFiles)
    matFiles = { ...
        'Figure_data01.mat', 'Figure_data02.mat', ...
        'Figure_data03.mat', 'Figure_data04.mat'  ...
    };
end

if nargin < 2 || isempty(outPng)
    outPng = 'Figure 02.png';
end

% normalize input
if isstring(matFiles), matFiles = cellstr(matFiles); end
if ischar(matFiles),   matFiles = {matFiles}; end

nF = numel(matFiles);

% layout (one file per row)
nRow = 4; nCol = 2;
if nF ~= nRow
    error('Need exactly %d MAT files for a %dx%d layout (one file per row). Current: %d files.', ...
        nRow, nRow, nCol, nF);
end

% ===== legend labels per ROW (file) =====
legendLabels = cell(4,1);
legendLabels{1} = {'pH=1', 'pH=2', 'pH=2.5', 'pH=3', 'pH=5', 'pH=9', 'pH=10', 'pH=11', 'pH=12', 'pH=13'};
legendLabels{2} = {'Pt-Ru/RuO$_2$', 'Pt/C', 'Ru/C', 'Ru/RuO$_2$', 'RuO$_2$'};
legendLabels{3} = {'Pt/C (pH=13.0)', 'Pt/cage (pH=13.0)', 'Pt/C (pH=1.1)', 'Pt/Cage (pH=1.1)'};
legendLabels{4} = {'NiCuCr/C', 'Pt/C', 'NiCu/C', 'NiCr/C', 'Ni/C'};

% ---------------- global style ----------------
set(groot,'DefaultTextInterpreter','latex');
set(groot,'DefaultAxesTickLabelInterpreter','latex');
set(groot,'DefaultLegendInterpreter','none');   % avoid '_' as subscript
set(groot,'DefaultAxesFontName','Helvetica');
set(groot,'DefaultAxesFontSize',12);
set(groot,'DefaultLineLineWidth',1.8);

fig = figure('Color','w','Units','centimeters','Position',[2 2 23 28]);
tlo = tiledlayout(fig, nRow, nCol, 'Padding','compact', 'TileSpacing','compact');

letters = char('A' + (0:(nRow*nCol-1)));  % A..H

% ====== legend visibility rules requested ======
legendLeftPanels  = ['E','G'];  % first column: only E, G
legendRightPanels = ['B','D'];  % second column: only B, D

for i = 1:nF
    filei = resolve_mat_path(matFiles{i});

    S = load(filei);
    if ~isfield(S,'OUT')
        error('MAT file %s does not contain variable OUT.', filei);
    end
    OUT = S.OUT;

    % required fields
    if ~isfield(OUT,'RES') || ~isfield(OUT,'D')
        error('OUT in %s must contain fields OUT.RES and OUT.D.', filei);
    end
    RES = OUT.RES;
    D   = OUT.D;

    % ensure D is cell
    if isstruct(D), D = num2cell(D); end
    if ~iscell(D)
        error('OUT.D in %s must be a cell array (or struct array convertible to cell).', filei);
    end

    % optional fields
    if isfield(OUT,'colors') && ~isempty(OUT.colors)
        C = OUT.colors;
    else
        C = lines(numel(D));
    end
    if isfield(OUT,'opt'), opt = OUT.opt; else, opt = struct(); end
    if isfield(OUT,'etaTgrid'), etaTgrid = OUT.etaTgrid; else, etaTgrid = []; end

    nG = numel(D);
    dsName = dataset_name_from_out(OUT, filei, i);

    % row legend labels
    rowLabs = legendLabels{i};
    if numel(rowLabs) < nG
        warning('Row %d: legend labels (%d) < groups (%d). Extra groups will be labeled as Group k.', ...
            i, numel(rowLabs), nG);
    elseif numel(rowLabs) > nG
        rowLabs = rowLabs(1:nG);
    end

    % --- tile indices (row-major) ---
    k1 = 2*(i-1) + 1;   % raw+fit  -> A,C,E,G
    k2 = k1 + 1;        % Pi_dens  -> B,D,F,H

    % ===================== (k1) raw + stored fit =====================
    ax1 = nexttile(tlo, k1); hold(ax1,'on'); box(ax1,'on'); grid(ax1,'on');

    hFit = gobjects(nG,1);   % handles for legend (fit curves)

    for g = 1:nG
        if g <= numel(RES) && isfield(RES(g),'eta') && isfield(RES(g),'j')
            eta = RES(g).eta(:); j = RES(g).j(:);
            ok = isfinite(eta) & isfinite(j);
            eta = eta(ok); j = j(ok);

            scatter(ax1, eta, j, 8, 'MarkerEdgeColor','k','MarkerFaceColor','k', ...
                'MarkerFaceAlpha',0.25,'MarkerEdgeAlpha',0.25,'HandleVisibility','off');
        end

        if isfield(D{g},'etaFine') && isfield(D{g},'jFit')
            ef = D{g}.etaFine(:);
            jf = D{g}.jFit(:);
            okf = isfinite(ef) & isfinite(jf);

            hFit(g) = plot(ax1, ef(okf), jf(okf), '-', ...
                'Color', C(min(g,size(C,1)),:), 'LineWidth',1.8, ...
                'DisplayName', pick_label(rowLabs, g));
        end
    end

    xline(ax1,0,'k-','HandleVisibility','off');
    yline(ax1,0,'k-','HandleVisibility','off');
    xlabel(ax1,'$\eta$ (V)');
    ylabel(ax1,'$j$ (mA cm$^{-2}$)');

    if isfield(opt,'fixedEtaWindow') && numel(opt.fixedEtaWindow)==2 && all(isfinite(opt.fixedEtaWindow))
        xlim(ax1, [opt.fixedEtaWindow(1), opt.fixedEtaWindow(2)]);
    else
        xlim(ax1, xlim_fallback_from_RES(RES));
    end

    panel_letter_local(ax1, letters(k1));
    % row_label_local(ax1, dsName);

    % ---- LEFT legend: ONLY for E and G ----
    if any(letters(k1) == legendLeftPanels)
        okH = isgraphics(hFit);
        hFit = hFit(okH);
        if ~isempty(hFit)
            ncol = 1;
            if numel(hFit) >= 6, ncol = 2; end
            lg = legend(ax1, hFit, 'Location','southeast', 'Box','off', 'NumColumns',ncol);
            lg.FontSize = 12;
            lg.Interpreter = 'latex';
        end
    end

    % ===================== (k2) Pi_dens + optimum =====================
    ax2 = nexttile(tlo, k2); hold(ax2,'on'); box(ax2,'on'); grid(ax2,'on');

    hPi = gobjects(nG,1);

    for g = 1:nG
        if ~isfield(D{g},'eta_t') || ~isfield(D{g},'Pi_dens_t')
            continue;
        end

        x = D{g}.eta_t(:);
        z = D{g}.Pi_dens_t(:);

        ok = isfinite(x) & isfinite(z) & (z > 0);
        hPi(g) = plot(ax2, x(ok), z(ok), '-', ...
            'Color', C(min(g,size(C,1)),:), 'LineWidth',1.8, ...
            'DisplayName', pick_label(rowLabs, g));

        if isfield(D{g},'etaStar_t') && isfield(D{g},'PiStar_t') ...
                && isfinite(D{g}.etaStar_t) && isfinite(D{g}.PiStar_t) && D{g}.PiStar_t > 0
            plot(ax2, D{g}.etaStar_t, D{g}.PiStar_t, 'o', 'MarkerSize',5.5, ...
                'MarkerFaceColor', C(min(g,size(C,1)),:), 'MarkerEdgeColor','k', ...
                'LineWidth',0.9, 'HandleVisibility','off');
        end
    end

    xlabel(ax2,'$\tilde{\eta}$');
    ylabel(ax2,'$\Pi_{\mathrm{dens}}(\tilde{\eta})$');

    if ~isempty(etaTgrid) && numel(etaTgrid) >= 2 && all(isfinite(etaTgrid([1 end])))
        xlim(ax2, [etaTgrid(1), etaTgrid(end)]);
    else
        xlim(ax2, xlim_fallback_from_D(D));
    end

    yl = ylim(ax2);
    if all(isfinite(yl)) && yl(1) > 0 && yl(2)/yl(1) > 1e3
        set(ax2,'YScale','log');
    end

    panel_letter_local(ax2, letters(k2));

    % ---- RIGHT legend: ONLY for B and D; B->east, D->northwest ----
    if any(letters(k2) == legendRightPanels)
        okH = isgraphics(hPi);
        hPi = hPi(okH);
        if ~isempty(hPi)
            ncol = 1;
            if numel(hPi) >= 6, ncol = 2; end

            if letters(k2) == 'B'
                loc = 'east';
                FZ = 8.5;
            else % 'D'
                loc = 'northwest';
                FZ = 12;
            end

            lg2 = legend(ax2, hPi, 'Location',loc, 'Box','off', 'NumColumns',ncol,...
                'FontSize',FZ);
           
            lg2.Interpreter = 'latex';
        end
    end
end

print(fig, '-dpng', '-r600', outPng);
disp(['Saved: ' outPng]);

end

% ---------------- helpers ----------------
function filei = resolve_mat_path(filei)
if exist(filei,'file'), return; end
cand = fullfile(pwd, filei);
if exist(cand,'file'), filei = cand; return; end
try
    scriptDir = fileparts(mfilename('fullpath'));
    cand = fullfile(scriptDir, filei);
    if exist(cand,'file'), filei = cand; return; end
end
cand = fullfile('/mnt/data', filei);
if exist(cand,'file'), filei = cand; return; end
error('Cannot find MAT file: %s (tried current dir / script dir / /mnt/data).', filei);
end

function panel_letter_local(ax, letter)
text(ax, -0.12, 0.98, letter, 'Units','normalized', 'FontSize',14, 'FontWeight','bold', ...
    'FontName','Helvetica', 'Interpreter','none', 'HorizontalAlignment','left', 'VerticalAlignment','top');
end

function name = dataset_name_from_out(OUT, matFile, idx)
name = '';
if isfield(OUT,'tag') && ~isempty(OUT.tag), name = OUT.tag; end
if isempty(name) && isfield(OUT,'opt') && isfield(OUT.opt,'panel') && ~isempty(OUT.opt.panel)
    name = sprintf('panel %s', string(OUT.opt.panel));
end
if isempty(name)
    [~,stem,~] = fileparts(matFile);
    name = stem;
end
name = sprintf('Row %d: %s', idx, char(name));
end

function xl = xlim_fallback_from_RES(RES)
allEta = [];
for g = 1:numel(RES)
    if isfield(RES(g),'eta')
        v = RES(g).eta(:);
        v = v(isfinite(v));
        allEta = [allEta; v]; %#ok<AGROW>
    end
end
if isempty(allEta)
    xl = [-0.2 0.2];
else
    lo = prctile(allEta, 1);
    hi = prctile(allEta, 99);
    pad = 0.05*(hi-lo + 1e-12);
    xl = [lo-pad, hi+pad];
end
end

function xl = xlim_fallback_from_D(D)
allX = [];
for g = 1:numel(D)
    if isfield(D{g},'eta_t')
        v = D{g}.eta_t(:);
        v = v(isfinite(v));
        allX = [allX; v]; %#ok<AGROW>
    end
end
if isempty(allX)
    xl = [-1 1];
else
    lo = prctile(allX, 1);
    hi = prctile(allX, 99);
    pad = 0.05*(hi-lo + 1e-12);
    xl = [lo-pad, hi+pad];
end
end

function s = pick_label(rowLabs, g)
if isempty(rowLabs) || g > numel(rowLabs) || isempty(rowLabs{g})
    s = sprintf('Group %d', g);
else
    s = rowLabs{g};
end
end
