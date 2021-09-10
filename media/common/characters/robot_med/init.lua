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

material `robot_med` { 
    additionalLighting = true,
	shadowBias = 0.1,
    blendedBones = 3,

	diffuseMap = point_tex(`/common/textures/robot_med.tga`),
	diffuseMask = vec(1, 1, 1),
	emissiveMap = point_tex(`/common/textures/robot_med_em.tga`),
	emissiveMask = vec(1.0, 2.5, 4),
	glossMap = point_tex(`/common/textures/robot_med_spec.tga`),
    glossMask = 1,
}

class `.` (DetachedCharacterClass) {

	gfxMesh = `robot_med.mesh`;
	colMesh = `robot_med.gcol`;
	
	-- distance travelled in one repeating period of gait
	walkStrideLength = 2.5;
	runStrideLength = 6.5;
	crouchStrideLength = 2.5;
	
	-- animation playback rate factors.
	walkSpeedFactor = 1.0;
	runSpeedFactor = 0.6; 
	crouchSpeedFactor = 1; 

	-- general character motion stuff
	mass = 90;	
    radius = 0.3;
	height = 2.2;
	crouchHeight = 1.55;
    camHeight = 2.2;

    terminalVelocity = 80/60/60*METRES_PER_MILE;
    stepHeight = 0.3;
    jumpVelocity = 6;
    pushForce = 5000;
    runPushForce = 10000;
	
    maxGradient = 50;

    jumpRepeatSpeed = 1.5;

    originAboveFeet = 1.112;
    placementZOffset = 1.112;
}

