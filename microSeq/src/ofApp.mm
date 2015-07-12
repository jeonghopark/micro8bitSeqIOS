#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetOrientation(OF_ORIENTATION_90_RIGHT);
    
    ofEnableAlphaBlending();
    ofSetCircleResolution(24);
    
    ofSetFrameRate(60);
    
    screenW = 2048;
    screenH = 2048 * 3.0 / 4.0;
    
    synthSetting();
    maxSpeed = 80;
    minSpeed = 20;
    bpm = synthMain.addParameter("tempo", 100).min(minSpeed).max(maxSpeed);
    metro = ControlMetro().bpm(4 * bpm);
    metroOut = synthMain.createOFEvent(metro);
    //    synthMain.setOutputGen();
    
    index = 0;
    
    ofAddListener(* metroOut, this, &ofApp::triggerReceive);
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        menuStartRectSize = 40 * 2;
        menuStartRectSpacing = 10 * 2;

        ctrlRectSize = 22 * 2;

        maxLine = screenW * 0.85;
        minLine = screenW * 0.67;
        
        downPart.length = screenW * 0.5;
        
    } else {
        menuStartRectSize = ofGetWidth() / 51.2*4;
        menuStartRectSpacing = ofGetWidth() / 204.8*4;
        
        ctrlRectSize = 22 * 2;

        maxLine = screenW * 0.85;
        minLine = screenW * 0.67;
        
        downPart.length = screenW * 0.5;
    }
    
    
    ofxAccelerometer.setup();
    ofxMultiTouch.addListener(this);
    
    backgroundColorHue = ofRandom(0,255);
    ofBackground(ofColor::fromHsb(backgroundColorHue, 150, 180));
    
    initialBufferSize = 256;
    sampleRate = 44100;
    drawCounter = 0;
    buffer = new float[initialBufferSize];
    memset(buffer, 0, initialBufferSize * sizeof(float));
    
    //    ofSoundStreamSetup(2, 0, this, sampleRate, initialBufferSize, 4);
    
    dir.listDir("sounds/samples/");
    dir.sort();
    
    fileNameUp = "sounds/samples/tap_02.wav";
    fileNameDown = "sounds/samples/tap_01.wav";
    sampleMainVolume = 0.85;
    
    startTime = ofGetElapsedTimef();
    
    
    sampleRecordingTime = 320;
    
    bMainStartStop = true;
    mainTempo = 1;
    
    for (int i=0; i<16; i++) {
        randomY[i] = ofRandom(50 * 2, screenH * 2/5);
    }
    
    //    downPart.length = ofGetWidth()*4/8;
    downPart.bBeingClick = true;
    downPart.bTimerReached = true;
    downPart.bDownSoundRecordClick = false;
    downPart.bChangeSampleClick = false;
    downPart.bChangeSampleOver = false;
    downPart.startTime = ofGetElapsedTimef() - sampleRecordingTime;
    downPart.rectBlockAlphaFactor = 0;
    downPart.recordState=0;
    downPart.soundVolume = 1;
    downPart.changeSampleIndex = 0;
    downPart.myWavWriter.setFormat(1, sampleRate, 16);
    downPart.onOffPos.x = -downPart.length*0.5 + screenW * 0.5;
    downPart.lengthPos.x = downPart.length*0.5 + screenW * 0.5;
    
    upPart.length = downPart.length;
    upPart.bBeingClick = true;
    upPart.bTimerReached = true;
    upPart.bDownSoundRecordClick = false;
    upPart.bChangeSampleClick = false;
    upPart.bChangeSampleOver = false;
    upPart.startTime = ofGetElapsedTimef() - sampleRecordingTime;
    upPart.rectBlockAlphaFactor = 0;
    upPart.recordState=0;
    upPart.soundVolume = 1;
    upPart.changeSampleIndex = 0;
    upPart.myWavWriter.setFormat(1, sampleRate, 16);
    upPart.onOffPos.x = -upPart.length*0.5 + screenW * 0.5;
    upPart.lengthPos.x = upPart.length*0.5 + screenW * 0.5;
    
    upPart.position.x = upPart.lengthPos.x-downPart.lengthPos.x;
    upPart.delayPos.x = upPart.length * 0.5 + screenW * 0.5 - upPart.length/(10*2);
    
    nElementLine = 8;
    for (int i = 0; i<nElementLine; i++) {
        elementDown[i].bLengthOver = false;
        elementDown[i].bOnOffOver = false;
        elementDown[i].bLengthBeingDragged = false;
        elementDown[i].bBeingClick = false;
        elementDown[i].soundTrigger = true;
        elementDown[i].onOffTrigger = true;
        elementDown[i].samplePlay.load(fileNameDown);
        elementDown[i].samplePlay.setVolume(sampleMainVolume);
        elementDown[i].samplePlay.setLoop(false);
        spacingLineDown = downPart.length / 10;
        elementDown[i].position = ofVec2f(spacingLineDown + spacingLineDown * 0.5 + spacingLineDown*i,
                                          downPart.onOffPos.y);
        elementDown[i].pitchPos = ofVec2f(elementDown[i].position.x, elementDown[i].position.y + randomY[i]);
        elementDown[i].onOffPos = elementDown[i].pitchPos * ofVec2f(1, -1) + ofVec2f(0, screenH);
        elementDown[i].triggerColor = 120;
        
        elementUp[i].bLengthOver = false;
        elementUp[i].bOnOffOver = false;
        elementUp[i].bLengthBeingDragged = false;
        elementUp[i].bBeingClick = false;
        elementUp[i].soundTrigger = true;
        elementUp[i].onOffTrigger = true;
        elementUp[i].samplePlay.load(fileNameUp);
        elementUp[i].samplePlay.setVolume(sampleMainVolume);
        elementUp[i].samplePlay.setLoop(false);
        spacingLineUp = upPart.length / 10;
        elementUp[i].position = ofVec2f(spacingLineUp + spacingLineUp * 0.5 + spacingLineUp*i,
                                        upPart.onOffPos.y);
        elementUp[i].pitchPos = ofVec2f(elementUp[i].position.x, elementUp[i].position.y - randomY[i+8]);
        elementUp[i].onOffPos = elementUp[i].pitchPos * ofVec2f(1,-1) + ofVec2f(0, screenH);
        elementUp[i].triggerColor = 120;
    }
    
    rectSizeRatio = 0.5;
    
    recBlockSize = initialBufferSize * 0.5;
    
    tempo = ofMap( downPart.length, maxLine, minLine, minSpeed, maxSpeed );
    
    
    menuSetting();
    
    minRecordRectPosX = screenW * 0.1347;
    
    debugMode = false;
    
    volumeParameter = screenW * 0.05;
    
    threadDownCounter = 0;
    threadUpCounter = 0;
    indexCounterDn = 0;
    indexCounterUp = 0;
    
    dnIndex = 0;
    upIndex = 0;
    
    
    delayValueSaved = 0;
    delayupPart = 0;
    
    tempoValueSaved = 0;
    
    ofSoundStreamSetup(2, 0, this, 44100, 256, 4);
    
}


//--------------------------------------------------------------
void ofApp::update(){
    
    float _recBlockPosCh = recBlockSize;
    
    downPart.recBlockPos = ofVec2f(downPart.onOffPos.x - _recBlockPosCh, screenH * 0.5 + screenH * 0.1);
    downPart.changeSamplePos = ofVec2f(downPart.lengthPos.x, screenH * 0.5 + screenH * 0.09);
    
    if (upPart.onOffPos.x > minRecordRectPosX) {
        upPart.recBlockPos = ofVec2f(upPart.onOffPos.x - _recBlockPosCh, screenH * 0.5 - screenH*0.1);
    } else {
        upPart.recBlockPos = ofVec2f(minRecordRectPosX-_recBlockPosCh, screenH * 0.5- screenH*0.1);
    }
    
    upPart.changeSamplePos = ofVec2f(upPart.lengthPos.x, screenH * 0.5 - screenH * 0.09);
    
    downPart.length = downPart.lengthPos.x - downPart.onOffPos.x;
    downPart.onOffPos.x = -downPart.length*0.5 + screenW * 0.5;
    downPart.lengthPos.x = downPart.length*0.5 + screenW * 0.5;
    
    //    delayupPart = (int)(upPart.position.x)/24;
    
    tempo = ofMap( downPart.length, maxLine, minLine, minSpeed, maxSpeed );
    synthMain.setParameter("tempo", tempo);
    
    
    
    spacingLineDown = downPart.length / 10;
    spacingLineUp = downPart.length / 10;
    
    upPart.lengthPos.x = downPart.lengthPos.x + spacingLineUp * delayupPart * 0.5;
    upPart.onOffPos.x = downPart.onOffPos.x + spacingLineUp * delayupPart * 0.5;
    upPart.length = upPart.lengthPos.x - upPart.onOffPos.x;
    
    for (int i = 0; i<nElementLine; i++){
        elementDown[i].position = ofVec2f( downPart.onOffPos.x + spacingLineDown + spacingLineDown/2 + spacingLineDown*i, downPart.onOffPos.y );
        elementDown[i].pitchPos = ofVec2f( elementDown[i].position.x, elementDown[i].pitchPos.y );
        elementDown[i].onOffPos = elementDown[i].pitchPos * ofVec2f(1,0) + ofVec2f(0,ctrlRectSize);
        elementUp[i].position.x = elementDown[i].position.x + spacingLineUp * delayupPart * 0.5;
        elementUp[i].pitchPos = ofVec2f( elementUp[i].position.x, elementUp[i].pitchPos.y );
        elementUp[i].onOffPos = elementUp[i].pitchPos * ofVec2f(1,0) + ofVec2f(0,-ctrlRectSize);
    }
    
    if ((!upPart.bBeingClick&&!upPart.bDownSoundRecordClick)||downPart.bBeingClick){
        upPart.bDownSoundRecordClick = true;
    }
    if ((!downPart.bBeingClick&&!downPart.bDownSoundRecordClick)||upPart.bBeingClick){
        downPart.bDownSoundRecordClick = true;
    }
    
    downPart.bDownSoundRecordPos = ofVec2f( downPart.recBlockPos.x, downPart.recBlockPos.y-(recBlockSize-1)*0.5 );
    upPart.bDownSoundRecordPos = ofVec2f( upPart.recBlockPos.x, upPart.recBlockPos.y-(recBlockSize-1)*0.5 );
    
    waveRecordPos = ofVec2f( downPart.onOffPos.x-menuStartRectSize+ctrlRectSize*0.5*0.5, ofGetHeight()*0.5-menuStartRectSize*0.5 );
    
}


//--------------------------------------------------------------
void ofApp::triggerReceive(float & metro){
    
    threadDownCounter++;
    threadUpCounter++;
    
    threadDownCounter %= 2;
    threadUpCounter %= 2;

    phraseComplete();
    
    
}


//--------------------------------------------------------------
void ofApp::phraseComplete(){
    
    
    int _indexMatch;
    int _shiftMinIndex;
    int _shiftMaxIndex;
    switch (delayupPart) {
        case 0:
            _indexMatch = 0;
            _shiftMinIndex = 0;
            _shiftMaxIndex = 7;
            indexCounterUp = indexCounterDn;
            break;

        case 1:
            _indexMatch = 1;
            _shiftMinIndex = 0;
            _shiftMaxIndex = 6;
            break;

        case 2:
            _indexMatch = 0;
            _shiftMinIndex = 0;
            _shiftMaxIndex = 5;
            break;

        case -1:
            _indexMatch = 1;
            _shiftMinIndex = 1;
            _shiftMaxIndex = 7;
            break;

        case -2:
            _indexMatch = 0;
            _shiftMinIndex = 2;
            _shiftMaxIndex = 7;
            break;

        default:
            break;
    }
    
    
    if ((threadDownCounter) == 0) {
        if (bMainStartStop) {
            indexCounterDn++;
            
            dnIndex = indexCounterDn % 8;
            
            if ((elementDown[dnIndex].soundTrigger) && downPart.bBeingClick){
                elementDown[dnIndex].onOffTrigger = true;
                elementDown[dnIndex].samplePlay.play();
                float _volRandom = ofRandom(0.35,1.0);
                elementDown[dnIndex].samplePlay.setVolume(_volRandom * downPart.soundVolume * sampleMainVolume);
                
                float _spdRandom = ofRandom(0.75,1.25);
                float _spdValueMap = ofMap(elementDown[dnIndex].pitchPos.y, 0, ofGetHeight()*0.5, 2.3, 0.45);
                float _value = _spdValueMap * _spdRandom;
                elementDown[dnIndex].samplePlay.setSpeed(_value);
            }
        }
    }
    
    if ((threadDownCounter) == _indexMatch) {
        if (bMainStartStop) {
            indexCounterUp++;
            
            upIndex = (indexCounterUp) % 8;
            upIndex = ofClamp(upIndex, _shiftMinIndex, _shiftMaxIndex);
            
            if ((elementUp[upIndex].soundTrigger) && upPart.bBeingClick){
                elementUp[upIndex].onOffTrigger = true;
                elementUp[upIndex].samplePlay.play();
                float _volRandom = ofRandom(0.35,1.0);
                elementUp[upIndex].samplePlay.setVolume(_volRandom * upPart.soundVolume * sampleMainVolume);
                
                float _spdRandom = ofRandom(0.75,1.25);
                float _spdValueMap = ofMap(ofGetHeight()*0.5+elementUp[upIndex].pitchPos.y, ofGetHeight()*0.5, 0, 2.3, 0.45);
                float _value = _spdValueMap * _spdRandom;
                elementUp[upIndex].samplePlay.setSpeed(_value);
            }
        }
    }
    
}

////--------------------------------------------------------------
//int ofApp::calculateNoteDuration() {
//
//    return (int)floor( 60000.0000f / tempo );
//
//}



//--------------------------------------------------------------
void ofApp::draw(){
    
    downPartDraw();
    upPartDraw();
    
    if (bWaveRect){
        recordingLineDraw(waveRecordPos-menuStartRectSize);
    }
    
    recordDraw();
    sampleChangeDraw();
    stopStartDraw();
    
}


//--------------------------------------------------------------
void ofApp::downPartDraw(){
    
    ofPushMatrix();
    ofTranslate(0, ofGetHeight()*0.5);
    
    drawMainLine(downPart.bBeingClick, downPart.bLengthOver, downPart.bOnOffOver,
                     downPart.lengthPos + ofVec2f(0, ctrlRectSize * 0.5), downPart.onOffPos + ofVec2f(0, ctrlRectSize * 0.5));
    
    ofPushStyle();
    ofSetRectMode(OF_RECTMODE_CENTER);
    
    float _size = ctrlRectSize * rectSizeRatio;
    
    if (elementDown[dnIndex].onOffTrigger) {
        if (!elementDown[dnIndex].bBeingClick) {
            elementDown[dnIndex].triggerColor = 100;
        } else {
            elementDown[dnIndex].triggerColor = 0;
        }
        elementDown[dnIndex].onOffTrigger = false;
    } else {
        elementDown[dnIndex].triggerColor = 0;
    }
    
    
    float _brightness = 255 + elementDown[dnIndex].triggerColor;
    float _alpha;
    if (elementDown[dnIndex].soundTrigger && downPart.bBeingClick) {
        ofFill();
        _alpha = 200 + elementDown[dnIndex].triggerColor;
        ofSetColor( ofColor::fromHsb(0, 0, 255 + _brightness, _alpha) );
        ofDrawLine(elementDown[dnIndex].onOffPos + ofVec2f(0, _size * 0.5),
                   elementDown[dnIndex].pitchPos + ofVec2f(0, -_size) * 0.5);
    } else {
        ofNoFill();
        _alpha = 0;
        ofSetColor( ofColor::fromHsb(0, 0, _brightness, _alpha) );
        //        ofDrawLine(elementDown[dnIndex].onOffPos+ofVec2f(0,ctrlRectSize*rectSizeRatio*0.5),
        //        elementDown[dnIndex].pitchPos+ofVec2f(0,-ctrlRectSize*rectSizeRatio*0.5));
    }
    
    if (!elementDown[dnIndex].bBeingClick) {
        ofNoFill();
        _alpha = 170 + elementDown[dnIndex].triggerColor;
        ofSetColor( ofColor::fromHsb(0, 0, _brightness, _alpha) );
    } else {
        //        ofFill();
        //        ofSetColor(ofColor::fromHsb(0,0,255+elementDown[dnIndex].triggerColor,30+elementDown[dnIndex].triggerColor));
    }
    ofDrawRectangle(elementDown[dnIndex].onOffPos, _size, _size);
    ofDrawRectangle(elementDown[dnIndex].pitchPos, _size, _size);
    
    ofPopStyle();
    
    ofPushStyle();
    ofSetRectMode(OF_RECTMODE_CENTER);
    
    for (int i = 0; i<nElementLine; i++) {
        
        if (elementDown[i].soundTrigger&&downPart.bBeingClick) {
            ofFill();
            ofSetColor(ofColor::fromHsb(0,0,255,150));
            ofDrawLine(elementDown[i].onOffPos+ofVec2f(0, _size*0.5),
                       elementDown[i].pitchPos+ofVec2f(0, -_size)*0.5);
        } else {
            ofNoFill();
            ofSetColor(ofColor::fromHsb(0,0,255,60));
            ofDrawLine(elementDown[i].onOffPos+ofVec2f(0, _size*0.5),
                       elementDown[i].pitchPos+ofVec2f(0, -_size*0.5));
        }
        
        if (!elementDown[i].bBeingClick) {
            ofNoFill();
            ofSetColor(ofColor::fromHsb(0,0,255,120));
        } else {
            ofFill();
            ofSetColor(ofColor::fromHsb(0,0,255,30));
        }
        ofDrawRectangle(elementDown[i].onOffPos, _size, _size);
        ofDrawRectangle(elementDown[i].pitchPos, _size, _size);
        
        debugModeView(i, "down");
        
    }
    
    ofPopStyle();
    
    ofPopMatrix();
    
}


//--------------------------------------------------------------
void ofApp::upPartDraw() {
    
    ofPushMatrix();
    ofTranslate(0, ofGetHeight()*0.5);
    
    drawMainLine(upPart.bBeingClick, upPart.bLengthOver, upPart.bOnOffOver,
                     downPart.lengthPos - ofVec2f(0, ctrlRectSize * 0.5), downPart.onOffPos - ofVec2f(0, ctrlRectSize * 0.5));
    
    ofPushStyle();
    ofSetRectMode(OF_RECTMODE_CENTER);
    
    float _size = ctrlRectSize * rectSizeRatio;
    
    
    if (elementUp[upIndex].onOffTrigger) {
        if (!elementUp[upIndex].bBeingClick) {
            elementUp[upIndex].triggerColor = 100;
        } else {
            elementUp[upIndex].triggerColor = 0;
        }
        elementUp[upIndex].onOffTrigger = false;
    } else {
        elementUp[upIndex].triggerColor = 0;
    }
    
    float _brightness = 255 + elementUp[upIndex].triggerColor;
    float _alpha;
    if (elementUp[upIndex].soundTrigger && upPart.bBeingClick) {
        ofFill();
        _alpha = 200 + elementUp[upIndex].triggerColor;
        ofSetColor( ofColor::fromHsb(0, 0, 255 + _brightness, _alpha) );
        ofDrawLine( elementUp[upIndex].onOffPos + ofVec2f(0, -_size * 0.5),
                   elementUp[upIndex].pitchPos + ofVec2f(0, _size * 0.5) );
    } else {
        ofNoFill();
        _alpha = 0;
        ofSetColor( ofColor::fromHsb(0, 0, _brightness, _alpha) );
        //        ofDrawLine(elementDown[upIndex].onOffPos+ofVec2f(0,ctrlRectSize*rectSizeRatio*0.5),
        //        elementUp[dnIndex].pitchPos+ofVec2f(0,-ctrlRectSize*rectSizeRatio*0.5));
    }
    
    if (!elementUp[upIndex].bBeingClick) {
        ofNoFill();
        _alpha = 170 + elementUp[upIndex].triggerColor;
        ofSetColor( ofColor::fromHsb(0, 0, _brightness, _alpha) );
    } else {
        //        ofFill();
        //        ofSetColor(ofColor::fromHsb(0,0,255+elementDown[dnIndex].triggerColor,30+elementDown[dnIndex].triggerColor));
    }
    
    
    //    if (elementUp[upIndex].soundTrigger&&upPart.bBeingClick) {
    //        ofFill();
    //        ofSetColor(ofColor::fromHsb(0,0,255+elementUp[upIndex].triggerColor,200+elementUp[upIndex].triggerColor));
    //        ofDrawLine(elementUp[upIndex].onOffPos+ofVec2f(0,-ctrlRectSize*rectSizeRatio*0.5),
    //                   elementUp[upIndex].pitchPos+ofVec2f(0,ctrlRectSize*rectSizeRatio*0.5));
    //    } else {
    //        ofNoFill();
    //        ofSetColor(ofColor::fromHsb(0,0,255+elementUp[upIndex].triggerColor,0));
    //        //        ofDrawLine(elementUp[upIndex].onOffPos+ofVec2f(0,-ctrlRectSize*rectSizeRatio*0.5),
    //        //        elementUp[upIndex].pitchPos+ofVec2f(0,ctrlRectSize*rectSizeRatio*0.5));
    //    }
    //
    //    if (!elementUp[upIndex].bBeingClick) {
    //        ofNoFill();
    //        ofSetColor(ofColor::fromHsb(0,0,255+elementUp[upIndex].triggerColor,170+elementUp[upIndex].triggerColor));
    //    } else {
    //        //        ofFill();
    //        //        ofSetColor(ofColor::fromHsb(0,0,255+elementUp[upIndex].triggerColor,30+elementUp[upIndex].triggerColor));
    //    }
    
    ofDrawRectangle(elementUp[upIndex].onOffPos, _size, _size);
    ofDrawRectangle(elementUp[upIndex].pitchPos, _size, _size);
    ofPopStyle();
    
    
    ofPushStyle();
    ofSetRectMode(OF_RECTMODE_CENTER);
    
    for (int i = 0; i<nElementLine; i++) {
        
        if (elementUp[i].soundTrigger&&upPart.bBeingClick) {
            ofFill();
            ofSetColor(ofColor::fromHsb(0,0,255,150));
            ofDrawLine(elementUp[i].onOffPos+ofVec2f(0, -_size*0.5),
                       elementUp[i].pitchPos+ofVec2f(0, _size*0.5));
        } else {
            ofNoFill();
            ofSetColor(ofColor::fromHsb(0,0,255,60));
            ofDrawLine(elementUp[i].onOffPos+ofVec2f(0, -_size*0.5),
                       elementUp[i].pitchPos+ofVec2f(0, _size*0.5));
        }
        
        if (!elementUp[i].bBeingClick) {
            ofNoFill();
            ofSetColor(ofColor::fromHsb(0,0,255,120));
        } else {
            ofFill();
            ofSetColor(ofColor::fromHsb(0,0,255,30));
        }
        
        ofDrawRectangle(elementUp[i].onOffPos, _size, _size);
        ofDrawRectangle(elementUp[i].pitchPos, _size, _size);
        
        debugModeView(i, "up");
        
    }
    ofPopStyle();
    
    ofPopMatrix();
    
}

//--------------------------------------------------------------
void ofApp::debugModeView(int _i, string _pos){
    
    if (debugMode) {
        ofPushStyle();
        ofSetColor(ofColor::fromHsb(0,0,255,180));
        if (_pos == "down") {
            ofDrawRectangle(elementDown[_i].onOffPos, ctrlRectSize, ctrlRectSize);
            ofDrawRectangle(elementDown[_i].pitchPos, ctrlRectSize, ctrlRectSize);
        }
        if (_pos == "up") {
            ofDrawRectangle(elementUp[_i].onOffPos, ctrlRectSize, ctrlRectSize);
            ofDrawRectangle(elementUp[_i].pitchPos, ctrlRectSize, ctrlRectSize);
        }
        ofPopStyle();
        
        ofDrawRectangle( upPart.lengthPos, ctrlRectSize, ctrlRectSize );
        ofDrawRectangle( downPart.lengthPos, ctrlRectSize, ctrlRectSize );
        
    }
    
}


//--------------------------------------------------------------
void ofApp::touchGuideLine(){
    
    ofPushStyle();
    
    ofSetColor(ofColor::fromHsb(0,0,255,80));
    
    ofDrawLine(touchPos.x, 0, touchPos.x, screenH);
    ofDrawLine(0, touchPos.y, screenW, touchPos.y);
    
    ofPopStyle();
}


//--------------------------------------------------------------
void ofApp::drawMainLine(bool _bTOnOff, bool _bTSizeOver, bool _bTOnOffOver, ofVec2f _vTSizePos, ofVec2f _vTOnOffPos) {
    
    ofPushStyle();
    ofSetRectMode(OF_RECTMODE_CENTER);
    
    ofPushStyle();
    ofColor _cRectOn = ofColor::fromHsb(0, 0, 255, 200);
    ofColor _cRectOff = ofColor::fromHsb(0, 0, 255, 30);
    
    ofSetColor(_cRectOn);
    
    float _size = ctrlRectSize * rectSizeRatio;
    
    if (_bTOnOff) {
        ofNoFill();
        ofSetColor(_cRectOn);
    } else {
        ofFill();
        ofSetColor(_cRectOff);
    }
    
    //    ofDrawRectangle(_vTSizePos, _size, _size);
    //    ofDrawRectangle(_vTOnOffPos, ctrlRectSize*rectSizeRatio, ctrlRectSize*rectSizeRatio);
    ofPopStyle();
    
    ofPushStyle();
    ofColor _cLineOn = ofColor::fromHsb(0, 0, 255, 200);
    ofColor _cLineOff = ofColor::fromHsb(0, 0, 255, 100);
    
    ofSetColor(_cLineOn);
    
    if (_bTOnOff) {
        ofNoFill();
        ofSetColor(_cLineOn);
    } else {
        ofFill();
        ofSetColor(_cLineOff);
    }
    
    //    ofDrawLine(_vTOnOffPos+ofVec2f(ctrlRectSize*rectSizeRatio*0.5, 0), _vTSizePos-ofVec2f(ctrlRectSize*rectSizeRatio*0.5, 0));
    ofDrawLine(_vTOnOffPos + ofVec2f(_size * 0.5, 0), _vTSizePos - ofVec2f(_size * 0.5, 0));
    ofPopStyle();
    
    ofPopStyle();
    
}

//--------------------------------------------------------------
void ofApp::sampleChangeDraw(){
    
    ofPushMatrix();
    ofPushStyle();
    
    ofNoFill();
    ofSetColor( ofColor::fromHsb(0, 0, 230, 200) );
    
    ofPushStyle();
    
    if (sampleChangeMenu) {
        ofSetColor( ofColor::fromHsb(0, 0, 230, 70) );
        ofFill();
        ofDrawRectangle( sampleChange );
        sampleChangeMenu = false;
    }
    
    ofDrawRectangle(sampleChange);
    
    ofPopStyle();
    
    ofPopStyle();
    ofPopMatrix();
    
    
}

//--------------------------------------------------------------
void ofApp::stopStartDraw(){
    
    ofPushMatrix();
    ofPushStyle();
    
    ofTranslate(menuStartRectSpacing, 0);
    ofTranslate(menuStartRectSpacing + menuStartRectSize * 0.5, screenH * 0.5);
    
    int rotateOnOff = dnIndex % 2;
    if (rotateOnOff==0) {
        ofRotateZ(0);
    } else {
        ofRotateZ(-45);
    }
    
    ofTranslate(-menuStartRectSpacing - menuStartRectSize * 0.5, -screenH * 0.5);
    
    if (bMainStartStop) {
        bMainStartStop = true;
    } else {
        bMainStartStop = false;
        threadDownCounter = 0;
        indexCounterDn = 0;
        indexCounterUp = 0;
        ofFill();
        ofSetColor(ofColor::fromHsb(0, 0, 255, 40));
        ofDrawRectangle(mainStartStop);
    }
    
    ofNoFill();
    ofSetColor(ofColor::fromHsb(0, 0, 255, 220));
    ofDrawRectangle(mainStartStop);
    ofPopStyle();
    ofPopMatrix();
    
    
}


//--------------------------------------------------------------
void ofApp::recordDraw(){
    
    ofPushMatrix();
    ofPushStyle();
    
    ofNoFill();
    ofSetColor(ofColor::fromHsb(0, 0, 255, 220));
    ofDrawRectangle( waveRecordPos, menuStartRectSize, menuStartRectSize );
    
    ofDrawRectangle( screenW - waveRecordPos.x - menuStartRectSize, waveRecordPos.y, menuStartRectSize, menuStartRectSize );
    
    ofPopStyle();
    ofPopMatrix();
    
    
}

//--------------------------------------------------------------
void ofApp::recordingLineDraw(ofVec2f _vP){
    
    //    float _colorAlpha = 120;
    //
    //    float _dnColorOn = abs(sin(ofDegToRad(downPart.rectBlockAlphaFactor))*_colorAlpha*0.5);
    //    float _dnColorOff = abs(sin(ofDegToRad(downPart.rectBlockAlphaFactor))*_colorAlpha*0.2);
    //    float _dnLineColor = abs(sin(ofDegToRad(downPart.rectBlockAlphaFactor))*_colorAlpha*0.3);
    //
    //    float _upColorOn = abs(sin(ofDegToRad(upPart.rectBlockAlphaFactor))*_colorAlpha*0.5);
    //    float _upColorOff = abs(sin(ofDegToRad(upPart.rectBlockAlphaFactor))*_colorAlpha*0.2);
    //    float _upLineColor = abs(sin(ofDegToRad(upPart.rectBlockAlphaFactor))*_colorAlpha*0.3);
    
    ofPushMatrix();
    
    //    ofTranslate(_vP);
    
    //    ofPushStyle();
    //    if (_vP.y == downPart.recBlockPos.y) {
    //        ofPushStyle();
    //        if (downPart.bDownSoundRecordClick) {
    //            downPart.rectBlockAlphaFactor = downPart.rectBlockAlphaFactor + 2.5;
    //            downPart.soundVolume = 1;
    //            ofFill();
    //            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _dnColorOn));
    //            ofDrawRectangle( 0,-(recBlockSize-1)*0.5,recBlockSize-1,recBlockSize-1 );
    //            ofNoFill();
    //        } else {
    //            downPart.rectBlockAlphaFactor = _colorAlpha;
    //            downPart.soundVolume = 0;
    //            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _dnColorOff));
    //            ofDrawRectangle( 0,-(recBlockSize-1)*0.5,recBlockSize-1,recBlockSize-1 );
    //        }
    //        ofPushStyle();
    //        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _dnLineColor));
    //        ofDrawLine(0,-(recBlockSize-1)*0.5,downPart.onOffPos.x-_vP.x-5,ofGetHeight()*0.5-_vP.y+5+3);
    //        ofPopStyle();
    //        ofPopStyle();
    //    } else {
    //        ofPushStyle();
    //        if (upPart.bDownSoundRecordClick) {
    //            upPart.rectBlockAlphaFactor = upPart.rectBlockAlphaFactor + 2.5;
    //            upPart.soundVolume = 1;
    //            ofFill();
    //            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _upColorOn));
    //            ofDrawRectangle(0,-(recBlockSize-1)*0.5,recBlockSize-1,recBlockSize-1);
    //            ofNoFill();
    //        } else {
    //            upPart.rectBlockAlphaFactor = _colorAlpha;
    //            upPart.soundVolume = 0;
    //            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _upColorOff));
    //            ofDrawRectangle(0,-(recBlockSize-1)*0.5,recBlockSize-1,recBlockSize-1);
    //        }
    //        ofPushStyle();
    //        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, _upLineColor));
    //        ofDrawLine(0,(recBlockSize-1)*0.5,upPart.onOffPos.x-_vP.x-5,ofGetHeight()*0.5-_vP.y-5-3);
    //        ofPopStyle();
    //        ofPopStyle();
    //    }
    //    ofPopStyle();
    
    ofPushMatrix();
    ofPushStyle();
    
    ofVec2f _pos = waveRecordPos - ofVec2f( menuStartRectSize*0.5, -menuStartRectSize*0.5 );
    float _volumeParameter = screenH * 0.05;
    float _volumePre = 1;
    int _indexBuffer = (int)(buffer[0] * _volumePre * _volumeParameter);
    
    ofTranslate( _pos );
    
    float _volumeWidth = menuStartRectSize * 0.4;
    
    int _lineThick = 3;
    
    ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 220, 210));
    for (int i=0; i<_indexBuffer; i+=10) {
        //        ofDrawLine( 0, -i-_lineThick, _volumeWidth, -i-_lineThick );
        //        ofDrawLine( 0, i+_lineThick, _volumeWidth, i+_lineThick );
        ofDrawRectangle( 0, i+_lineThick, _volumeWidth, _lineThick*2 );
        ofDrawRectangle( 0, -i-_lineThick, _volumeWidth, _lineThick*2 );
    }
    
    ofNoFill();
    ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 220, 140));
    for (int i=0; i<(int)_volumeParameter; i+=10) {
        ofDrawRectangle( 0, i+_lineThick, _volumeWidth, _lineThick*2 );
        ofDrawRectangle( 0, -i-_lineThick, _volumeWidth, _lineThick*2 );
    }
    ofPopStyle();
    ofPopMatrix();
    
    for(int i = 0; i < recBlockSize-1; i++){
        ofPushStyle();
        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 220, 150));
        
        //        ofDrawLine(i, buffer[i] * (recBlockSize-1)/3, i+1, buffer[i+1] * -(recBlockSize-1)/3);
        
        
        ofPopStyle();
        
        //        if ((abs(buffer[i+1]*50.0f)>5)&&!downPart.bDownSoundRecordClick){
        //            downPart.startTime = ofGetElapsedTimeMillis();
        //        }
        //        if ((abs(buffer[i+1]*50.0f)>5)&&!upPart.bDownSoundRecordClick){
        //            upPart.startTime = ofGetElapsedTimeMillis();
        //        }
        if ((abs(buffer[i+1]*50.0f)>10)){
            downPart.startTime = ofGetElapsedTimef();
            //            upPart.startTime = ofGetElapsedTimeMillis();
        }
    }
    
    ofPopMatrix();
    
    downPart.recordingTime = sampleRecordingTime;
    downPart.timeStamp = ofGetElapsedTimef() - downPart.startTime;
    
    if ((downPart.timeStamp < downPart.recordingTime)){
        if (downPart.recordState==0){
            downPart.recordState=1;
        }
        downPart.bTimerReached = false;
    }
    
    if ((downPart.timeStamp >= downPart.recordingTime)&&!downPart.bTimerReached){
        if (downPart.recordState==3){
            downPart.recordState=2;
        }
        downPart.bTimerReached = true;
        bWaveRect = false;
    }
    
    
}


//--------------------------------------------------------------
void ofApp::audioRequested (float * output, int bufferSize, int nChannels){
    
    synthMain.fillBufferOfFloats(output, bufferSize, nChannels);
    
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
    
    if (downPart.recordState==1){
        downPart.recordState=3;
        downPart.myWavWriter.open(ofxiOSGetDocumentsDirectory() + "recordingDown.wav", WAVFILE_WRITE);
        //        upPart.myWavWriter.open(ofxiOSGetDocumentsDirectory() + "recordingUp.wav", WAVFILE_WRITE);
    }
    
    if (downPart.recordState==3){
        downPart.myWavWriter.write(input, bufferSize*nChannels);
        //        upPart.myWavWriter.write(input, bufferSize*nChannels);
    }
    
    if (downPart.recordState==2){
        downPart.myWavWriter.close();
        downPart.recordState=0;
        for (int i = 0; i<nElementLine; i++){
            elementDown[i].samplePlay.load(ofxiOSGetDocumentsDirectory() + "recordingDown.wav");
            elementUp[i].samplePlay.load(ofxiOSGetDocumentsDirectory() + "recordingDown.wav");
        }
    }
    
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
void ofApp::menuSetting(){
    
    mainStartStop.set(menuStartRectSpacing, screenH * 0.5 - menuStartRectSize * 0.5, menuStartRectSize, menuStartRectSize);
    
    sampleChange.set( screenW - menuStartRectSize - menuStartRectSpacing, screenH * 0.5 - menuStartRectSize * 0.5,
                     menuStartRectSize, menuStartRectSize);
    
    //    ofPoint _waveRecord = ofPoint( downPart.onOffPos.x-menuStartRectSize, ofGetHeight()*0.5 );
    //    waveRecord.set( _waveRecord, menuStartRectSize, menuStartRectSize );
    
}


//--------------------------------------------------------------
void ofApp::exit(){
    
    ofSoundStreamStop();
    ofSoundStreamClose();
    
    for (int i = 0; i<nElementLine; i++){
        elementDown[i].samplePlay.unload();
        elementUp[i].samplePlay.unload();
    }
    
}


//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
    //    ofVec2f _touchCaP = ofVec2f(touch.x-22, touch.y);
    ofVec2f _touchCaP = ofVec2f(touch.x, touch.y);
    
    if (touch.y < screenH * 0.5) {
        delayTouchDownPos = touch.x;
    } else {
        tempoTouchDownPos = touch.x;
    }
    
    touchPos = _touchCaP;
    
    ofVec2f _yDnInput = ofVec2f(_touchCaP.x, _touchCaP.y - (screenH*0.5));
    ofVec2f _yUpInput = ofVec2f(_touchCaP.x, _touchCaP.y - (screenH*0.5));
    
    //    ofVec2f _dnRecPos = downPart.bDownSoundRecordPos+ofVec2f(recBlockSize*0.5, recBlockSize*0.5)+ofVec2f(0,-(ofGetHeight()*0.5));
    //    ofVec2f _upRecPos = upPart.bDownSoundRecordPos+ofVec2f(recBlockSize*0.5, recBlockSize*0.5)+ofVec2f(0,-(ofGetHeight()*0.5));
    ofVec2f _waveRectPos = waveRecordPos;
    
    ofVec2f _yDnInputForCtrl = ofVec2f(_touchCaP.x, _touchCaP.y - (screenH*0.5)-ctrlRectSize);
    ofVec2f _yUpInputForCtrl = ofVec2f(_touchCaP.x, _touchCaP.y - (screenH*0.5)+ctrlRectSize);
    
    //    downPart.bBeingClick = onOffOut(_yDnInputForCtrl, downPart.onOffPos, ctrlRectSize, downPart.bBeingClick);
    downPart.bLengthBeingDragged = inOutCal(_yDnInputForCtrl, downPart.lengthPos, ctrlRectSize);
    
    //    upPart.bBeingClick = onOffOut(_yUpInputForCtrl, upPart.onOffPos, ctrlRectSize, upPart.bBeingClick);
    upPart.bLengthBeingDragged = inOutCal(_yUpInputForCtrl, upPart.lengthPos, ctrlRectSize);
    
    bWaveRect = onOffOut( _touchCaP, _waveRectPos + ofVec2f(menuStartRectSize,menuStartRectSize)*0.5, menuStartRectSize, bWaveRect );
    
    //    downPart.bDownSoundRecordClick = onOffOut(_yDnInput, _dnRecPos, recBlockSize, downPart.bDownSoundRecordClick);
    //    upPart.bDownSoundRecordClick = onOffOut(_yUpInput, _upRecPos, recBlockSize, upPart.bDownSoundRecordClick);
    
    for (int i = 0; i < nElementLine; i++) {
        elementDown[i].bLengthBeingDragged = inOutCal(_yDnInput, elementDown[i].pitchPos, ctrlRectSize);
        elementUp[i].bLengthBeingDragged = inOutCal(_yUpInput, elementUp[i].pitchPos, ctrlRectSize);
        
        if (downPart.bBeingClick) {
            elementDown[i].bBeingClick = onOffOut(_yDnInput, elementDown[i].onOffPos, ctrlRectSize, elementDown[i].bBeingClick);
            elementDown[i].soundTrigger = onOffOut(_yDnInput, elementDown[i].onOffPos, ctrlRectSize, elementDown[i].soundTrigger);
        }
        
        if (upPart.bBeingClick) {
            elementUp[i].bBeingClick = onOffOut(_yUpInput, elementUp[i].onOffPos, ctrlRectSize, elementUp[i].bBeingClick);
            elementUp[i].soundTrigger = onOffOut(_yUpInput, elementUp[i].onOffPos, ctrlRectSize, elementUp[i].soundTrigger);
        }
    }
    
    ofVec2f _inputSampleChange = ofVec2f(touch.x, touch.y);
    
    if (sampleChange.inside(_inputSampleChange)) {
        sampleChangeMenu = true;
        downPart.bChangeSampleClick = true;
        upPart.bChangeSampleClick = true;
    }
    
    if (downPart.bChangeSampleClick){
        downPart.changeSampleIndex = downPart.changeSampleIndex%dir.size();
        for (int i = 0; i<nElementLine; i++){
            string fileNameDown = "sounds/samples/" + dir.getName(downPart.changeSampleIndex);
            elementDown[i].samplePlay.load(fileNameDown);
        }
        downPart.bChangeSampleClick = false;
        
        upPart.changeSampleIndex = upPart.changeSampleIndex%dir.size();
        for (int i = 0; i<nElementLine; i++){
            string fileNameUp = "sounds/samples/" + dir.getName(upPart.changeSampleIndex);
            elementUp[i].samplePlay.load(fileNameUp);
        }
        upPart.bChangeSampleClick = false;
        
        downPart.changeSampleIndex++;
        upPart.changeSampleIndex++;
        
    }
    
    
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    
    //    ofVec2f _touchCaP = ofVec2f(touch.x-22, touch.y);
    ofVec2f _touchCaP = ofVec2f(touch.x, touch.y);
    
    float _torelance = 0.05;
    if (touch.y < screenH * (0.5 - _torelance)) {
        delayTouchMovingPos = touch.x;
        float _movingSecond = delayTouchMovingPos - delayTouchDownPos;
        movingFactor = _movingSecond / 70;
        delayValue = ofClamp(delayValueSaved + movingFactor, -2, 2);
        delayupPart = delayValue;
    } else if (touch.y > screenH * (0.5 + _torelance)) {
        if (!downPart.bLengthBeingDragged) {
            tempoTouchMovingPos = touch.x;
            float _movingSecond = - tempoTouchMovingPos + tempoTouchDownPos;
            tempoValue = ofClamp(tempoValueSaved + _movingSecond, minLine, maxLine);
            downPart.lengthPos.x = tempoValue;
        }
        
    }
    
    
    touchPos = _touchCaP;
    
    float _minElementPosY = 50 * 2;
    float _maxElementPosY = 20 * 2;
    
    for (int i = 0; i < nElementLine; i++){
        if (elementDown[i].bLengthBeingDragged == true){
            float _yPos = ofClamp(touch.y, screenH*0.5+_minElementPosY, screenH-_maxElementPosY);
            downPart.bLengthBeingDragged = true;
            elementDown[i].pitchPos.y = _yPos - screenH*0.5;
        }
    }
    
    for (int i = 0; i < nElementLine; i++){
        if (elementUp[i].bLengthBeingDragged == true){
            float _yPos = ofClamp(touch.y, _maxElementPosY, screenH*0.5-_minElementPosY);
            elementUp[i].pitchPos.y = _yPos - screenH*0.5;
        }
    }
    
    if (upPart.bLengthBeingDragged == true){
        float _xPos = touch.x - (upPart.length*0.5+screenH*0.5);
        upPart.position.x = ofClamp(_xPos, -49, 49);
    }
    
}


//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
    ofVec2f _inputSampleChange = ofVec2f(touch.x, touch.y);
    
    float _dist = ofDist(mainStartStop.getCenter().x, mainStartStop.getCenter().y, _inputSampleChange.x, _inputSampleChange.y);
    if ( _dist < mainStartStop.width * 1.5) {
        bMainStartStop = !bMainStartStop;
    }
    
    delayTouchDownPos = 0;
    delayValueSaved = delayValue;
    
    
    tempoTouchDownPos = 0;
    tempoValueSaved = tempoValue;
    
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    
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

//--------------------------------------------------------------
void ofApp::synthSetting(){
    
}

