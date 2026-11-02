clear; clc;

sumo_dir = 'C:\twoCross-trafficControl';
net_file = fullfile(sumo_dir, 'twocross.net.xml');

if ~exist(net_file, 'file')
    error('Network file not found: %s', net_file);
end

% Parse SUMO network XML file
xmlDoc = xmlread(net_file);
edges = xmlDoc.getElementsByTagName('edge');

target_edges = {'1i', '2i', '3i', '4i', '5i', '6i', '7i', '8i'};
num_edges = length(target_edges);

lengths = zeros(num_edges, 1);
lane_counts = zeros(num_edges, 1);
S_exact = zeros(num_edges, 1);
x_max_exact = zeros(num_edges, 1);

for i = 1:edges.getLength()
    edgeNode = edges.item(i-1);
    
    if edgeNode.hasAttributes()
        edge_id = char(edgeNode.getAttribute('id'));
        idx = find(strcmp(target_edges, edge_id));
        
        if ~isempty(idx)
            laneNodes = edgeNode.getElementsByTagName('lane');
            n_lanes = laneNodes.getLength();
            lane_counts(idx) = n_lanes;
            
            if n_lanes > 0
                firstLane = laneNodes.item(0);
                lengths(idx) = str2double(char(firstLane.getAttribute('length')));
            end
            
            S_exact(idx) = lane_counts(idx) * 0.5;
            
            x_max_exact(idx) = (lengths(idx) * lane_counts(idx)) / 7.5;
        end
    end
end

T_params = table(target_edges', lane_counts, lengths, S_exact, x_max_exact, ...
    'VariableNames', {'Edge', 'Lanes', 'Length_m', 'SaturationFlow_veh_s', 'MaxQueue_veh'});

disp('================ Physical Parameters Extracted from twocross.net.xml ================');
disp(T_params);

% Save physical parameters to workspace file
save('network_physical_params.mat', 'lengths', 'lane_counts', 'S_exact', 'x_max_exact');
disp('>> Parameters successfully saved to network_physical_params.mat.');
