
#include "CloudsVisualSystemDataCascade.h"
#include "CloudsRGBDVideoPlayer.h"

//--------------------------------------------------------------
string CloudsVisualSystemDataCascade::getSystemName(){
	return "DataCascade";
}

//--------------------------------------------------------------
void CloudsVisualSystemDataCascade::selfSetup(){
	regenerateParticles();
	
	speedTexture.allocate(width, 1, OF_IMAGE_COLOR);
	for(int i = 0; i < width; i++){
		speedTexture.setColor(i, 0, ofRandom(10,255) );
	}
	speedTexture.reloadTexture();
	
	sourceOffset.allocate(width, 1, GL_RGB32F);
	targetOffset.allocate(width, 1, GL_RGB32F);
	
	offsetMesh.addVertex(ofVec3f(0,0,0));
	offsetMesh.addVertex(ofVec3f(0,1,0));
	offsetMesh.addVertex(ofVec3f(width,0,0));
	offsetMesh.addVertex(ofVec3f(width,1,0));
	offsetMesh.addTexCoord(ofVec3f(0,0));
	offsetMesh.addTexCoord(ofVec3f(0,1));
	offsetMesh.addTexCoord(ofVec2f(width,0));
	offsetMesh.addTexCoord(ofVec2f(width,1));
	
	offsetMesh.setMode(OF_PRIMITIVE_TRIANGLE_STRIP);

	reloadShaders();
		
	regenerate = true;
	
	if(ofFile::doesFileExist(getVisualSystemDataPath() + "TestVideo/Jer_TestVideo.mov")){
		getRGBDVideoPlayer().setup(getVisualSystemDataPath() + "TestVideo/Jer_TestVideo.mov",
								   getVisualSystemDataPath() + "TestVideo/Jer_TestVideo.xml" );
		
		getRGBDVideoPlayer().swapAndPlay();
		
	}
}

//--------------------------------------------------------------
void CloudsVisualSystemDataCascade::selfPresetLoaded(string presetPath){
	regenerate = true;
}

//--------------------------------------------------------------
void CloudsVisualSystemDataCascade::reloadShaders(){
	
	sourceOffset.begin();
	ofClear(0);
	sourceOffset.end();
	
	targetOffset.begin();
	ofClear(0);
	targetOffset.end();
	
	drawShader.load( getVisualSystemDataPath() + "shaders/display");
	updateShader.load( getVisualSystemDataPath() + "shaders/update");
}

//--------------------------------------------------------------
void CloudsVisualSystemDataCascade::regenerateParticles(){
	
	float currentColorFlip = powf(colorflip,2.0);
	bool one = false;
	debug = false;
	width  = 1280;
	height = 720;
	mesh.clear();
	for(int x = 0; x < width; x++){
		for(int y = 0; y < height; y++){
			mesh.addColor( ofFloatColor( one ? 1 : 0) );
			mesh.addVertex(ofVec3f(x,y,0));
			if(ofRandomuf() > 1.0 - currentColorFlip ) one = !one;
			if(ofRandomuf() > .05) currentColorFlip = ofRandomf() * powf(colorflip, 2.0);
		}
	}
	mesh.setMode(OF_PRIMITIVE_POINTS);
	
	shiftTexture.allocate(width, height, OF_IMAGE_COLOR);
	for(int y = 0; y < height; y++){
		for(int x = 0; x < width; x++){
			if(y == 0){
				shiftTexture.setColor(x, y, ofColor(128));
			}
			else{
				ofColor current = shiftTexture.getColor(x, y-1);
				float random = ofRandomf();
				if(current.r >= 128 && random > 1.0 - pathDeviation){
					shiftTexture.setColor(x, y, current+1);
				}
				else if(current.r <= 128 && random < -(1.0 - pathDeviation)){
					shiftTexture.setColor(x, y, current-1);
				}
				else{
					shiftTexture.setColor(x, y, current);
				}
			}
		}
	}
	
	shiftTexture.update();
	regenerate = false;
}


void CloudsVisualSystemDataCascade::selfSetupGuis(){
	
}

void CloudsVisualSystemDataCascade::selfUpdate(){
	if(regenerate){
		regenerateParticles();
	}
	
	ofPushStyle();
	
	ofDisableAlphaBlending();
	glDisable(GL_DEPTH_TEST);

	sourceOffset.begin();
	updateShader.begin();
	updateShader.setUniformTexture("image", targetOffset.getTextureReference(), 0);
	updateShader.setUniformTexture("speed", speedTexture.getTextureReference(), 1);
	updateShader.setUniform1f("speedMultiplier", powf(speed, 2.0));
	
	offsetMesh.draw();
	
	updateShader.end();
	sourceOffset.end();
	
	ofPopStyle();
	
	swap(sourceOffset,targetOffset);	
}

void CloudsVisualSystemDataCascade::selfDrawBackground(){
	
}

void CloudsVisualSystemDataCascade::selfDrawDebug(){
	
}

void CloudsVisualSystemDataCascade::selfSceneTransformation(){

}

void CloudsVisualSystemDataCascade::selfDraw(){
	
	drawShader.begin();
	
	getRGBDVideoPlayer().setupProjectionUniforms(drawShader);
	
	drawShader.setUniformTexture("image", targetOffset.getTextureReference(), 1);
	drawShader.setUniformTexture("shift", shiftTexture.getTextureReference(), 2);
	drawShader.setUniform1f("height", height);
	drawShader.setUniform1f("deviation", deviation);
	drawShader.setUniform1f("pushz", ofGetMouseX());
	
	ofPushStyle();
	ofEnableAlphaBlending();	
	glPushAttrib(GL_POINT_BIT);
	
	ofPushMatrix();
	
	setupRGBDTransforms();

	ofSetLineWidth(10);
	glPointSize(pointSize);
	if(getTransitionType() != RGBD){
		float scaleexp = powf(scale,2);
		ofTranslate(ofGetWidth()/2,ofGetHeight()/2 );
		ofScale(scaleexp, scaleexp);
		ofTranslate(-ofGetWidth()/2,-ofGetHeight()/2 );
	}
	
	mesh.draw();
	
	
	ofPopMatrix();
	
	glPopAttrib();
	ofPopStyle();
	
	drawShader.end();
	
	
}

void CloudsVisualSystemDataCascade::selfExit(){
	
}

void CloudsVisualSystemDataCascade::selfBegin(){
	sourceOffset.begin();
	ofClear(0);
	sourceOffset.end();
	
	targetOffset.begin();
	ofClear(0);
	targetOffset.end();
		
}

void CloudsVisualSystemDataCascade::selfEnd(){
	
}

void CloudsVisualSystemDataCascade::selfKeyPressed(ofKeyEventArgs & args){
	if(args.key == 'R'){
		cout << "Reloading shader" << endl;
		reloadShaders();
	}
}

void CloudsVisualSystemDataCascade::selfKeyReleased(ofKeyEventArgs & args){
	
}

void CloudsVisualSystemDataCascade::selfMouseDragged(ofMouseEventArgs& data){
	
}

//--------------------------------------------------------------
void CloudsVisualSystemDataCascade::selfMouseMoved(ofMouseEventArgs& data){
	
}

//--------------------------------------------------------------
void CloudsVisualSystemDataCascade::selfMousePressed(ofMouseEventArgs& data){
	
}

//--------------------------------------------------------------
void CloudsVisualSystemDataCascade::selfMouseReleased(ofMouseEventArgs& data){
	
}

//--------------------------------------------------------------
void CloudsVisualSystemDataCascade::selfSetupGui(){
	
}

//--------------------------------------------------------------
void CloudsVisualSystemDataCascade::selfGuiEvent(ofxUIEventArgs &e){
	
}

//--------------------------------------------------------------
void CloudsVisualSystemDataCascade::selfSetupSystemGui(){
	sysGui->addSlider("path color flip chance", 0, 1.0, &colorflip);
	sysGui->addSlider("path deviation", 0, 1000, &deviation);
	sysGui->addSlider("path deviation chance", 0, .2, &pathDeviation);
	sysGui->addLabelButton("regenerate particles", &regenerate);
}

//--------------------------------------------------------------
void CloudsVisualSystemDataCascade::guiSystemEvent(ofxUIEventArgs &e){
}

void CloudsVisualSystemDataCascade::selfSetupRenderGui(){
	rdrGui->addSlider("speed", 0., 2., &speed);
	rdrGui->addSlider("point size", 1., 25., &pointSize);
	rdrGui->addSlider("scale", 1., 10., &scale);
}

//--------------------------------------------------------------
void CloudsVisualSystemDataCascade::guiRenderEvent(ofxUIEventArgs &e){
	
}

