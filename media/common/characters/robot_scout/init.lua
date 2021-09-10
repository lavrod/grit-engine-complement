-- Code (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- Art (c) Vincent Mayeur 2013, Licenced under Creative Commons License BY-NC-SA: http://creativecommons.org/licenses/by-nc-sa/3.0/

local function point_tex(name)
    local T = {
        image = name,
        filterMax = "POINT",
        filterMip = "LINEAR",
    }
    return T
end

material `robot_scout` { 
	shadowBias = 0.1,
    blendedBones = 3,
    additionalLighting = true,

	diffuseMap = point_tex(`/common/textures/robot_scout.tga`),
	diffuseMask = vec(1, 1, 1),
	emissiveMap = point_tex(`/common/textures/robot_scout_em.tga`),
	emissiveMask = vec(1.0, 2.5, 4),
	glossMap = point_tex(`/common/textures/robot_scout_spec.tga`),
    glossMask = 1,
}


class `.` (DetachedCharacterClass) {

	gfxMesh = `robot_scout.mesh`;
	colMesh = `robot_scout.gcol`;
	
	-- distance travelled in one repeating period of gait
	walkStrideLength = 2.5;
	runStrideLength = 6.5;
	crouchStrideLength = 2.5;
	
	-- animation playback rate factors.
	walkSpeedFactor = 1.0;
	runSpeedFactor = .8; 
	crouchSpeedFactor = 1; 

	-- general character motion stuff
	mass = 60;	
    radius = 0.2;
	height = 2.0;
	crouchHeight = 1.55;
    camHeight = 2.0;

    terminalVelocity = 80/60/60*METRES_PER_MILE;
    stepHeight = 0.3;
    jumpVelocity = 9.5;
    pushForce = 1000;
    runPushForce = 2000;
	
    maxGradient = 50;

    jumpRepeatSpeed = 2;

    originAboveFeet = 1.112;
    placementZOffset = 1.112;
}

