#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetOrientation(OF_ORIENTATION_90_RIGHT);
    ofEnableAlphaBlending();
    ofSetCircleResolution(24);
    
    ofSetFrameRate(60);
    //    ofSetDataPathRoot(ofxiOSGetDocumentsDirectory());
    //    cout << ofxiOSGetDocumentsDirectory() << endl;
    
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
    
    ofSoundStreamSetup(2, 1, this, sampleRate, initialBufferSize, 4);
    //    ofSoundStreamSetup(2, 0, this, sampleRate, initialBufferSize, 4);
    //    soundStream.setup(this, 2, 1, sampleRate, initialBufferSize, 4);
    
    samplePlay0.loadSound("sounds/samples/bell_sample_03.wav");
    samplePlay1.loadSound("sounds/samples/bell_sample_03.wav");
    samplePlay2.loadSound("sounds/samples/bell_sample_03.wav");
    samplePlay3.loadSound("sounds/samples/bell_sample_03.wav");
    samplePlay4.loadSound("sounds/samples/bell_sample_03.wav");
    samplePlay5.loadSound("sounds/samples/bell_sample_03.wav");
    samplePlay6.loadSound("sounds/samples/bell_sample_03.wav");
    samplePlay7.loadSound("sounds/samples/bell_sample_03.wav");
    
    dir.listDir("sounds/samples/");
    dir.sort();
    //    if( dir.size() ){
    //        soundsList.assign(dir.size(), ofSoundPlayer());
    //    }
    //    for(int i = 0; i < (int)dir.size(); i++){
    //        soundsList[i].loadSound(dir.getPath(i));
    //    }
    currentSound = 0;
    
    fileNameUp = "tap_02.wav";
    fileNameDown = "tap_01.wav";
    sampleMainVolume = 0.85;
    
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
    downPart.onOffRectPos.x = -downPart.length*0.5 + ofGetWidth()*0.5;
    downPart.lengthRectPos.x = downPart.length*0.5 + ofGetWidth()*0.5;
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
    upPart.onOffRectPos.x = -upPart.length*0.5 + ofGetWidth()*0.5;
    upPart.lengthRectPos.x = upPart.length*0.5 + ofGetWidth()*0.5;
    upPart.changeSampleSize = 60;
    
    upPart.position.x = upPart.lengthRectPos.x-downPart.lengthRectPos.x;
    upPart.delayPos.x = upPart.length*0.5 + ofGetWidth()*0.5 - upPart.length/(10*2);
    
    nElementLine = 8;
    for (int i = 0; i<nElementLine; i++){
        elementDown[i].bLengthOver = false;
        elementDown[i].bOnOffOver = false;
        elementDown[i].bLengthBeingDragged = false;
        elementDown[i].bBeingClick = false;
        elementDown[i].soundTrigger = true;
        //        elementDown[i].samplePlay.setMultiPlay(true);
        elementDown[i].samplePlay.loadSound(fileNameDown);
        elementDown[i].samplePlay.setVolume(sampleMainVolume);
        spacingLineDown = downPart.length / 10;
        elementDown[i].position = ofVec2f(spacingLineDown + spacingLineDown*0.5 + spacingLineDown*i,
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
        elementUp[i].samplePlay.setVolume(sampleMainVolume);
        spacingLineUp = upPart.length / 10;
        elementUp[i].position = ofVec2f(spacingLineUp + spacingLineUp*0.5 + spacingLineUp*i,
                                        upPart.onOffRectPos.y);
        elementUp[i].pitchRectPos = ofVec2f(elementUp[i].position.x, elementUp[i].position.y-randomY[i+8]);
        elementUp[i].onOffRectPos = elementUp[i].pitchRectPos * ofVec2f(1,-1) + ofVec2f(0,ofGetHeight());
        elementUp[i].width = controlRectSize;
        elementUp[i].triggerColor = 120;
    }
    
    speedTempo = 120.0;
	setBPM(speedTempo);
    
    rectSizeRatio = 0.5;
    
    recBlockSize = initialBufferSize * 0.08;
    
}

//--------------------------------------------------------------
void ofApp::update(){
    
    ofSoundUpdate();
    
    int _speedFactor8th = 4;
    int _index = counterBPM%32;
    int _indexUp = counterBPMUp%32;
    
    for (int i = 0; i<nElementLine; i++) {
        if (_index==((i*_speedFactor8th))) {
            if ((elementDown[i].soundTrigger)&&downPart.bBeingClick) {
                elementDown[i].onOffTrigger = true;
            }
        } else {
            elementDown[i].onOffTrigger = false;
        }
        
        if (_indexUp==((i*_speedFactor8th)+delayupPart)) {
            if ((elementUp[i].soundTrigger)&&upPart.bBeingClick) {
                elementUp[i].onOffTrigger = true;
            }
        } else {
            elementUp[i].onOffTrigger = false;
        }
    }
    
    
    float _recBlockPosCh = recBlockSize * 0.5 + 10;
    downPart.recBlockPos = ofVec2f(downPart.onOffRectPos.x-_recBlockPosCh, ofGetHeight()*0.5+ofGetHeight()*0.1);
    downPart.changeSamplePos = ofVec2f(downPart.lengthRectPos.x, ofGetHeight()*0.5+ofGetHeight()*0.09);
    
    upPart.recBlockPos = ofVec2f(upPart.onOffRectPos.x-_recBlockPosCh, ofGetHeight()*0.5-ofGetHeight()*0.1);
    upPart.changeSamplePos = ofVec2f(upPart.lengthRectPos.x,ofGetHeight()*0.5-ofGetHeight()*0.09);
    
    downPart.length = downPart.lengthRectPos.x - downPart.onOffRectPos.x;
    downPart.onOffRectPos.x = -downPart.length*0.5 + ofGetWidth()*0.5;
    downPart.lengthRectPos.x = downPart.length*0.5 + ofGetWidth()*0.5;
    
    delayupPart = (int)(upPart.position.x)/12;
    
    speedTempo = ofMap(downPart.length/12, 0, 1024/12, 180, 60);
    setTempoMilisecond = ofMap(downPart.length/12, 0, 1024/12, 20, 60);
    setBPM(speedTempo);
    
    spacingLineDown = downPart.length * 0.1;
    spacingLineUp = downPart.length * 0.1;
    
    upPart.lengthRectPos.x = downPart.lengthRectPos.x + spacingLineUp * delayupPart * 0.25;
    upPart.onOffRectPos.x = downPart.onOffRectPos.x + spacingLineUp * delayupPart * 0.25;
    upPart.length = upPart.lengthRectPos.x - upPart.onOffRectPos.x;
    
    for (int i = 0; i<nElementLine; i++){
        elementDown[i].position = ofVec2f(downPart.onOffRectPos.x + spacingLineDown + spacingLineDown*0.5 + spacingLineDown*i,
                                          downPart.onOffRectPos.y);
        elementDown[i].pitchRectPos = ofVec2f(elementDown[i].position.x, elementDown[i].pitchRectPos.y);
        elementDown[i].onOffRectPos = elementDown[i].pitchRectPos * ofVec2f(1,0) + ofVec2f(0,controlRectSize);
        elementUp[i].position.x = elementDown[i].position.x + spacingLineUp * delayupPart * 0.25;
        elementUp[i].pitchRectPos = ofVec2f( elementUp[i].position.x, elementUp[i].pitchRectPos.y );
        elementUp[i].onOffRectPos = elementUp[i].pitchRectPos * ofVec2f(1,0) + ofVec2f(0,-controlRectSize);
    }
    
    
    if ((!upPart.bBeingClick&&!upPart.bDownSoundRecordClick)||downPart.bBeingClick){
        upPart.bDownSoundRecordClick = true;
    }
    if ((!downPart.bBeingClick&&!downPart.bDownSoundRecordClick)||upPart.bBeingClick){
        downPart.bDownSoundRecordClick = true;
    }
    
    downPart.bDownSoundRecordPos = ofVec2f( downPart.recBlockPos.x, downPart.recBlockPos.y-(recBlockSize-1)*0.5 );
    upPart.bDownSoundRecordPos = ofVec2f( upPart.recBlockPos.x, upPart.recBlockPos.y-(recBlockSize-1)*0.5 );
    
    
}


//--------------------------------------------------------------
void ofApp::draw(){
    
    downPartDraw();
    upPartDraw();
    
    if (!upPart.bBeingClick&&downPart.bBeingClick){
        recordingLineDraw(downPart.recBlockPos);
    }
    if (!downPart.bBeingClick&&upPart.bBeingClick){
        recordingLineDraw(upPart.recBlockPos);
    }
    
    
    //    infomationWindow();
    //    touchGuideLine();
    ofDrawBitmapString(ofToString(ofGetFrameRate(),2), 10, 10);
    
}


//--------------------------------------------------------------
void ofApp::downPartDraw(){
    
    ofPushMatrix();
    ofTranslate(0, ofGetHeight()*0.5);
    
    drawingTempoLine(downPart.bBeingClick,downPart.bLengthOver,downPart.bOnOffOver,
                     downPart.lengthRectPos+ofVec2f(0,controlRectSize*0.5),downPart.onOffRectPos+ofVec2f(0,controlRectSize*0.5));
    
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


//--------------------------------------------------------------
void ofApp::upPartDraw() {
    
    ofPushMatrix();
    ofTranslate(0, ofGetHeight()*0.5);
    
    drawingTempoLine(upPart.bBeingClick, upPart.bLengthOver, upPart.bOnOffOver,
                     upPart.lengthRectPos-ofVec2f(0,controlRectSize*0.5), upPart.onOffRectPos-ofVec2f(0,controlRectSize*0.5));
    
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



//--------------------------------------------------------------
void ofApp::touchGuideLine(){
    
    ofPushStyle();
    
    ofSetColor(ofColor::fromHsb(0,0,255,80));
    
    ofLine(touchPos.x, 0, touchPos.x, ofGetHeight());
    ofLine(0, touchPos.y, ofGetWidth(), touchPos.y);
    
    ofPopStyle();
}


//--------------------------------------------------------------
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
    ofLine(_vTOnOffPos+ofVec2f(controlRectSize*rectSizeRatio*0.5, 0), _vTSizePos-ofVec2f(controlRectSize*rectSizeRatio*0.5, 0));
    ofPopStyle();
    
}


//--------------------------------------------------------------
void ofApp::infomationWindow() {
    
    ofPushStyle();
    startTime = startTime + 1;
    if (startTime>300) startTime = 301;
    ofSetColor( ofColor::fromHsb(backgroundColorHue, 0, ofMap(startTime,0,300,0,230), ofMap(startTime,0,300,255,0) ) );
    ofRect(0, 0, ofGetWidth(), ofGetHeight());
    ofPopStyle();
    
}

//--------------------------------------------------------------
void ofApp::recordingLineDraw(ofVec2f _vP){
    
    float _colorAlpha = 120;
    
    float _dnColorOn = abs(sin(ofDegToRad(downPart.rectBlockAlphaFactor))*_colorAlpha*0.5);
    float _dnColorOff = abs(sin(ofDegToRad(downPart.rectBlockAlphaFactor))*_colorAlpha*0.2);
    float _dnLineColor = abs(sin(ofDegToRad(downPart.rectBlockAlphaFactor))*_colorAlpha*0.3);
    
    float _upColorOn = abs(sin(ofDegToRad(upPart.rectBlockAlphaFactor))*_colorAlpha*0.5);
    float _upColorOff = abs(sin(ofDegToRad(upPart.rectBlockAlphaFactor))*_colorAlpha*0.2);
    float _upLineColor = abs(sin(ofDegToRad(upPart.rectBlockAlphaFactor))*_colorAlpha*0.3);
    
    ofPushMatrix();
    ofTranslate(_vP);
    
    ofPushStyle();
    
    if (_vP.y == downPart.recBlockPos.y) {
        ofPushStyle();
        if (downPart.bDownSoundRecordClick) {
            downPart.rectBlockAlphaFactor = downPart.rectBlockAlphaFactor + 2.5;
            downPart.soundVolume = 1;
            ofFill();
            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _dnColorOn));
            ofRect( 0,-(recBlockSize-1)*0.5,recBlockSize-1,recBlockSize-1 );
            ofNoFill();
        } else {
            downPart.rectBlockAlphaFactor = _colorAlpha;
            downPart.soundVolume = 0;
            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _dnColorOff));
            ofRect( 0,-(recBlockSize-1)*0.5,recBlockSize-1,recBlockSize-1 );
        }
        ofPushStyle();
        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _dnLineColor));
        ofLine(0,-(recBlockSize-1)*0.5,downPart.onOffRectPos.x-_vP.x-5,ofGetHeight()*0.5-_vP.y+5+3);
        ofPopStyle();
        ofPopStyle();
    } else {
        ofPushStyle();
        if (upPart.bDownSoundRecordClick) {
            upPart.rectBlockAlphaFactor = upPart.rectBlockAlphaFactor + 2.5;
            upPart.soundVolume = 1;
            ofFill();
            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _upColorOn));
            ofRect(0,-(recBlockSize-1)*0.5,recBlockSize-1,recBlockSize-1);
            ofNoFill();
        } else {
            upPart.rectBlockAlphaFactor = _colorAlpha;
            upPart.soundVolume = 0;
            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _upColorOff));
            ofRect(0,-(recBlockSize-1)*0.5,recBlockSize-1,recBlockSize-1);
        }
        ofPushStyle();
        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _upLineColor));
        ofLine(0,(recBlockSize-1)*0.5,upPart.onOffRectPos.x-_vP.x-5,ofGetHeight()*0.5-_vP.y-5-3);
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



//--------------------------------------------------------------
void ofApp::audioRequested(float *output, int bufferSize, int nChannels) {
    
	for(int i = 0; i < bufferSize*nChannels; i++) {
        pos++;
        if(fmod(pos,lengthOfOneBeatInSamples)==0) {
            startBeatDetected=true;
            pos = 0;
            counterBPM++;
            counterBPMUp++;
        }
    }
    
        int _speedFactor8th = 4;
        int _index = counterBPM%32;
        
        int indexBPM = counterBPM%32;
        int _indexUp = counterBPMUp%32+delayupPart;
        
        for (int i = 0; i<nElementLine; i++) {
            if (_index==((i*_speedFactor8th))) {
                if ((elementDown[i].soundTrigger)&&downPart.bBeingClick) {
                    float _volRandom = ofRandom(0.35,1.0);
                    elementDown[i].samplePlay.setVolume(_volRandom * downPart.soundVolume * sampleMainVolume);
                    
                    float _spdRandom = ofRandom(0.75,1.25);
                    float _spdValueMap = ofMap(elementDown[i].pitchRectPos.y, 0, ofGetHeight()*0.5, 2.3, 0.45);
                    float _value = _spdValueMap * _spdRandom;
                    elementDown[i].samplePlay.setSpeed(_value);
                    if (startBeatDetected) {
                        elementDown[i].samplePlay.play();
                    }
                    testCounter++;
                    cout << testCounter << endl;
                }
            }
            if (_index==((i*_speedFactor8th)+delayupPart)) {
                if ((elementUp[i].soundTrigger)&&upPart.bBeingClick) {
                    float _volRandom = ofRandom(0.35,1.0);
                    elementUp[i].samplePlay.setVolume(_volRandom * upPart.soundVolume * sampleMainVolume);
                    
                    float _spdRandom = ofRandom(0.75,1.25);
                    float _spdValueMap = ofMap(ofGetHeight()*0.5+elementUp[i].pitchRectPos.y, ofGetHeight()*0.5, 0, 2.3, 0.45);
                    float _value = _spdValueMap * _spdRandom;
                    elementUp[i].samplePlay.setSpeed(_value);
                    if (startBeatDetected) {
                        elementUp[i].samplePlay.play();
                    }
                }
            }
        }
        
        startBeatDetected=false;

        
//    }
    
    
}


//--------------------------------------------------------------
void ofApp::audioReceived(float * input, int bufferSize, int nChannels) {
    
    if (initialBufferSize != bufferSize){
        ofLog(OF_LOG_ERROR, "your buffer size was set to %i - but the stream needs a buffer size of %i", initialBufferSize, bufferSize);
        return;
    }
    
    for (int i = 0; i < bufferSize; i++){
        buffer[i] = input[i];
    }
    
    if ((downPart.recordState==1)&&(soundRecordingDownOn)){
        downPart.recordState=3;
        downPart.myWavWriter.open(ofxiOSGetDocumentsDirectory() + "recordingDown.wav", WAVFILE_WRITE);
    }
    
    if (downPart.recordState==3){
        downPart.myWavWriter.write(input, bufferSize*nChannels);
    }
    
    if (downPart.recordState==2){
        downPart.myWavWriter.close();
        downPart.recordState=0;
        for (int i = 0; i<nElementLine; i++){
            elementDown[i].samplePlay.loadSound(ofxiOSGetDocumentsDirectory() + "recordingDown.wav");
        }
    }
    
    if ((upPart.recordState==1)&&(soundRecordingDownOn)){
        upPart.recordState=3;
        upPart.myWavWriter.open(ofxiOSGetDocumentsDirectory() + "recordingUp.wav", WAVFILE_WRITE);
    }
    
    if (upPart.recordState==3){
        upPart.myWavWriter.write(input, bufferSize*nChannels);
    }
    
    if (upPart.recordState==2){
        upPart.myWavWriter.close();
        upPart.recordState=0;
        for (int i = 0; i<nElementLine; i++){
            elementUp[i].samplePlay.loadSound(ofxiOSGetDocumentsDirectory() + "recordingUp.wav");
        }
    }
    
}


//--------------------------------------------------------------
void ofApp::setBPM(float targetBPM) {
    
	lengthOfOneBeatInSamples = (int)((sampleRate*60.0f)/(targetBPM*4));
	BPM=(sampleRate*60.0f)/lengthOfOneBeatInSamples;
    
}




//--------------------------------------------------------------
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

//--------------------------------------------------------------
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



//--------------------------------------------------------------
void ofApp::exit(){
    
    buffer = NULL;
    
}


//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
    ofVec2f _touchCaP = ofVec2f(touch.x-7, touch.y);
    touchPos = _touchCaP;
    
    ofVec2f _yDnInput = ofVec2f(_touchCaP.x, _touchCaP.y - (ofGetHeight()*0.5));
    ofVec2f _yUpInput = ofVec2f(_touchCaP.x, _touchCaP.y - (ofGetHeight()*0.5));
    
    ofVec2f _dnRecPos = downPart.bDownSoundRecordPos+ofVec2f(recBlockSize*0.5, recBlockSize*0.5)+ofVec2f(0,-(ofGetHeight()*0.5));
    ofVec2f _upRecPos = upPart.bDownSoundRecordPos+ofVec2f(recBlockSize*0.5, recBlockSize*0.5)+ofVec2f(0,-(ofGetHeight()*0.5));
    
    ofVec2f _yDnInputForCtrl = ofVec2f(_touchCaP.x, _touchCaP.y - (ofGetHeight()*0.5)-controlRectSize);
    ofVec2f _yUpInputForCtrl = ofVec2f(_touchCaP.x, _touchCaP.y - (ofGetHeight()*0.5)+controlRectSize);
    
    downPart.bBeingClick = onOffOut(_yDnInputForCtrl, downPart.onOffRectPos, controlRectSize, downPart.bBeingClick);
    downPart.bLengthBeingDragged = inOutCal(_yDnInputForCtrl, downPart.lengthRectPos, controlRectSize);
    
    upPart.bBeingClick = onOffOut(_yUpInputForCtrl, upPart.onOffRectPos, controlRectSize, upPart.bBeingClick);
    upPart.bLengthBeingDragged = inOutCal(_yUpInputForCtrl, upPart.lengthRectPos, controlRectSize);
    
    downPart.bDownSoundRecordClick = onOffOut(_yDnInput, _dnRecPos, recBlockSize, downPart.bDownSoundRecordClick);
    upPart.bDownSoundRecordClick = onOffOut(_yUpInput, _upRecPos, recBlockSize, upPart.bDownSoundRecordClick);
    
    for (int i = 0; i < nElementLine; i++) {
        elementDown[i].bLengthBeingDragged = inOutCal(_yDnInput, elementDown[i].pitchRectPos, controlRectSize);
        elementUp[i].bLengthBeingDragged = inOutCal(_yUpInput, elementUp[i].pitchRectPos, controlRectSize);
        
        if (downPart.bBeingClick) {
            elementDown[i].bBeingClick = onOffOut(_yDnInput, elementDown[i].onOffRectPos, controlRectSize, elementDown[i].bBeingClick);
            elementDown[i].soundTrigger = onOffOut(_yDnInput, elementDown[i].onOffRectPos, controlRectSize, elementDown[i].soundTrigger);
        }
        
        if (upPart.bBeingClick) {
            elementUp[i].bBeingClick = onOffOut(_yUpInput, elementUp[i].onOffRectPos, controlRectSize, elementUp[i].bBeingClick);
            elementUp[i].soundTrigger = onOffOut(_yUpInput, elementUp[i].onOffRectPos, controlRectSize, elementUp[i].soundTrigger);
        }
    }
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    
    ofVec2f _touchCaP = ofVec2f(touch.x-7, touch.y);
    touchPos = _touchCaP;
    
    float _minElementPosY = 57;
    float _maxElementPosY = 20;
    
    for (int i = 0; i < nElementLine; i++){
        if (elementDown[i].bLengthBeingDragged == true){
            if (touch.y<ofGetHeight()*0.5+_minElementPosY){
                touch.y = ofGetHeight()*0.5+_minElementPosY;
            }
            if (touch.y>ofGetHeight()-_maxElementPosY){
                touch.y = ofGetHeight()-_maxElementPosY;
            }
            elementDown[i].pitchRectPos.y = touch.y - ofGetHeight()*0.5;
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
            elementUp[i].pitchRectPos.y = touch.y - ofGetHeight()*0.5;
        }
    }
    
    if (downPart.bLengthBeingDragged == true){
        if (touch.x<657) {
            touch.x = 657;
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


//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    //    downPart.bChangeSampleClick = onOffOut(touch.x, touch.y, downPart.changeSamplePos, 30, downPart.bChangeSampleClick);
    //    upPart.bChangeSampleClick = onOffOut(touch.x, touch.y, upPart.changeSamplePos, 30, upPart.bChangeSampleClick);
    //    if(inOutCal(touch.x, touch.y, downPart.changeSamplePos, 30)) downPart.bChangeSampleClick = false;
    //    if(inOutCal(touch.x, touch.y, upPart.changeSamplePos, 30)) upPart.bChangeSampleClick = false;
}


//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    
    ofVec2f _input = ofVec2f(touch.x, touch.y);
    if (touch.x>ofGetWidth()-70) {
        downPart.bChangeSampleClick = onOffOut(_input, downPart.changeSamplePos, 30, downPart.bChangeSampleClick);
        upPart.bChangeSampleClick = onOffOut(_input, upPart.changeSamplePos, 30, upPart.bChangeSampleClick);
        
        if (touch.y>ofGetHeight()*0.5) {
            downPart.bChangeSampleClick = true;
        }
        
        if (touch.y<ofGetHeight()*0.5) {
            upPart.bChangeSampleClick = true;
        }
        
        if (upPart.bChangeSampleClick){
            upPart.changeSampleIndex++;
            upPart.changeSampleIndex = upPart.changeSampleIndex%dir.size();
            for (int i = 0; i<nElementLine; i++){
                string fileNameUp = "sounds/samples/" + dir.getName(upPart.changeSampleIndex);
                elementUp[i].samplePlay.loadSound(fileNameUp);
            }
            upPart.bChangeSampleClick = !upPart.bChangeSampleClick;
        }
        
        if (downPart.bChangeSampleClick){
            downPart.changeSampleIndex++;
            downPart.changeSampleIndex = downPart.changeSampleIndex%dir.size();
            for (int i = 0; i<nElementLine; i++){
                string fileNameDown = "sounds/samples/" + dir.getName(downPart.changeSampleIndex);
                elementDown[i].samplePlay.loadSound(fileNameDown);
            }
            downPart.bChangeSampleClick = !downPart.bChangeSampleClick;
        }
    }
    
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
}
