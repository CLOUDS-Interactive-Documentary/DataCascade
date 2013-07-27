
//varying float positionValid;
const float epsilon = 1e-6;
uniform sampler2DRect rgbdTexture;

uniform float minDist;
uniform float fallOff;
varying float fogFactor;

void main (void)
{
	gl_Color.a *= fogFactor * .5;
	gl_FragColor = gl_Color;
	
}
