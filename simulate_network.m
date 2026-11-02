function results = simulate_network(mode, K, num_cycles, show_gui)

if nargin < 4, show_gui = false; end
if nargin < 3, num_cycles = 15; end

sumo_dir = 'C:\twoCross-trafficControl';
sumocfg_file = fullfile(sumo_dir, 'twocross.sumocfg');

try py.traci.close(); catch; end

% Initialize SUMO simulation via TraCI
sumo_bin = 'sumo';
if show_gui, sumo_bin = 'sumo-gui'; end
cmd = py.list({sumo_bin, '-c', sumocfg_file, '--start', '--seed', '42'});
py.traci.start(cmd);

edge_ids = {'1i', '2i', '3i', '4i', '5i', '6i', '7i', '8i'};
C = 90;
lost_time_0 = 10; 
lost_time_5 = 6;  

g0_base = (C - lost_time_0) / 2; 
g5_base = (C - lost_time_5) / 2; 

queue_log = zeros(num_cycles, 8);
wait_log = zeros(num_cycles, 8);
green_log = zeros(num_cycles, 4);


% Main simulation loop over cycles
for cyc = 1:num_cycles
    x_k = zeros(8, 1);
    w_k = zeros(8, 1);
    for e = 1:8
        x_k(e) = double(py.traci.edge().getLastStepHaltingNumber(edge_ids{e}));
        w_k(e) = double(py.traci.edge().getWaitingTime(edge_ids{e}));
    end
    queue_log(cyc, :) = x_k';
    wait_log(cyc, :) = w_k';
    
    if strcmpi(mode, 'lqr')
        u = -K * x_k;
        
        delta_g0 = max(-12, min(12, (u(1) - u(2))));
        g0_NS = round(g0_base + delta_g0);
        g0_NS = max(15, min((C - lost_time_0) - 15, g0_NS));
        g0_EW = (C - lost_time_0) - g0_NS;
        
        delta_g5 = max(-12, min(12, (u(3) - u(4))));
        g5_NS = round(g5_base + delta_g5);
        g5_NS = max(15, min((C - lost_time_5) - 15, g5_NS));
        g5_EW = (C - lost_time_5) - g5_NS;
    else
        g0_NS = g0_base;
        g0_EW = g0_base;
        g5_NS = g5_base;
        g5_EW = g5_base;
    end
    green_log(cyc, :) = [g0_NS, g0_EW, g5_NS, g5_EW];
    
    % phase transition switching times
    t0_y1_start = g0_NS;
    t0_g2_start = g0_NS + 5;
    t0_y2_start = t0_g2_start + g0_EW;
    
    t5_y1_start = g5_NS;
    t5_g2_start = g5_NS + 3;
    t5_y2_start = t5_g2_start + g5_EW;
    
    for t = 1:C
        if t <= t0_y1_start
            p0 = 0;
        elseif t <= t0_g2_start
            p0 = 1;
        elseif t <= t0_y2_start
            p0 = 2; 
        else
            p0 = 3; 
        end
        
        if t <= t5_y1_start
            p5 = 0; 
        elseif t <= t5_g2_start
            p5 = 1; 
        elseif t <= t5_y2_start
            p5 = 2; 
        else
            p5 = 3; 
        end
        
        py.traci.trafficlight().setPhase('0', int32(p0));
        py.traci.trafficlight().setPhase('5', int32(p5));
        py.traci.simulationStep();
    end
end

py.traci.close();

results.queue = queue_log;
results.waiting_time = wait_log;
results.green_times = green_log;
results.total_queue = sum(queue_log, 2);
results.total_wait = sum(wait_log, 2);
end
