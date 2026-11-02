clear; clc; close all;

total_cycles = 50;
show_gui = false; 

% Build LQR gain matrix 
[K, ~, ~, ~, ~] = build_lq_gain(90);

% Run simulations 
res_fixed = simulate_network('fixed', [], total_cycles, show_gui);
res_lqr = simulate_network('lqr', K, total_cycles, show_gui);

cycles = 1:total_cycles;

figure('Name', 'Traffic Performance Comparison', 'Color', 'w', 'Position', [100, 100, 1000, 700]);

% Plot 1: Total Network Queue
subplot(2, 2, 1);
plot(cycles, res_fixed.total_queue, 'r--o', 'LineWidth', 1.8, 'MarkerSize', 5); hold on;
plot(cycles, res_lqr.total_queue, 'b-s', 'LineWidth', 1.8, 'MarkerSize', 5);
grid on;
title('Total Network Queue Length');
xlabel('Cycle'); ylabel('Number of Vehicles');
legend({'Fixed-Time', 'Diakaki LQR'}, 'Location', 'best');

% Plot 2: Total Waiting Time
subplot(2, 2, 2);
plot(cycles, res_fixed.total_wait, 'r--o', 'LineWidth', 1.8, 'MarkerSize', 5); hold on;
plot(cycles, res_lqr.total_wait, 'b-s', 'LineWidth', 1.8, 'MarkerSize', 5);
grid on;
title('Total Waiting Time');
xlabel('Cycle'); ylabel('Seconds');
legend({'Fixed-Time', 'Diakaki LQR'}, 'Location', 'best');

% Plot 3: Green Time Allocation at Junction 0
subplot(2, 2, 3);
plot(cycles, res_lqr.green_times(:, 1), 'b-^', 'LineWidth', 1.5); hold on;
plot(cycles, res_lqr.green_times(:, 2), 'm-v', 'LineWidth', 1.5);
yline(40, 'k--', 'Base (40s)', 'LineWidth', 1.2);
grid on;
title('Green Time Allocation at Intersection 0 (LQR)');
xlabel('Cycle'); ylabel('Green Time (s)');
legend({'NS Phase', 'EW Phase'}, 'Location', 'best');

% Calculate queue standard deviation across links
std_fixed = std(res_fixed.queue, 0, 2);
std_lqr = std(res_lqr.queue, 0, 2);

% Plot 4: Queue Imbalance
subplot(2, 2, 4);
plot(cycles, std_fixed, 'r--o', 'LineWidth', 1.8); hold on;
plot(cycles, std_lqr, 'b-s', 'LineWidth', 1.8);
grid on;
title('Queue Imbalance Between Links');
xlabel('Cycle'); ylabel('Queue Std Dev');
legend({'Fixed-Time', 'Diakaki LQR'}, 'Location', 'best');

% Performance improvement calculations
imp_queue = (mean(res_fixed.total_queue) - mean(res_lqr.total_queue)) / mean(res_fixed.total_queue) * 100;
imp_wait = (mean(res_fixed.total_wait) - mean(res_lqr.total_wait)) / mean(res_fixed.total_wait) * 100;

fprintf('\n================== Performance Summary ==================\n');
fprintf('Mean Total Queue: Fixed = %.1f | LQR = %.1f | Improvement: %.1f%%\n', ...
    mean(res_fixed.total_queue), mean(res_lqr.total_queue), imp_queue);
fprintf('Mean Total Wait:  Fixed = %.1f | LQR = %.1f | Improvement: %.1f%%\n', ...
    mean(res_fixed.total_wait), mean(res_lqr.total_wait), imp_wait);
fprintf('=========================================================\n');

metrics = {'Total Queue', 'Total Wait', 'Queue Imbalance'};

% Compute specific queue imbalances
imb_fixed = abs(res_fixed.queue(:,1) - res_fixed.queue(:,2)) + ...
            abs(res_fixed.queue(:,5) - res_fixed.queue(:,6));
imb_lqr   = abs(res_lqr.queue(:,1)   - res_lqr.queue(:,2))   + ...
            abs(res_lqr.queue(:,5)   - res_lqr.queue(:,6));

fx = {res_fixed.total_queue, res_fixed.total_wait, imb_fixed};
lq = {res_lqr.total_queue,   res_lqr.total_wait,   imb_lqr};

fprintf('\n%-18s | %-22s | %-22s | %-10s\n', 'Metric', 'Fixed (mean±std)', 'LQR (mean±std)', 'Imp (%)');
fprintf('%s\n', repmat('-', 1, 80));
for i = 1:numel(metrics)
    mf = mean(fx{i}); sf = std(fx{i});
    ml = mean(lq{i}); sl = std(lq{i});
    imp = 100*(mf - ml)/mf;
    fprintf('%-18s | %6.2f ± %-12.2f | %6.2f ± %-12.2f | %6.1f\n', ...
        metrics{i}, mf, sf, ml, sl, imp);
end
