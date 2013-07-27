
//varying float positionValid;
const float epsilon = 1e-6;
uniform sampler2DRect rgbdTexture;

//TODO: add point sprites or something cool!
void main (void)
{
	
//	if(positionValid < epsilon){
//    	discard;
//        return;
//    }

	gl_FragColor = gl_Color;
	
}
