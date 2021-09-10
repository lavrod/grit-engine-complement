
-- FoliageAnimation shader -> References:
-- https://mtnphil.wordpress.com/2011/10/18/wind-animations-for-vegetation/
-- http://http.developer.nvidia.com/GPUGems3/gpugems3_ch16.html
shader `FoliageAnimation` {

    textureAnimation = uniform_float(0, 0);
    textureScale = uniform_float(1, 1);

    diffuseMap = uniform_texture_2d(1, 1, 1);
    diffuseMask = uniform_float(1, 1, 1);
    diffuseVertex = static_float(0);  -- Boolean

    alphaMask = uniform_float(1);
    alphaVertex = static_float(0);  -- Boolean
    alphaRejectThreshold = uniform_float(-1);

    normalMap = uniform_texture_2d(0.5, 0.5, 1);

    glossMap = uniform_texture_2d(1, 1, 1);
    glossMask = uniform_float(0);
    specularMask = uniform_float(0.04);
    premultipliedAlpha = static_float(0);  -- Boolean

    emissiveMap = uniform_texture_2d(1, 1, 1);
    emissiveMask = uniform_float(0, 0, 0);

    vertexCode = [[
		// side-side1, side-side2, up-down1, up-down2
		var vFreq : Float4 = Float4(1.975, 0.793, 0.375, 0.193);
		
		// Controls how much up and down
		var fBranchAmp : Float = 0.1;
		
		// "Overall stiffness", *inverse* of blue channel
		// Is how restricted this vertex of the leaf/branch is. e.g. close to the stem
		//  it should be 0 (maximum stiffness). At the far outer edge it might be 1.		
		var fBranchAtten : Float = 0.1;// 1 - vert.colour.b;

		// "Leaf stiffness", red vertex channel
		// Controls movement in the plane of the leaf/branch. Generally, it should be 0
		// in the middle of the leaf (maximum stiffness), and 1 on the outer edges.
		var fEdgeAtten : Float = 0.05;// vert.colour.r;
		
		// The green vertex channel
		var fBranchPhase : Float = 0.0;//vert.colour.g;
		
		// How much this plant is affected by the wind
		var fBendScale : Float = 1.0;
		
		// The current direction and strength of the wind
		var vWind : Float2 = Float2(0.0, 0.0);
		
		// Controls how quickly the leaf oscillates
		var fSpeed : Float = 1.0;
		
		// Controls how much back and forth
		var fDetailAmp : Float = 0.05;
		
		// Optional phase for side-to-side. This is used to vary the phase for side-to-side motion
		var fDetailPhase : Float = 1.0;
		
		// Same thing as fSpeed (they could really be combined, but I suspect
		var fDetailFreq : Float = 1.0;
		
		var worldPosition : Float3 = transform_to_world(vert.position.xyz);
		var vPos : Float3 = worldPosition.xyz;

		// Calculate the length from the ground
		var fLength : Float = length(vPos);
		var fBF : Float = vPos.z * fBendScale;

		// Smooth bending factor and increase its nearby height limit.
		fBF = fBF + 1.0;
		fBF = fBF * fBF;
		fBF = fBF * fBF - fBF;

		// Displace position
		var vNewPos : Float3 = vPos;
		vNewPos.xy = vNewPos.xy + vWind.xy * fBF;

		// Rescale - this keeps the plant parts from "stretching" by shortening the y (height) while
		// they move about the xy.		
		vPos.xyz = normalise(vNewPos.xyz) * fLength;

		// Phases (object, vertex, branch)
		// fObjPhase: This ensures phase is different for different plant instances, but it should be
		// the same value for all vertices of the same plant.
		var fObjPhase = dot(worldPosition, Float3(1, 1, 1));
		
		// In this sample fBranchPhase is always zero, but if you want you could somehow supply a
		// different phase for each branch.		
		fBranchPhase = fBranchPhase + fObjPhase;
		
		// Detail phase is (in this sample) controlled by the GREEN vertex color. In your modelling program,
		// assign the same "random" phase color to each vertex in a single leaf/branch so that the whole leaf/branch
		// moves together.
		var fVtxPhase = dot(vPos.xyz, fDetailPhase + fBranchPhase);  
		// x is used for edges; y is used for branches 
		var vWavesIn : Float2 =  Float2(fVtxPhase, fBranchPhase) + global.time;

		var vWaves : Float4 = (fract(vWavesIn.xxyy * vFreq) * 2.0 - 1.0 ) * fSpeed * fDetailFreq;
		
		var TriangleWave = abs( fract(vWaves + 0.5) * 2.0 - 1.0 );
		vWaves = TriangleWave * TriangleWave *( 3.0 - 2.0 * TriangleWave );  

		var vWavesSum : Float2 = vWaves.xz + vWaves.yw;  

		var normal = rotate_to_world(vert.normal.xyz);
		// Edge (xy) and branch bending (z)
		vPos.xyz = vPos.xyz + vWavesSum.xxy *vWavesSum.xxy * Float3(fEdgeAtten * fDetailAmp * (normal.xy), fBranchAtten * fBranchAmp);  
		vPos.y = vPos.y + vWavesSum.y * fBranchAtten * fBranchAmp;
		
		out.position = vPos.xyz;
		
        var normal_ws = normal;
        var tangent_ws = rotate_to_world(vert.tangent.xyz);
        var binormal_ws = vert.tangent.w * cross(normal_ws, tangent_ws);
    ]],

    dangsCode = [[
        var uv = vert.coord0.xy * mat.textureScale + global.time * mat.textureAnimation;
        var diff_texel = sample(mat.diffuseMap, uv);
        if (mat.premultipliedAlpha > 0) diff_texel = pma_decode(diff_texel);
        out.diffuse = gamma_decode(diff_texel.rgb) * mat.diffuseMask;
        if (mat.diffuseVertex > 0) out.diffuse = out.diffuse * vert.colour.xyz;
        out.alpha = diff_texel.a * mat.alphaMask;
        if (mat.alphaVertex > 0) out.alpha = out.alpha * vert.colour.w;
        if (out.alpha <= mat.alphaRejectThreshold) discard;
        var normal_texel = sample(mat.normalMap, uv).xyz;
        var normal_ts = normal_texel * Float3(-2, 2, 2) + Float3(1, -1, -1);
        out.normal = normal_ts.x*tangent_ws + normal_ts.y*binormal_ws + normal_ts.z*normal_ws;
        var gloss_texel = sample(mat.glossMap, uv);
        out.gloss = gloss_texel.b * mat.glossMask;
        out.specular = gamma_decode(gloss_texel.r) * mat.specularMask;
    ]],

    additionalCode = [[
        var uv = vert.coord0.xy * mat.textureScale + global.time * mat.textureAnimation;
        var c = sample(mat.emissiveMap, uv);
        out.colour = gamma_decode(c.rgb) * mat.emissiveMask;
    ]],
}

material `TropGroup1` {
	shader = `FoliageAnimation`,
    backfaces = true,
    -- clamp = true,  // TODO: clamp
    shadowBias=.03,

    diffuseMap = `textures/TropGroup1.dds`,
    alphaRejectThreshold = 0.5,
    shadowAlphaReject = true,
    normalMap = `textures/TropGroup1_N.dds`,
    -- specularFromDiffuse = {-0.3, 0.2},
    -- translucencyMap = `textures/TropGroup1_SSS.dds`,
    specularMask = 0,
}

class `TropPlant1` (BaseClass) { castShadows=true, renderingDistance=70, placementRandomRotation=true }
class `TinyPalmT` (BaseClass) { castShadows=true, renderingDistance=70, placementRandomRotation=true }
class `YellowFlowers` (BaseClass) { castShadows=true, renderingDistance=35, placementRandomRotation=true }
class `PinkFlowers` (BaseClass) { castShadows=true, renderingDistance=35, placementRandomRotation=true }

material `Tree_aelmTrunk` {
    diffuseVertex = 1,
    diffuseMap = `textures/tree_aelm.dds`,
	diffuseMask = V_ID*3,
    normalMap = `textures/tree_aelm_N.dds`,
    specularMask = 0,
}

material `Tree_aelmLev` {
	shader = `FoliageAnimation`,
    -- clamp = true,  // TODO: clamp

    diffuseMap = `textures/tree_aelm.dds`,
	diffuseMask = V_ID*3,
    alphaRejectThreshold = 0.5,
    normalMap = `textures/tree_aelm_N.dds`,
    specularMask = 0,
}


class `Tree_aelm_LOD` (ColClass) { castShadows=true, renderingDistance=350, colMesh=`Tree_aelm.gcol` }
class `Tree_aelm` (ColClass) { castShadows=true, renderingDistance=100, lod=`Tree_aelm_LOD` }


--paroxum's tree, hes mad

material `generic_bark` {
    diffuseMap = `textures/generic_bark.tga`,
    normalMap = `textures/generic_bark_nrm.tga`,
    specularMask = 0,
	diffuseMask = V_ID*10,
}

material `flowerbed_dif` {
	shader = `FoliageAnimation`,
    backfaces = true,
    -- clamp = true,  -- TODO: clamp
    shadowAlphaReject = true,

    diffuseMap = `textures/flowerbed_dif.tga`,
    normalMap = `textures/flowerbed_nrm.tga`,
    alphaRejectThreshold = 0.5,
    diffuseMask = vec(10, 10, 10),
    specularMask = 0,
}

class `prxtree` (ColClass) { castShadows=true, renderingDistance=250 }

--end paroxum tree

-- TODO: needs special grass shader
material `GrassTuft1` {
	shader = `FoliageAnimation`,
    backfaces=true,
    -- clamp = true,  -- TODO: clamp

    diffuseMap = `textures/GrassTuft1_D.dds`,
    alphaRejectThreshold = 0.9,
    specularMask = 0,
}

material `grasstuft2` {
	shader = `FoliageAnimation`,
    backfaces = true,
    -- clamp = true,  -- TODO: clamp

    diffuseMap = `textures/GrassTuft2_D.dds`,
    normalMap = `textures/GrassTuft2_N.dds`,
    alphaRejectThreshold = 0.33,
    specularMask = 0,
}


material `GrassMap1` {
	shader = `FoliageAnimation`,
    backfaces = true,
    -- clamp = true,  -- TODO: clamp

    diffuseMap = `textures/GrassMap1.dds`,
    alphaRejectThreshold = 0.5,
    specularMask = 0,
}

class `GrassTuft1` (BaseClass) { renderingDistance=30, placementRandomRotation=true }
class `GrassMesh` (BaseClass) { renderingDistance=30, placementRandomRotation=true }
