
SAMPLE_PARTITION_WATERSHED = 0
SAMPLE_PARTITION_MONOTONE = 1
SAMPLE_PARTITION_LAYERS = 2

nav_builder_params = {
	cellSize = 0.3;
	cellHeight = 0.2;
	agentHeight = 2.0;
	agentRadius = 0.6;
	agentMaxClimb = 0.9;
	agentMaxSlope = 45.0;
	regionMinSize = 8;
	regionMergeSize = 20;
	partitionType = SAMPLE_PARTITION_WATERSHED;
	edgeMaxLen = 12.0;
	edgeMaxError = 1.3;
	vertsPerPoly = 6.0;
	detailSampleDist = 6.0;
	detailSampleMaxError = 1.0;
	keepInterResults = false;
	tileSize = 48;
}

local nav_builder_params_spec = {
	cellSize = { "range", 0.1, 1 };
	cellHeight = { "range", 0.1, 1 };
	agentHeight = { "range", 0.1, 5 };
	agentRadius = { "range", 0, 5 };
	agentMaxClimb = { "range", 0.1, 5 };
	agentMaxSlope = { "int range", 0, 90 };
	regionMinSize = { "int range", 0, 150 };
	regionMergeSize = { "int range", 0, 150 };
	partitionType = { "int range", 0, 3 };
	edgeMaxLen = { "int range", 0, 50 };
	edgeMaxError = { "range", 0.1, 3 };
	vertsPerPoly = { "int range", 3, 12 };
	detailSampleDist = { "int range", 0, 16 };
	detailSampleMaxError = { "int range", 0, 16 };
	keepInterResults = { "one of", false, true };
	tileSize = { "one of", 16,24,32,40,48,56,64,72,80,88,96,104,112,120,128 };
}

local function commit(c, p)
    for k,v in pairs(p) do
        if c[k] ~= v then
            c[k] = v
			
			if k == "cellSize" then
				-- navigation_system().cellSize = v
			elseif k == "cellHeight" then
				-- navigation_system().cellHeight = v
			end
        end
    end 
end

make_active_table(nav_builder_params, nav_builder_params_spec, commit)
nav_builder_params.autoUpdate = true
