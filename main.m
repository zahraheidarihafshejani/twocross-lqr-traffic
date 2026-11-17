clear; clc; close all;

total_cycles = 50;
show_gui = false; 

% Build controllers
[K, ~, B, Q, R] = build_lq_gain();
mpc_ctrl = build_mpc_controller(B, Q, R);

% Run simulations
res_fixed = simulate_network('fixed', [], total_cycles, show_gui);
res_lqr   = simulate_network('lqr', K, total_cycles, show_gui);
res_mpc   = simulate_network('mpc', mpc_ctrl, total_cycles, show_gui);

cycles = 1:total_cycles;

figure('Name', 'Traffic Performance Comparison', 'Color', 'w', 'Position', [100, 100, 1000, 700]);

% Plot 1: Total Network Queue
subplot(2, 2, 1);
plot(cycles, res_fixed.total_queue, 'r--o', 'LineWidth', 1.8, 'MarkerSize', 5); hold on;
plot(cycles, res_lqr.total_queue, 'b-s', 'LineWidth', 1.8, 'MarkerSize', 5);
plot(cycles, res_mpc.total_queue, 'g-^', 'LineWidth', 1.8, 'MarkerSize', 5);
grid on;
title('Total Network Queue Length');
xlabel('Cycle'); ylabel('Number of Vehicles');
legend({'Fixed-Time', 'Diakaki LQR', 'MPC'}, 'Location', 'best');

% Plot 2: Total Waiting Time
subplot(2, 2, 2);
plot(cycles, res_fixed.total_wait, 'r--o', 'LineWidth', 1.8, 'MarkerSize', 5); hold on;
plot(cycles, res_lqr.total_wait, 'b-s', 'LineWidth', 1.8, 'MarkerSize', 5);
plot(cycles, res_mpc.total_wait, 'g-^', 'LineWidth', 1.8, 'MarkerSize', 5);
grid on;
title('Total Waiting Time');
xlabel('Cycle'); ylabel('Seconds');
legend({'Fixed-Time', 'Diakaki LQR', 'MPC'}, 'Location', 'best');

% Plot 3: Green Time Allocation at Junction 0
subplot(2, 2, 3);
plot(cycles, res_lqr.green_times(:, 1), 'b-^', 'LineWidth', 1.5); hold on;
plot(cycles, res_lqr.green_times(:, 2), 'm-v', 'LineWidth', 1.5);
yline(40, 'k--', 'Base (40s)', 'LineWidth', 1.2);
plot(cycles, res_mpc.green_times(:, 1), 'g-^', 'LineWidth', 1.5);
plot(cycles, res_mpc.green_times(:, 2), 'c-v', 'LineWidth', 1.5);
grid on;
title('Green Time Allocation at Intersection 0');
xlabel('Cycle'); ylabel('Green Time (s)');
legend({'LQR NS', 'LQR EW', 'Base (40s)', 'MPC NS', 'MPC EW'}, 'Location', 'best');

% Plot 4: Queue Imbalance
subplot(2, 2, 4);
plot(cycles, std(res_fixed.queue, 0, 2), 'r--o', 'LineWidth', 1.8); hold on;
plot(cycles, std(res_lqr.queue, 0, 2), 'b-s', 'LineWidth', 1.8);
plot(cycles, std(res_mpc.queue, 0, 2), 'g-^', 'LineWidth', 1.8);
grid on;
title('Queue Imbalance Between Links');
xlabel('Cycle'); ylabel('Queue Std Dev');
legend({'Fixed-Time', 'Diakaki LQR', 'MPC'}, 'Location', 'best');

% Metrics display
names = {'Fixed-Time', 'Diakaki LQR', 'MPC'};
runs = {res_fixed, res_lqr, res_mpc};

fprintf('\n%-14s %14s %14s %16s %16s\n', ...
    'Controller', 'Queue mean', 'Queue std', 'Wait mean', 'Wait std');
fprintf('%s\n', repmat('-', 1, 80));

for i = 1:numel(runs)
    fprintf('%-14s %14.2f %14.2f %16.2f %16.2f\n', ...
        names{i}, ...
        mean(runs{i}.total_queue), std(runs{i}.total_queue), ...
        mean(runs{i}.total_wait),  std(runs{i}.total_wait));
end

fprintf('\nMPC vs Fixed: queue %.1f%% | wait %.1f%%\n', ...
    100 * (1 - mean(res_mpc.total_queue) / mean(res_fixed.total_queue)), ...
    100 * (1 - mean(res_mpc.total_wait) / mean(res_fixed.total_wait)));

fprintf('MPC vs LQR:   queue %.1f%% | wait %.1f%%\n', ...
    100 * (1 - mean(res_mpc.total_queue) / mean(res_lqr.total_queue)), ...
    100 * (1 - mean(res_mpc.total_wait) / mean(res_lqr.total_wait)));
