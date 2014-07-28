#include "ofApp.h"

void ofApp::setup(){
    
    ofSetOrientation(OF_ORIENTATION_90_RIGHT);
    ofEnableAlphaBlending();
    ofSetCircleResolution(24);
    
    ofxAccelerometer.setup();
    ofxMultiTouch.addListener(this);
    
    backgroundColorHue = ofRandom(0,255);
    ofBackground(ofColor::fromHsb(backgroundColorHue, 150, 180));
    
    initialBufferSize = 1024;
    sampleRate = 44100;
    drawCounter = 0;
    bufferCounter = 0;
    buffer = new float[initialBufferSize];
    memset(buffer, 0, initialBufferSize * sizeof(float));
    
    ofSoundStreamSetup(0, 1, this, sampleRate, initialBufferSize, 4);
	ofSoundStreamSetup(2, 0, this, sampleRate, initialBufferSize, 4);
    ofSetFrameRate(60);
    
    
    dir.listDir("sounds/samples/");
    dir.sort();
    if( dir.size() ){
        soundsList.assign(dir.size(), ofSoundPlayer());
    }
    for(int i = 0; i < (int)dir.size(); i++){
        soundsList[i].loadSound(dir.getPath(i));
    }
    currentSound = 0;
    
    fileNameUp = "sounds/samples/tap_02.wav";
    fileNameDown = "sounds/samples/tap_01.wav";
    highVolume = 0.75;
    
    triggerCounterUp = 0;
    triggerCounterDown = 0;
    
    startTime = ofGetElapsedTimeMillis();
    millisDown = ofGetElapsedTimeMillis();
    bangUp = false;
    bangDown = false;
    
    soundRecordingDownOn = true;
    
    controlRectSize = 22;
    
    for (int i=0; i<16; i++) {
        randomY[i] = ofRandom(55,ofGetHeight()*2/5);
    }
    
    downPart.length = ofGetWidth()*3/8;
    downPart.bBeingClick = true;
    downPart.bTimerReached = true;
    downPart.bDownSoundRecordClick = true;
    downPart.bChangeSampleClick = false;
    downPart.bChangeSampleOver = false;
    downPart.startTime = ofGetElapsedTimeMillis() - 1000;
    downPart.rectBlockAlphaFactor = 0;
    downPart.recordState=0;
    downPart.soundVolume = 1;
    downPart.changeSampleIndex = 0;
    downPart.myWavWriter.setFormat(1, sampleRate, 16);
    downPart.onOffRectPos.x = -downPart.length/2 + ofGetWidth()/2;
    downPart.lengthRectPos.x = downPart.length/2 + ofGetWidth()/2;
    downPart.changeSampleSize = 60;
    
    upPart.length = downPart.length;
    upPart.bBeingClick = true;
    upPart.bTimerReached = true;
    upPart.bDownSoundRecordClick = true;
    upPart.bChangeSampleClick = false;
    upPart.bChangeSampleOver = false;
    upPart.startTime = ofGetElapsedTimeMillis() - 1000;
    upPart.rectBlockAlphaFactor = 0;
    upPart.recordState=0;
    upPart.soundVolume = 1;
    upPart.changeSampleIndex = 0;
    upPart.myWavWriter.setFormat(1, sampleRate, 16);
    upPart.onOffRectPos.x = -upPart.length/2 + ofGetWidth()/2;
    upPart.lengthRectPos.x = upPart.length/2 + ofGetWidth()/2;
    upPart.changeSampleSize = 60;
    
    upPart.position.x = upPart.lengthRectPos.x-downPart.lengthRectPos.x;
    upPart.delayPos.x = upPart.length/2 + ofGetWidth()/2 - upPart.length/(10*2);
    
    nElementLine = 8;
    for (int i = 0; i<nElementLine; i++){
        elementDown[i].bLengthOver = false;
        elementDown[i].bOnOffOver = false;
        elementDown[i].bLengthBeingDragged = false;
        elementDown[i].bBeingClick = false;
        elementDown[i].soundTrigger = true;
        //        elementDown[i].samplePlay.setMultiPlay(true);
        elementDown[i].samplePlay.loadSound(fileNameDown);
        elementDown[i].samplePlay.setVolume(highVolume);
        spacingLineDown = downPart.length / 10;
        elementDown[i].position = ofVec2f(spacingLineDown + spacingLineDown/2 + spacingLineDown*i,
                                               downPart.onOffRectPos.y);
        elementDown[i].pitchRectPos = ofVec2f(elementDown[i].position.x, elementDown[i].position.y+randomY[i]);
        elementDown[i].onOffRectPos = elementDown[i].pitchRectPos * ofVec2f(1,-1) + ofVec2f(0,ofGetHeight());
        elementDown[i].width = controlRectSize;
        elementDown[i].triggerColor = 120;
        
        elementUp[i].bLengthOver = false;
        elementUp[i].bOnOffOver = false;
        elementUp[i].bLengthBeingDragged = false;
        elementUp[i].bBeingClick = false;
        elementUp[i].soundTrigger = true;
        //        elementUp[i].samplePlay.setMultiPlay(true);
        elementUp[i].samplePlay.loadSound(fileNameUp);
        elementUp[i].samplePlay.setVolume(highVolume);
        spacingLineUp = upPart.length / 10;
        elementUp[i].position = ofVec2f(spacingLineUp + spacingLineUp/2 + spacingLineUp*i,
                                             upPart.onOffRectPos.y);
        elementUp[i].pitchRectPos = ofVec2f(elementUp[i].position.x, elementUp[i].position.y-randomY[i+8]);
        elementUp[i].onOffRectPos = elementUp[i].pitchRectPos * ofVec2f(1,-1) + ofVec2f(0,ofGetHeight());
        elementUp[i].width = controlRectSize;
        elementUp[i].triggerColor = 120;
    }
    
    speedTempo = 120.0;
	setBPM(speedTempo);
    
    rectSizeRatio = 0.5;
    
    recBlockSize = initialBufferSize/8;
    
}

void ofApp::update(){
    
    ofSoundUpdate();
    
    downPart.recBlockPos = ofVec2f(downPart.onOffRectPos.x-30, ofGetHeight()/2+ofGetHeight()*0.1);
    downPart.changeSamplePos = ofVec2f(downPart.lengthRectPos.x, ofGetHeight()/2+ofGetHeight()*0.09);
    
    upPart.recBlockPos = ofVec2f(upPart.onOffRectPos.x-30, ofGetHeight()/2-ofGetHeight()*0.1);
    upPart.changeSamplePos = ofVec2f(upPart.lengthRectPos.x,ofGetHeight()/2-ofGetHeight()*0.09);
    
    downPart.length = downPart.lengthRectPos.x - downPart.onOffRectPos.x;
    downPart.onOffRectPos.x = -downPart.length/2 + ofGetWidth()/2;
    downPart.lengthRectPos.x = downPart.length/2 + ofGetWidth()/2;
    
    delayupPart = (int)(upPart.position.x)/12;
    
    speedTempo = ofMap(downPart.length/12, 0, 1024/12, 180, 60);
    setBPM(speedTempo);

    int _speedFactor8th = 4;
    int _index = counterBPM%32;
    
    for (int i = 0; i<nElementLine; i++) {
        if (_index==((i*_speedFactor8th))) {
            if ((elementDown[i].soundTrigger)&&downPart.bBeingClick) {
                elementDown[i].onOffTrigger = true;
            }
        } else {
            elementDown[i].onOffTrigger = false;
        }
        
        if (_index==((i*_speedFactor8th)+delayupPart)) {
            if ((elementUp[i].soundTrigger)&&upPart.bBeingClick) {
                elementUp[i].onOffTrigger = true;
            }
        } else {
            elementUp[i].onOffTrigger = false;
        }
    }

    
    spacingLineDown = downPart.length / 10;
    spacingLineUp = downPart.length / 10;
    
    upPart.lengthRectPos.x = downPart.lengthRectPos.x + spacingLineUp * delayupPart * 0.25;
    upPart.onOffRectPos.x = downPart.onOffRectPos.x + spacingLineUp * delayupPart * 0.25;
    upPart.length = upPart.lengthRectPos.x - upPart.onOffRectPos.x;
    
    for (int i = 0; i<nElementLine; i++){
        elementDown[i].position = ofVec2f(downPart.onOffRectPos.x + spacingLineDown + spacingLineDown/2 + spacingLineDown*i,
                                               downPart.onOffRectPos.y);
        elementDown[i].pitchRectPos = ofVec2f(elementDown[i].position.x, elementDown[i].pitchRectPos.y);
        elementDown[i].onOffRectPos = elementDown[i].pitchRectPos * ofVec2f(1,0) + ofVec2f(0,controlRectSize*3/2);
        elementUp[i].position.x = elementDown[i].position.x + spacingLineUp * delayupPart * 0.25;
        elementUp[i].pitchRectPos = ofVec2f( elementUp[i].position.x, elementUp[i].pitchRectPos.y );
        elementUp[i].onOffRectPos = elementUp[i].pitchRectPos * ofVec2f(1,0) + ofVec2f(0,-controlRectSize*3/2);
    }
    
    
    if ((!upPart.bBeingClick&&!upPart.bDownSoundRecordClick)||downPart.bBeingClick){
        upPart.bDownSoundRecordClick = true;
    }
    if ((!downPart.bBeingClick&&!downPart.bDownSoundRecordClick)||upPart.bBeingClick){
        downPart.bDownSoundRecordClick = true;
    }

    
}


void ofApp::draw(){
    
    downPartDraw();
    upPartDraw();
    
    
    if (!upPart.bBeingClick&&downPart.bBeingClick){
        recordingLineDraw(downPart.recBlockPos);
    }
    if (!downPart.bBeingClick&&upPart.bBeingClick){
        recordingLineDraw(upPart.recBlockPos);
    }
    
    downPart.bDownSoundRecordPos = ofVec2f( downPart.recBlockPos.x,downPart.recBlockPos.y-(recBlockSize-1)/2 );
    upPart.bDownSoundRecordPos = ofVec2f( upPart.recBlockPos.x,upPart.recBlockPos.y-(recBlockSize-1)/2 );
    
    ofPushStyle();
    ofSetColor( ofColor::fromHsb(backgroundColorHue, 0, 220, 100) );
    //    if (upPart.bChangeSampleOver){
    ofPushStyle();
    if (upPart.bChangeSampleClick){
        ofSetColor( ofColor::fromHsb(backgroundColorHue, 0, 220, 160) );
        upPart.changeSampleIndex++;
        upPart.changeSampleIndex = upPart.changeSampleIndex%dir.size();
        for (int i = 0; i<nElementLine; i++){
            string fileNameUp = "sounds/samples/" + dir.getName(upPart.changeSampleIndex);
            elementUp[i].samplePlay.loadSound(fileNameUp);
        }
        upPart.bChangeSampleClick = !upPart.bChangeSampleClick;
    }
    else{
        ofSetColor( ofColor::fromHsb(backgroundColorHue, 0, 220, 50) );
    }
    //        ofRect(upPart.changeSamplePos.x-upPart.changeSampleSize/2, upPart.changeSamplePos.y-upPart.changeSampleSize/2, upPart.changeSampleSize, upPart.changeSampleSize);
    //        ofNoFill();
    //        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, 80) );
    //        ofLine(upPart.changeSamplePos.x+upPart.changeSampleSize/2,upPart.changeSamplePos.y+upPart.changeSampleSize/2,upPart.lengthRectPos.x+3,upPart.lengthRectPos.y+ofGetHeight()/2-7);
    ofPopStyle();
    
    //    }
    //    if (downPart.bChangeSampleOver){

    ofPushStyle();
    if (downPart.bChangeSampleClick){
        ofSetColor( ofColor::fromHsb(backgroundColorHue, 0, 220, 160) );
        downPart.changeSampleIndex++;
        downPart.changeSampleIndex = downPart.changeSampleIndex%dir.size();
        for (int i = 0; i<nElementLine; i++){
            string fileNameDown = "sounds/samples/" + dir.getName(downPart.changeSampleIndex);
            elementDown[i].samplePlay.loadSound(fileNameDown);
        }
        downPart.bChangeSampleClick = !downPart.bChangeSampleClick;
    } else {
        ofSetColor( ofColor::fromHsb(backgroundColorHue, 0, 220, 50) );
    }
    //        ofRect(downPart.changeSamplePos.x-30, downPart.changeSamplePos.y-30, 60, 60);
    //        ofNoFill();
    //        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, 80) );
    //        ofLine(downPart.changeSamplePos.x+30,downPart.changeSamplePos.y-30,downPart.lengthRectPos.x+3,downPart.lengthRectPos.y+ofGetHeight()/2+7);
    ofPopStyle();
    //    }
    ofPopStyle();
    
    
    infomationWindow();
    touchGuideLine();
    ofDrawBitmapString(ofToString(ofGetFrameRate(),2), 10, 10);
    
}


void ofApp::downPartDraw(){
    
    ofPushMatrix();
    ofTranslate(0, ofGetHeight()/2+controlRectSize*rectSizeRatio);
    
    drawingTempoLine(downPart.bBeingClick,downPart.bLengthOver,downPart.bOnOffOver,downPart.lengthRectPos,downPart.onOffRectPos);
    
    ofPushStyle();
    ofSetRectMode(OF_RECTMODE_CENTER);
    
    for (int i = 0; i<nElementLine; i++) {
        if (elementDown[i].onOffTrigger) {
            if (!elementDown[i].bBeingClick) {
                elementDown[i].triggerColor = 100;
            } else {
                elementDown[i].triggerColor = 0;
            }
            elementDown[i].onOffTrigger = false;
        } else {
            elementDown[i].triggerColor = 0;
        }
        
        if (elementDown[i].soundTrigger&&downPart.bBeingClick) {
            ofFill();
            ofSetColor(ofColor::fromHsb(0,0,230+elementDown[i].triggerColor,155+elementDown[i].triggerColor));
            ofLine(elementDown[i].onOffRectPos+ofVec2f(0,controlRectSize*rectSizeRatio*0.5),
                   elementDown[i].pitchRectPos+ofVec2f(0,-controlRectSize*rectSizeRatio)*0.5);
        } else {
            ofNoFill();
            ofSetColor(ofColor::fromHsb(0,0,230+elementDown[i].triggerColor,50+elementDown[i].triggerColor));
            ofLine(elementDown[i].onOffRectPos+ofVec2f(0,controlRectSize*rectSizeRatio*0.5),
                   elementDown[i].pitchRectPos+ofVec2f(0,-controlRectSize*rectSizeRatio*0.5));
        }
        
        if (!elementDown[i].bBeingClick) {
            ofNoFill();
        } else {
            ofFill();
        }
        ofRect(elementDown[i].onOffRectPos, controlRectSize*rectSizeRatio, controlRectSize*rectSizeRatio);
        ofRect(elementDown[i].pitchRectPos, controlRectSize*rectSizeRatio, controlRectSize*rectSizeRatio);
        
    }
    
    ofPopStyle();
    ofPopMatrix();

}


void ofApp::upPartDraw() {
 
    ofPushMatrix();
    ofTranslate(0, ofGetHeight()/2-controlRectSize*rectSizeRatio);
    
    drawingTempoLine(upPart.bBeingClick, upPart.bLengthOver, upPart.bOnOffOver, upPart.lengthRectPos, upPart.onOffRectPos);
    
    ofPushStyle();
    ofSetRectMode(OF_RECTMODE_CENTER);
    for (int i = 0; i<nElementLine; i++) {
        
        if (elementUp[i].onOffTrigger) {
            if (!elementUp[i].bBeingClick) {
                elementUp[i].triggerColor = 100;
            } else {
                elementUp[i].triggerColor = 0;
            }
            elementUp[i].onOffTrigger = false;
            
        } else {
            elementUp[i].triggerColor = 0;
        }
        
        
        if (elementUp[i].soundTrigger&&upPart.bBeingClick) {
            ofFill();
            ofSetColor(ofColor::fromHsb(0,0,230+elementUp[i].triggerColor,155+elementUp[i].triggerColor));
            ofLine(elementUp[i].onOffRectPos+ofVec2f(0,-controlRectSize*rectSizeRatio*0.5),
                   elementUp[i].pitchRectPos+ofVec2f(0,controlRectSize*rectSizeRatio*0.5));
        } else {
            ofNoFill();
            ofSetColor(ofColor::fromHsb(0,0,230+elementUp[i].triggerColor,50+elementUp[i].triggerColor));
            ofLine(elementUp[i].onOffRectPos+ofVec2f(0,-controlRectSize*rectSizeRatio*0.5),
                   elementUp[i].pitchRectPos+ofVec2f(0,controlRectSize*rectSizeRatio*0.5));
        }
        
        if (!elementUp[i].bBeingClick) {
            ofNoFill();
        } else {
            ofFill();
        }
        
        ofRect(elementUp[i].onOffRectPos, controlRectSize*rectSizeRatio, controlRectSize*rectSizeRatio);
        ofRect(elementUp[i].pitchRectPos, controlRectSize*rectSizeRatio, controlRectSize*rectSizeRatio);
        
    }
    ofPopStyle();
    ofPopMatrix();
    
}



void ofApp::touchGuideLine(){
    
    ofPushStyle();
    
    ofSetColor(ofColor::fromHsb(0,0,255,80));
 
    ofLine(touchPos.x, 0, touchPos.x, ofGetHeight());
    ofLine(0, touchPos.y, ofGetWidth(), touchPos.y);

    ofPopStyle();
}


void ofApp::drawingTempoLine(bool _bTOnOff, bool _bTSizeOver, bool _bTOnOffOver, ofVec2f _vTSizePos, ofVec2f _vTOnOffPos) {
    
    ofPushStyle();
    ofSetRectMode(OF_RECTMODE_CENTER);
    ofSetColor(ofColor::fromHsb(0,0,255,140));
    
    if (_bTOnOff) {
        ofNoFill();
        ofSetColor(ofColor::fromHsb(0,0,255,140));
    } else {
        ofFill();
        ofSetColor(ofColor::fromHsb(0,0,255,40));
    }
    
    ofRect(_vTSizePos, controlRectSize*rectSizeRatio, controlRectSize*rectSizeRatio);
    ofRect(_vTOnOffPos, controlRectSize*rectSizeRatio, controlRectSize*rectSizeRatio);
    ofLine(_vTOnOffPos+ofVec2f(controlRectSize*rectSizeRatio/2,0), _vTSizePos-ofVec2f(controlRectSize*rectSizeRatio/2,0));
    ofPopStyle();
    
}


void ofApp::infomationWindow() {

    ofPushStyle();
    startTime = startTime + 1;
    if (startTime>300) startTime = 301;
    ofSetColor( ofColor::fromHsb(backgroundColorHue, 0, ofMap(startTime,0,300,0,230), ofMap(startTime,0,300,255,0) ) );
    ofRect(0, 0, ofGetWidth(), ofGetHeight());
    ofPopStyle();
    
}

void ofApp::recordingLineDraw(ofVec2f _vP){
    ofPushMatrix();
    ofTranslate(_vP);
    ofPushStyle();
    
    float _colorAlpha = 120;
    
    float _dnColorOn = abs(sin(ofDegToRad(downPart.rectBlockAlphaFactor))*_colorAlpha*0.5);
    float _dnColorOff = abs(sin(ofDegToRad(downPart.rectBlockAlphaFactor))*_colorAlpha*0.2);
    float _dnLineColor = abs(sin(ofDegToRad(downPart.rectBlockAlphaFactor))*_colorAlpha*0.3);

    float _upColorOn = abs(sin(ofDegToRad(upPart.rectBlockAlphaFactor))*_colorAlpha*0.5);
    float _upColorOff = abs(sin(ofDegToRad(upPart.rectBlockAlphaFactor))*_colorAlpha*0.2);
    float _upLineColor = abs(sin(ofDegToRad(upPart.rectBlockAlphaFactor))*_colorAlpha*0.3);

    if (_vP.y == downPart.recBlockPos.y) {
        ofPushStyle();
        if (downPart.bDownSoundRecordClick) {
            downPart.rectBlockAlphaFactor = downPart.rectBlockAlphaFactor + 2.5;
            downPart.soundVolume = 1;
            ofFill();
            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _dnColorOn));
            ofRect( 0,-(recBlockSize-1)/2,recBlockSize-1,recBlockSize-1 );
            ofNoFill();
        } else {
            downPart.rectBlockAlphaFactor = _colorAlpha;
            downPart.soundVolume = 0;
            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _dnColorOff));
            ofRect( 0,-(recBlockSize-1)/2,recBlockSize-1,recBlockSize-1 );
        }
        ofPushStyle();
        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _dnLineColor));
        ofLine(0,-(recBlockSize-1)/2,downPart.onOffRectPos.x-_vP.x-5,ofGetHeight()/2-_vP.y+5+3);
        ofPopStyle();
        ofPopStyle();
    } else {
        ofPushStyle();
        if (upPart.bDownSoundRecordClick) {
            upPart.rectBlockAlphaFactor = upPart.rectBlockAlphaFactor + 2.5;
            upPart.soundVolume = 1;
            ofFill();
            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _upColorOn));
            ofRect(0,-(recBlockSize-1)/2,recBlockSize-1,recBlockSize-1);
            ofNoFill();
        } else {
            upPart.rectBlockAlphaFactor = _colorAlpha;
            upPart.soundVolume = 0;
            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _upColorOff));
            ofRect(0,-(recBlockSize-1)/2,recBlockSize-1,recBlockSize-1);
        }
        ofPushStyle();
        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _upLineColor));
        ofLine(0,(recBlockSize-1)/2,upPart.onOffRectPos.x-_vP.x-5,ofGetHeight()/2-_vP.y-5-3);
        ofPopStyle();
        ofPopStyle();
    }
    ofPopStyle();
    
    for(int i = 0; i < recBlockSize-1; i++){
        ofPushStyle();
        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 220, 150));
        
        ofLine(i, buffer[i] * (recBlockSize-1)/3, i+1, buffer[i+1] * -(recBlockSize-1)/3);
        ofPopStyle();
        
        if ((abs(buffer[i+1]*50.0f)>5)&&!downPart.bDownSoundRecordClick){
            downPart.startTime = ofGetElapsedTimeMillis();
        }
        if ((abs(buffer[i+1]*50.0f)>5)&&!upPart.bDownSoundRecordClick){
            upPart.startTime = ofGetElapsedTimeMillis();
        }
    }
    
    ofPopMatrix();
    
    if (_vP.y == downPart.recBlockPos.y){
        downPart.recordingTime = 1000;
        downPart.timeStamp = ofGetElapsedTimeMillis() - downPart.startTime;
        
        if ((downPart.timeStamp<downPart.recordingTime)){
            if (downPart.recordState==0){
                downPart.recordState=1;
            }
            downPart.bTimerReached = false;
        }
        
        if ((downPart.timeStamp>=downPart.recordingTime)&&!downPart.bTimerReached){
            if (downPart.recordState==3){
                downPart.recordState=2;
            }
            downPart.bTimerReached = true;
            downPart.bDownSoundRecordClick = true;
        }
    } else {
        upPart.recordingTime = 1000;
        upPart.timeStamp = ofGetElapsedTimeMillis() - upPart.startTime;
        
        if ((upPart.timeStamp<upPart.recordingTime)){
            if (upPart.recordState==0){
                upPart.recordState=1;
            }
            upPart.bTimerReached = false;
        }
        
        if ((upPart.timeStamp>=upPart.recordingTime)&&!upPart.bTimerReached){
            if (upPart.recordState==3){
                upPart.recordState=2;
            }
            upPart.bTimerReached = true;
            upPart.bDownSoundRecordClick = true;
        }
    }
}

void ofApp::audioRequested(float *output, int bufferSize, int numChannels) {
    
	startBeatDetected=false;
	int i;
	for(i = 0; i < bufferSize; i++) {
        pos++;
        if(fmod(pos,lengthOfOneBeatInSamples)==0) {
            startBeatDetected=true;
            pos = 0;
        }
    }
    
	if(startBeatDetected){
        
        counterBPM++;

        int _speedFactor8th = 4;
        int _index = counterBPM%32;
        
        for (int i = 0; i<nElementLine; i++) {
            if (_index==((i*_speedFactor8th))) {
                if ((elementDown[i].soundTrigger)&&downPart.bBeingClick) {

                    float _volRandom = ofRandom(0.325,0.95);
                    elementDown[i].samplePlay.setVolume(_volRandom * downPart.soundVolume);
                    
                    float _spdRandom = ofRandom(0.75,1.25);
                    float _spdValueMap = ofMap(elementDown[i].pitchRectPos.y, 0, ofGetHeight()/2, 2.0, 0.4);
                    elementDown[i].samplePlay.setSpeed(_spdValueMap * _spdRandom);
                    
                    elementDown[i].samplePlay.play();
                }
            }
            if (_index==((i*_speedFactor8th)+delayupPart)) {
                if ((elementUp[i].soundTrigger)&&upPart.bBeingClick) {
                    
                    float _volRandom = ofRandom(0.325,0.95);
                    elementUp[i].samplePlay.setVolume(_volRandom * upPart.soundVolume);
                    
                    float _spdRandom = ofRandom(0.75,1.25);
                    float _spdValueMap = ofMap(ofGetHeight()/2+elementUp[i].pitchRectPos.y, ofGetHeight()/2, 0, 2.0, 0.4);
                    elementUp[i].samplePlay.setSpeed(_spdValueMap * _spdRandom);
                
                    elementUp[i].samplePlay.play();
                }
            }
        }

	 }
    
    
}


void ofApp::setBPM(float targetBPM){
	lengthOfOneBeatInSamples = (int)((sampleRate*60.0f)/(targetBPM*8));
	BPM=(sampleRate*60.0f)/lengthOfOneBeatInSamples;
}


void ofApp::audioIn(float * input, int bufferSize, int nChannels){
    
    if (initialBufferSize != bufferSize){
        ofLog(OF_LOG_ERROR, "your buffer size was set to %i - but the stream needs a buffer size of %i", initialBufferSize, bufferSize);
        return;
    }
    
    for (int i = 0; i < bufferSize; i++){
        buffer[i] = input[i];
    }
    bufferCounter++;
    
    if ((downPart.recordState==1)&&(soundRecordingDownOn)){
        downPart.recordState=3;
        downPart.myWavWriter.open(ofToDataPath("sounds/recordingDown.wav"), WAVFILE_WRITE);
    }
    
    if (downPart.recordState==3){
        downPart.myWavWriter.write(input, bufferSize*nChannels);
    }
    
    if (downPart.recordState==2){
        downPart.myWavWriter.close();
        downPart.recordState=0;
        for (int i = 0; i<nElementLine; i++){
            elementDown[i].samplePlay.loadSound("sounds/recordingDown.wav");
        }
    }
    
    if ((upPart.recordState==1)&&(soundRecordingDownOn)){
        upPart.recordState=3;
        upPart.myWavWriter.open(ofToDataPath("sounds/recordingUp.wav"), WAVFILE_WRITE);
    }
    
    if (upPart.recordState==3){
        upPart.myWavWriter.write(input, bufferSize*nChannels);
    }
    
    if (upPart.recordState==2){
        upPart.myWavWriter.close();
        upPart.recordState=0;
        for (int i = 0; i<nElementLine; i++){
            elementUp[i].samplePlay.loadSound("sounds/recordingUp.wav");
        }
    }
    
}


bool ofApp::inOutCal(ofVec2f input, ofVec2f xyN, int distSize){
    float _diffx = abs(input.x - xyN.x);
    float _diffy = abs(input.y - xyN.y);
    float _diff = sqrt(_diffx*_diffx + _diffy*_diffy);
    if (_diff < distSize){
        return true;
    } else {
        return false;
    }
}

bool ofApp::onOffOut(ofVec2f input, ofVec2f xyN, int distSize, bool _b){
    float _diffx = abs(input.x - xyN.x);
    float _diffy = abs(input.y - xyN.y);
    float _diff = sqrt(_diffx*_diffx + _diffy*_diffy);
    if (_diff < distSize){
        return _b = !_b;
    } else {
        return _b = _b;
    }
}


void ofApp::exit(){
    
}


void ofApp::touchDown(ofTouchEventArgs & touch){
    
    ofVec2f _touchCaP = ofVec2f(touch.x-7, touch.y);
    touchPos = _touchCaP;
    
    ofVec2f _yDnInput = ofVec2f(_touchCaP.x, _touchCaP.y - (ofGetHeight()*0.5+controlRectSize*0.5));
    ofVec2f _yUpInput = ofVec2f(_touchCaP.x, _touchCaP.y - (ofGetHeight()*0.5-controlRectSize*0.5));
    ofVec2f _yDnRatioInput = ofVec2f(_touchCaP.x, _touchCaP.y - (ofGetHeight()*0.5+controlRectSize*0.5*1.5));
    ofVec2f _yUpRatioInput = ofVec2f(_touchCaP.x, _touchCaP.y - (ofGetHeight()*0.5-controlRectSize*0.5*1.5));
    
    ofVec2f _dnRecPos = downPart.bDownSoundRecordPos+ofVec2f(recBlockSize/2,recBlockSize/2+1);
    ofVec2f _upRecPos = upPart.bDownSoundRecordPos+ofVec2f(recBlockSize/2,recBlockSize/2+1);
    
    downPart.bBeingClick = onOffOut(_yDnInput, downPart.onOffRectPos, controlRectSize, downPart.bBeingClick);
    downPart.bLengthBeingDragged = inOutCal(_yDnInput, downPart.lengthRectPos, controlRectSize);

    upPart.bBeingClick = onOffOut(_yUpInput, upPart.onOffRectPos, controlRectSize, upPart.bBeingClick);
    upPart.bLengthBeingDragged = inOutCal(_yUpInput, upPart.lengthRectPos, controlRectSize);
    
    downPart.bDownSoundRecordClick = onOffOut(_yDnRatioInput, _dnRecPos, recBlockSize*0.5, downPart.bDownSoundRecordClick);
    upPart.bDownSoundRecordClick = onOffOut(_yDnRatioInput, _upRecPos, recBlockSize*0.5, upPart.bDownSoundRecordClick);
    
    for (int i = 0; i < nElementLine; i++) {
        elementDown[i].bLengthBeingDragged = inOutCal(_yDnRatioInput, elementDown[i].pitchRectPos, controlRectSize);
        elementUp[i].bLengthBeingDragged = inOutCal(_yUpRatioInput, elementUp[i].pitchRectPos, controlRectSize);
        
        if (downPart.bBeingClick) {
            elementDown[i].bBeingClick = onOffOut(_yDnRatioInput, elementDown[i].onOffRectPos, controlRectSize, elementDown[i].bBeingClick);
            elementDown[i].soundTrigger = onOffOut(_yDnRatioInput, elementDown[i].onOffRectPos, controlRectSize, elementDown[i].soundTrigger);
        }
        
        if (upPart.bBeingClick) {
            elementUp[i].bBeingClick = onOffOut(_yUpRatioInput, elementUp[i].onOffRectPos, controlRectSize, elementUp[i].bBeingClick);
            elementUp[i].soundTrigger = onOffOut(_yUpRatioInput, elementUp[i].onOffRectPos, controlRectSize, elementUp[i].soundTrigger);
        }
    }
    
}

void ofApp::touchMoved(ofTouchEventArgs & touch){
    
    ofVec2f _touchCaP = ofVec2f(touch.x-7, touch.y);
    touchPos = _touchCaP;
    
    float _minElementPosY = 79;
    float _maxElementPosY = 20;
    
    for (int i = 0; i < nElementLine; i++){
        if (elementDown[i].bLengthBeingDragged == true){
            if (touch.y<ofGetHeight()*0.5+_minElementPosY){
                touch.y = ofGetHeight()*0.5+_minElementPosY;
            }
            if (touch.y>ofGetHeight()-_maxElementPosY){
                touch.y = ofGetHeight()-_maxElementPosY;
            }
            elementDown[i].pitchRectPos.y = touch.y - ofGetHeight()*0.5-controlRectSize;
        }
    }
    
    for (int i = 0; i < nElementLine; i++){
        if (elementUp[i].bLengthBeingDragged == true){
            if (touch.y>ofGetHeight()*0.5-_minElementPosY) {
                touch.y = ofGetHeight()*0.5-_minElementPosY;
            }
            if (touch.y<_maxElementPosY) {
                touch.y = _maxElementPosY;
            }
            elementUp[i].pitchRectPos.y = touch.y - ofGetHeight()*0.5+controlRectSize;
        }
    }
    
    if (downPart.bLengthBeingDragged == true){
        if (touch.x<630) {
            touch.x = 630;
        }
        if (touch.x>ofGetWidth()-ofGetWidth()*0.11){
            touch.x = ofGetWidth()-ofGetWidth()*0.11;
        }
        downPart.lengthRectPos.x = touch.x;
    }
    
    if (upPart.bLengthBeingDragged == true){
        upPart.position.x = touch.x - (upPart.length*0.5+ofGetWidth()*0.5);
        if (upPart.position.x>49){
            upPart.position.x = 49;
        }
        if (upPart.position.x<-49){
            upPart.position.x = -49;
        }
    }
}


void ofApp::touchUp(ofTouchEventArgs & touch){
    //    downPart.bChangeSampleClick = onOffOut(touch.x, touch.y, downPart.changeSamplePos, 30, downPart.bChangeSampleClick);
    //    upPart.bChangeSampleClick = onOffOut(touch.x, touch.y, upPart.changeSamplePos, 30, upPart.bChangeSampleClick);
    //    if(inOutCal(touch.x, touch.y, downPart.changeSamplePos, 30)) downPart.bChangeSampleClick = false;
    //    if(inOutCal(touch.x, touch.y, upPart.changeSamplePos, 30)) upPart.bChangeSampleClick = false;
}

void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

    ofVec2f _input = ofVec2f(touch.x, touch.y);
    downPart.bChangeSampleClick = onOffOut(_input, downPart.changeSamplePos, 30, downPart.bChangeSampleClick);
    upPart.bChangeSampleClick = onOffOut(_input, upPart.changeSamplePos, 30, upPart.bChangeSampleClick);
    
    if (touch.y>ofGetHeight()*0.5) {
        downPart.bChangeSampleClick = true;
    }
    
    if (touch.y<ofGetHeight()*0.5) {
        upPart.bChangeSampleClick = true;
    }
    
}

void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

void ofApp::lostFocus(){
    
}

void ofApp::gotFocus(){
    
}

void ofApp::gotMemoryWarning(){
    
}

void ofApp::deviceOrientationChanged(int newOrientation){
    
}
