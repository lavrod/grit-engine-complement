class `navmeshtest` (ColClass) {
	renderingDistance = 1000.0;
	castShadows = true;
	gfxMesh = `meshes/navmeshtest.mesh`;
	colMesh = `meshes/navmeshtest.gcol`;
}

class `RobotMed` (AICharacter) {

	gfxMesh = `/common/characters/robot_med/robot_med.mesh`;
	colMesh = `/common/characters/robot_med/robot_med.gcol`;

	mass = 90;	
    radius = 0.3;
	height = 2.2;

    stepHeight = 0.3;
    pushForce = 5000;
    runPushForce = 10000;

    placementZOffset = 1.112;
	health = 1000;

    states = airandomwalk,
}	

class `RobotScout` (AICharacter) {

	gfxMesh = `/common/characters/robot_scout/robot_scout.mesh`;
	colMesh = `/common/characters/robot_scout/robot_scout.gcol`;

	mass = 90;	
    radius = 0.3;
	height = 2.2;

    stepHeight = 0.3;
    pushForce = 5000;
    runPushForce = 10000;
	
    placementZOffset = 1.112;
	health = 1000;

    states = airandomwalk,
}

class `RobotHeavy` (AICharacter) {

	gfxMesh = `/common/characters/robot_heavy/robot_heavy.mesh`;
	colMesh = `/common/characters/robot_heavy/robot_heavy.gcol`;

	mass = 90;	
    radius = 0.3;
	height = 2.2;

    stepHeight = 0.3;
    pushForce = 5000;
    runPushForce = 10000;
	
    placementZOffset = 1.112;
	health = 5000;

    states = airandomwalk,
}
