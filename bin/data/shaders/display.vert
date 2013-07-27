
uniform sampler2DRect image;
uniform sampler2DRect shift;
uniform float height;
uniform float deviation;
uniform vec2 vertexOffset;
uniform float vertexScale;

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
	depthPos.x = clamp(depthPos.x,depthRect.x+1.,depthRect.x+depthRect.z-2.);
	depthPos.y = clamp(depthPos.y,depthRect.y+1.,depthRect.y+depthRect.w-2.);
	
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
	
	pos.xy *= vertexScale;
	pos.xy += vertexOffset;
	
	//RGBD STUFF
	// Here we get the position, and account for the vertex position flowing
	vec2 samplePos = vec2(pos.x, pos.y);
    vec2 depthPos = samplePos + depthRect.xy;
    float depth = depthValueFromSample( depthPos );
	
	//if the depth value is equal or less than min depth, then it didn't fall on the person.
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
	
}

