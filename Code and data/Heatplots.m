% Plots the policies of the three models and the differences between them.
function showReachStateProbDiff()
    steal_pink = pink;

    policycolors = jet; % 1 - repmat(steal_pink(:,1), 1, 3);
    policy_scale = [0, 40];

    diffcolors = jet;
    diff_scale = [-10, 10];

    % Time correction
    tc = repmat(1:26, 26, 1);
    % Enable this line to disable time boost
    tc = ones(26, 26); % disable time correction
    n_trials = 240;
    
    load('../Summary_Semus_sym');
    data = Summary_Semus_sym;
    
    counts_data = coverage(data);

    load('../estimates_OptimalSym.mat');
    pars_optimal = pars_est;
    probs_optimal = getProbs(pars_optimal);
    counts_optimal = makeFreq(probs_optimal) * n_trials;

    load('../estimates_heuristicUncertaintySym.mat');
    pars_heuristic = pars_est;
    probs_heuristic = getProbs(pars_heuristic);
    counts_heuristic = makeFreq(probs_heuristic) * n_trials;

    load('../estimates_DDM_Sym.mat');
    pars_count = pars_est;
    probs_count = getProbs(pars_count);
    counts_ddm = makeFreq(probs_count) * n_trials;

    figure('Position', [20, 450, 1400, 300]);
    addPlot(1, tc .* counts_data,      policy_scale, policycolors, 'Human Data');
    addPlot(2, tc .* counts_optimal,   policy_scale, policycolors, 'Optimal');
    addPlot(3, tc .* counts_heuristic, policy_scale, policycolors, 'Uncertainty');
    addPlot(4, tc .* counts_ddm,       policy_scale, policycolors, 'DDM');

    figure('Position', [20, 20, 1400, 300]);
    addPlot(2, tc .* (counts_data - counts_optimal),   diff_scale, diffcolors, 'Data - Optimal');
    addPlot(3, tc .* (counts_data - counts_heuristic), diff_scale, diffcolors, 'Data - Uncertainty');
    addPlot(4, tc .* (counts_data - counts_ddm),       diff_scale, diffcolors, 'Data - DDM');
    
    subplot(1, 4, 1);
    caxis(diff_scale);
    colorbar;
    axis off;
end

function total_counts = makeFreq(policy)
    T = size(policy,4) + 1;
    total_counts = zeros(T, T);
    probs = [0 0.2 0.4 0.6 0.8 1];
    % n will keep track of how many parameter configurations there are
    n = 0;
    for subject = 1:size(policy, 1)
        for cost_condition = 1:size(policy, 2)
            for p_green = probs
                counts = zeros(T, T);
                counts(1, 1) = 1;
                for t = 1:T-1
                    current_p_sample = squeeze(policy(subject, cost_condition, 1:t, t));
                    current_counts = counts(1:t, t);
                    next_counts = current_counts .* current_p_sample;
                    
                    next_green = [0; next_counts * p_green];
                    next_red = [next_counts * (1 - p_green); 0];
                    counts(1:t + 1, t + 1) = next_red + next_green;
                end
                total_counts = total_counts + counts;
                n = n + 1;
            end
        end
    end
    total_counts = total_counts / n;
    % Put NaN's in the unreachable states
    for t = 1:(T - 1)
        total_counts((t + 1):end, t) = NaN;
    end
end

function addPlot(nr, data, scale, colors, title_text)
    subplot(1, 4, nr);
    img = imagesc(data, scale);
    if ~exist('OCTAVE_VERSION', 'builtin')
        set(img, 'AlphaData', ~isnan(data));
    end
    title(title_text);
    set(gca,'YDir','normal');
    ticks = [1, 6, 11, 16, 21, 26];
    labels = {'0','5','10', '15', '20', '25'};
    set(gca, 'XTick', ticks);
    set(gca, 'YTick', ticks);
    set(gca, 'XTickLabel', labels);
    set(gca, 'YTickLabel', labels);
    set(gca, 'FontSize', 16);
    xlabel('n samples');
    ylabel('positive samples');
    hold on;
    plot(1 + [0 size(data, 2)], 1 + [0 0.5 * size(data, 1)], 'w-');
    colormap(colors);
    %colorbar;
    hold off;
end