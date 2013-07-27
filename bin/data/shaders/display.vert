
uniform sampler2DRect image;
uniform sampler2DRect shift;
uniform float height;
uniform float deviation;

//uniform float pushz;
//varying vec2 vertxy;

//RGBD UNIFORMS
//TEXTURE INFORMATION
//
uniform sampler2DRect rgbdTexture;
uniform vec2 textureSize;
//COLOR
uniform vec4 colorRect;
uniform vec2 colorScale;

uniform vec2 colorFOV;
uniform vec2 colorPP;
uniform vec3 dK;
uniform vec2 dP;

uniform mat4 extrinsics;
uniform vec2 scale;

//DEPTH
uniform vec4 depthRect;
uniform vec2 depthPP;
uniform vec2 depthFOV;

//NORMAL
uniform vec4 normalRect;

//GEOMETRY
uniform vec2  simplify;
uniform float farClip;
uniform float nearClip;
uniform float edgeClip;
uniform float minDepth;
uniform float maxDepth;

//varying float positionValid;

//END RGBD UNIFORMS


//RGBD STUFF::
vec3 rgb2hsl( vec3 _input ){
	float h = 0.0;
	float s = 0.0;
	float l = 0.0;
	float r = _input.r;
	float g = _input.g;
	float b = _input.b;
	float cMin = min( r, min( g, b ) );
	float cMax = max( r, max( g, b ) );
	
	l = ( cMax + cMin ) / 2.0;
	if ( cMax > cMin ) {
		float cDelta = cMax - cMin;
        
		s = l < .05 ? cDelta / ( cMax + cMin ) : cDelta / ( 2.0 - ( cMax + cMin ) );
		
		// hue
		if ( r == cMax ) {
			h = ( g - b ) / cDelta;
		} else if ( g == cMax ) {
			h = 2.0 + ( b - r ) / cDelta;
		} else {
			h = 4.0 + ( r - g ) / cDelta;
		}
		
		if ( h < 0.0) {
			h += 6.0;
		}
		h = h / 6.0;
	}
	return vec3( h, s, l );
}

float depthValueFromSample( vec2 depthPos){
    vec2  halfvec = vec2(.5,.5);
    float depth = rgb2hsl( texture2DRect(rgbdTexture, floor(depthPos) + halfvec ).xyz ).r;
    return depth * ( maxDepth - minDepth ) + minDepth;
}

void main(void)
{
	
	//----------
	float offset = texture2DRect(image, vec2(gl_Vertex.x, 1.0)).r;
		
	//this is a default vertex shader, don't modify the position
	vec4 pos = vec4(gl_Vertex.x,
					mod(gl_Vertex.y + offset, height),
					gl_Vertex.z,
					gl_Vertex.w);

	pos.x += (texture2DRect(shift, vec2(gl_Vertex.x, pos.y)).r - .5) * deviation;
	
	//RGBD STUFF
	// Here we get the position, and account for the vertex position flowing
	vec2 samplePos = vec2(pos.x, pos.y);
//	vec2 samplePos = gl_Vertex.xy;
    vec2 depthPos = samplePos + depthRect.xy;
    float depth = depthValueFromSample( depthPos );
	
	if(depth <= minDepth){
		depth = maxDepth;
	}
	// Reconstruct the 3D point position
    vec4 rgbdPos = vec4((samplePos.x - depthPP.x) * depth / depthFOV.x,
						(samplePos.y - depthPP.y) * depth / depthFOV.y,
						depth,
						1.0);
    
	gl_Position = gl_ModelViewProjectionMatrix * rgbdPos;
	gl_FrontColor = gl_Color;
	
	//extract the normal and pass it along to the fragment shader
//    vec2  normalPos = samplePos + normalRect.xy;
//	//    normal = texture2DRect(texture, floor(normalPos) + vec2(.5,.5)).xyz * 2.0 - 1.0;
//	vec4 normalColor = texture2DRect(texture, floor(normalPos) + vec2(.5,.5));
//	vec3 surfaceNormal = normalColor.xyz * 2.0 - 1.0;
//    normal = -normalize(gl_NormalMatrix * surfaceNormal);
//	vec3 vert = vec3(gl_ModelViewMatrix * pos);
//	eye = normalize(-vert);
	
//    float right = depthValueFromSample( depthPos + vec2(simplify.x,0.0)  );
//    float down  = depthValueFromSample( depthPos + vec2(0.0,simplify.y)  );
//    float left  = depthValueFromSample( depthPos + vec2(-simplify.x,0.0) );
//    float up    = depthValueFromSample( depthPos + vec2(0.0,-simplify.y) );
//    float bl    = depthValueFromSample( vec2(floor(depthPos.x - simplify.x),floor( depthPos.y + simplify.y)) );
//    float ur    = depthValueFromSample( vec2(floor(depthPos.x + simplify.x),floor( depthPos.y - simplify.y)) );
//    
//    positionValid = (depth < farClip &&
//					 right < farClip &&
//					 down < farClip &&
//					 left < farClip &&
//					 up < farClip &&
//					 bl < farClip &&
//					 ur < farClip &&
//					 
//					 depth > nearClip &&
//					 right > nearClip &&
//					 down > nearClip &&
//					 left > nearClip &&
//					 up > nearClip &&
//					 bl > nearClip &&
//					 ur > nearClip &&
//					 
//					 abs(down - depth) < edgeClip &&
//					 abs(right - depth) < edgeClip &&
//					 abs(up - depth) < edgeClip &&
//					 abs(left - depth) < edgeClip &&
//					 abs(ur - depth) < edgeClip &&
//					 abs(bl - depth) < edgeClip
//					 ) ? 1.0 : 0.0;
	
//	rgbdPos.z += 1000.;
//    pos.z += 1000.;
//	if(positionValid == 0.0){
//		rgbdPos.z = maxDepth;
//	}
//	if(positionValid > .5){
//	}
//	else {
//		gl_Position = gl_ModelViewProjectionMatrix * pos;
//	}
    // http://opencv.willowgarage.com/documentation/camera_calibration_and_3d_reconstruction.html
    //

	//----------END RGBD
	
	
	
	//pass color info along
}

