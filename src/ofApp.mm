#include "ofApp.h"

void ofApp::setup(){
    
    //    ofSetWindowTitle("micro 8Bit sequencer");
    ofSetOrientation(OF_ORIENTATION_90_RIGHT);
    ofEnableAlphaBlending();
    ofSetCircleResolution(24);
    
    
    ofxAccelerometer.setup();
    ofxMultiTouch.addListener(this);
    
    backgroundColorHue = ofRandom(0,255);
    ofBackground(ofColor::fromHsb(backgroundColorHue, 150, 180));
    
    initialBufferSize = 256;
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
    
    //    fullscreen = false;
    
    controlPointSize = 22;
    
    for (int i=0; i<16; i++) {
        randomY[i] = ofRandom(55,ofGetHeight()*2/5);
    }
    
    tempoLineDown.length = ofGetWidth()*3/8;
    tempoLineDown.bBeingClick = true;
    tempoLineDown.bTimerReached = true;
    tempoLineDown.bDownSoundRecordClick = true;
    tempoLineDown.bChangeSampleClick = false;
    tempoLineDown.bChangeSampleOver = false;
    tempoLineDown.startTime = ofGetElapsedTimeMillis() - 1000;
    tempoLineDown.rectBlockAlphaFactor = 0;
    tempoLineDown.recordState=0;
    tempoLineDown.soundVolume = 1;
    tempoLineDown.changeSampleIndex = 0;
    tempoLineDown.myWavWriter.setFormat(1, sampleRate, 16);
    tempoLineDown.onOffRectPos.x = -tempoLineDown.length/2 + ofGetWidth()/2;
    tempoLineDown.lengthRectPos.x = tempoLineDown.length/2 + ofGetWidth()/2;
    tempoLineDown.changeSampleSize = 60;
    
    tempoLineUp.length = tempoLineDown.length;
    tempoLineUp.bBeingClick = true;
    tempoLineUp.bTimerReached = true;
    tempoLineUp.bDownSoundRecordClick = true;
    tempoLineUp.bChangeSampleClick = false;
    tempoLineUp.bChangeSampleOver = false;
    tempoLineUp.startTime = ofGetElapsedTimeMillis() - 1000;
    tempoLineUp.rectBlockAlphaFactor = 0;
    tempoLineUp.recordState=0;
    tempoLineUp.soundVolume = 1;
    tempoLineUp.changeSampleIndex = 0;
    tempoLineUp.myWavWriter.setFormat(1, sampleRate, 16);
    tempoLineUp.onOffRectPos.x = -tempoLineUp.length/2 + ofGetWidth()/2;
    tempoLineUp.lengthRectPos.x = tempoLineUp.length/2 + ofGetWidth()/2;
    tempoLineUp.changeSampleSize = 60;
    
    tempoLineUp.position.x = tempoLineUp.lengthRectPos.x-tempoLineDown.lengthRectPos.x;
    tempoLineUp.delayPos.x = tempoLineUp.length/2 + ofGetWidth()/2 - tempoLineUp.length/(10*2);
    
    nElementLine = 8;
    for (int i = 0; i<nElementLine; i++){
        elementLinesDown[i].bLengthOver = false;
        elementLinesDown[i].bOnOffOver = false;
        elementLinesDown[i].bLengthBeingDragged = false;
        elementLinesDown[i].bBeingClick = false;
        elementLinesDown[i].soundTrigger = true;
        //        elementLinesDown[i].samplePlay.setMultiPlay(true);
        elementLinesDown[i].samplePlay.loadSound(fileNameDown);
        elementLinesDown[i].samplePlay.setVolume(highVolume);
        spacingLineDown = tempoLineDown.length / 10;
        elementLinesDown[i].position = ofVec2f(spacingLineDown + spacingLineDown/2 + spacingLineDown*i, tempoLineDown.onOffRectPos.y);
        elementLinesDown[i].lengthRect = ofVec2f(elementLinesDown[i].position.x, elementLinesDown[i].position.y+randomY[i]);
        elementLinesDown[i].onOffRect = elementLinesDown[i].lengthRect * ofVec2f(1,-1) + ofVec2f(0,ofGetHeight());
        elementLinesDown[i].width = controlPointSize;
        elementLinesDown[i].triggerColor = 120;
        
        elementLinesUp[i].bLengthOver = false;
        elementLinesUp[i].bOnOffOver = false;
        elementLinesUp[i].bLengthBeingDragged = false;
        elementLinesUp[i].bBeingClick = false;
        elementLinesUp[i].soundTrigger = true;
        //        elementLinesUp[i].samplePlay.setMultiPlay(true);
        elementLinesUp[i].samplePlay.loadSound(fileNameUp);
        elementLinesUp[i].samplePlay.setVolume(highVolume);
        spacingLineUp = tempoLineUp.length / 10;
        elementLinesUp[i].position = ofVec2f(spacingLineUp + spacingLineUp/2 + spacingLineUp*i, tempoLineUp.onOffRectPos.y);
        elementLinesUp[i].lengthRect = ofVec2f(elementLinesUp[i].position.x, elementLinesUp[i].position.y-randomY[i+8]);
        elementLinesUp[i].onOffRect = elementLinesUp[i].lengthRect * ofVec2f(1,-1) + ofVec2f(0,ofGetHeight());
        elementLinesUp[i].width = controlPointSize;
        elementLinesUp[i].triggerColor = 120;
    }
    
    
    tempo = 300;
    threadedObject.notesPerPhrase = 1;
    threadedObject.start(this);
    
    thredCounter = 0;
}

void ofApp::update(){
    
    ofSoundUpdate();
    
    tempoLineDown.recBlockPos = ofVec2f(tempoLineDown.onOffRectPos.x-30, ofGetHeight()/2+ofGetHeight()*0.1);
    tempoLineDown.changeSamplePos = ofVec2f(tempoLineDown.lengthRectPos.x,ofGetHeight()/2+ofGetHeight()*0.09);
    
    tempoLineUp.recBlockPos = ofVec2f(tempoLineUp.onOffRectPos.x-30, ofGetHeight()/2-ofGetHeight()*0.1);
    tempoLineUp.changeSamplePos = ofVec2f(tempoLineUp.lengthRectPos.x,ofGetHeight()/2-ofGetHeight()*0.09);
    
    tempoLineDown.length = tempoLineDown.lengthRectPos.x - tempoLineDown.onOffRectPos.x;
    tempoLineDown.onOffRectPos.x = -tempoLineDown.length/2 + ofGetWidth()/2;
    tempoLineDown.lengthRectPos.x = tempoLineDown.length/2 + ofGetWidth()/2;
    
    delayTempoLineUp = (int)(tempoLineUp.position.x)/24;
    
    cout << delayTempoLineUp << endl;
    
    float timer = (ofGetElapsedTimeMillis()-millisDown)*1.0;
    int speedFactor = 32;
    int speedFactor8th = speedFactor/8;
    
    int _speed = (float)ofMap(tempoLineDown.length/12, 0, 1024/12, 2, 30);
    
    
    //    TO.setTempo(_speed);
    
    
    //    if(TO.trigger) {
    //        toCounter++;
    //        cout << toCounter << endl;
    //        if(toCounter>8) toCounter = 0;
    //    }
    
    
    //    if (timer>=speed){
    //        millisDown = ofGetElapsedTimeMillis();
    //
    //        triggerCounterDown++;
    //        int _index = triggerCounterDown%speedFactor;
    //
    //        for (int i = 0; i<nElementLine; i++){
    //            if (_index==((i*speedFactor8th))){
    //                if ((elementLinesDown[i].soundTrigger)&&tempoLineDown.bBeingClick){
    //                    elementLinesDown[i].onOffTrigger = true;
    //                    elementLinesDown[i].samplePlay.play();
    //                    elementLinesDown[i].samplePlay.setVolume( ofRandom(0.325,0.95) * tempoLineDown.soundVolume);
    //                    elementLinesDown[i].samplePlay.setSpeed( ofMap(elementLinesDown[i].lengthRect.y, 0, ofGetHeight()/2, 3.0, 0) * ofRandom(0.75,1.25) );
    //                }
    //            }
    //            else{
    //                elementLinesDown[i].onOffTrigger = false;
    //            }
    //
    //            if (_index==((i*speedFactor8th)+delayTempoLineUp%8)){
    //                if ((elementLinesUp[i].soundTrigger)&&tempoLineUp.bBeingClick){
    //                    elementLinesUp[i].onOffTrigger = true;
    //                    elementLinesUp[i].samplePlay.play();
    //                    elementLinesUp[i].samplePlay.setVolume( ofRandom(0.325,0.95) * tempoLineUp.soundVolume);
    //                    elementLinesUp[i].samplePlay.setSpeed( ofMap(elementLinesUp[i].lengthRect.y+ofGetHeight()/2, ofGetHeight()/2, 0, 3.0, 0) * ofRandom(0.75,1.25) );
    //                }
    //            }
    //            else{
    //                elementLinesUp[i].onOffTrigger = false;
    //            }
    //        }
    //    }
    
    
    
    //    if (timer>=speed){
    millisDown = ofGetElapsedTimeMillis();
    

    int _index = triggerCounterDown%speedFactor;
    
    //    cout << TO.trigger << endl;
    
    
    //    if (TO.trigger) {
    //        TO.trigger = false;
    //        _TOIndex = TO.count%32;
    //        if (_TOIndex%4==0) {
    //            elementLinesDown[0].samplePlay.play();
    //        }
    //    }
    
    //    if (TO.trigger) {
    //        TO.trigger = false;
    //        _TOIndex = TO.count%32;
    //        if (_TOIndex%4==0) {
    //            int _indexCounter = _TOIndex / 4;
    //            if ((elementLinesDown[_indexCounter].soundTrigger)&&tempoLineDown.bBeingClick){
    //                elementLinesDown[_indexCounter].onOffTrigger = true;
    //                elementLinesDown[_indexCounter].samplePlay.play();
    //                //                    elementLinesDown[i].samplePlay.setVolume( ofRandom(0.325,0.95) * tempoLineDown.soundVolume);
    //                elementLinesDown[_indexCounter].samplePlay.setVolume( tempoLineDown.soundVolume);
    ////                elementLinesDown[_indexCounter].samplePlay.setSpeed( ofMap(elementLinesDown[_indexCounter].lengthRect.y, 0, ofGetHeight()/2, 3.0, 0) * ofRandom(0.75,1.25) );
    //                elementLinesDown[_indexCounter].samplePlay.setSpeed( ofMap(elementLinesDown[_indexCounter].lengthRect.y, 0, ofGetHeight()/2, 3.0, 0));
    //            }
    //        }
    ////                if (_TOIndex%4==(delayTempoLineUp%8)) {
    ////                    int _indexCounter = _TOIndex / 4;
    ////                    cout << _indexCounter << endl;
    ////                    if ((elementLinesUp[_indexCounter].soundTrigger)&&tempoLineUp.bBeingClick){
    ////                        elementLinesUp[_indexCounter].onOffTrigger = true;
    ////                        elementLinesUp[_indexCounter].samplePlay.play();
    ////                        //                    elementLinesDown[i].samplePlay.setVolume( ofRandom(0.325,0.95) * tempoLineDown.soundVolume);
    ////                        elementLinesUp[_indexCounter].samplePlay.setVolume( tempoLineUp.soundVolume);
    ////                        elementLinesUp[_indexCounter].samplePlay.setSpeed( ofMap(elementLinesUp[_indexCounter].lengthRect.y, 0, ofGetHeight()/2, 3.0, 0) * ofRandom(0.75,1.25) );
    ////                    }
    ////
    ////                }
    //    }
    
    
    
    
    spacingLineDown = tempoLineDown.length / 10;
    spacingLineUp = tempoLineDown.length / 10;
    
    tempoLineUp.lengthRectPos.x = tempoLineDown.lengthRectPos.x + spacingLineUp * delayTempoLineUp * 0.5;
    tempoLineUp.onOffRectPos.x = tempoLineDown.onOffRectPos.x + spacingLineUp * delayTempoLineUp * 0.5;
    tempoLineUp.length = tempoLineUp.lengthRectPos.x - tempoLineUp.onOffRectPos.x;
    
    for (int i = 0; i<nElementLine; i++){
        elementLinesDown[i].position = ofVec2f( tempoLineDown.onOffRectPos.x + spacingLineDown + spacingLineDown/2 + spacingLineDown*i, tempoLineDown.onOffRectPos.y );
        elementLinesDown[i].lengthRect = ofVec2f( elementLinesDown[i].position.x, elementLinesDown[i].lengthRect.y );
        elementLinesDown[i].onOffRect = elementLinesDown[i].lengthRect * ofVec2f(1,0) + ofVec2f(0,controlPointSize*3/2);
        elementLinesUp[i].position.x = elementLinesDown[i].position.x + spacingLineUp * delayTempoLineUp * 0.5;
        elementLinesUp[i].lengthRect = ofVec2f( elementLinesUp[i].position.x, elementLinesUp[i].lengthRect.y );
        elementLinesUp[i].onOffRect = elementLinesUp[i].lengthRect * ofVec2f(1,0) + ofVec2f(0,-controlPointSize*3/2);
    }
    
}

//--------------------------------------------------------------
void ofApp::phraseComplete(){
    
    testOnOf = true;
    
    thredCounter++;
    
    //    onOffRect = true;
    // Play sounds here
    // This is called exactly at every four measures at 125bpm
    
    
    if (thredCounter%2==0) {
        _indexCounterDn++;

        int _index = _indexCounterDn%8;
        
        if ((elementLinesDown[_index].soundTrigger)&&tempoLineDown.bBeingClick){
            elementLinesDown[_index].onOffTrigger = true;
            elementLinesDown[_index].samplePlay.play();
            //                    elementLinesDown[i].samplePlay.setVolume( ofRandom(0.325,0.95) * tempoLineDown.soundVolume);
            //        elementLinesDown[_indexCounter].samplePlay.setVolume( tempoLineDown.soundVolume);
            //        elementLinesDown[_indexCounter].samplePlay.setSpeed( ofMap(elementLinesDown[_indexCounter].lengthRect.y, 0, ofGetHeight()/2, 3.0, 0) * ofRandom(0.75,1.25) );
            //                elementLinesDown[_indexCounter].samplePlay.setSpeed( ofMap(elementLinesDown[_indexCounter].lengthRect.y, 0, ofGetHeight()/2, 3.0, 0));
        }

    }
    
    
    if ((thredCounter+delayTempoLineUp)%2==0) {
        _indexCounterUp++;

        int _index = _indexCounterDn%8;

        if ((elementLinesUp[_index].soundTrigger)&&tempoLineDown.bBeingClick){
            elementLinesUp[_index].onOffTrigger = true;
            elementLinesUp[_index].samplePlay.play();
            //                    elementLinesDown[i].samplePlay.setVolume( ofRandom(0.325,0.95) * tempoLineDown.soundVolume);
            //        elementLinesDown[_indexCounter].samplePlay.setVolume( tempoLineDown.soundVolume);
            //        elementLinesDown[_indexCounter].samplePlay.setSpeed( ofMap(elementLinesDown[_indexCounter].lengthRect.y, 0, ofGetHeight()/2, 3.0, 0) * ofRandom(0.75,1.25) );
            //                elementLinesDown[_indexCounter].samplePlay.setSpeed( ofMap(elementLinesDown[_indexCounter].lengthRect.y, 0, ofGetHeight()/2, 3.0, 0));
        }
    }

    
    
}

//--------------------------------------------------------------
int ofApp::calculateNoteDuration()
{
    
    // Translate tempo to milliseconds
    return (int)floor(60000.0000f / tempo);
    
}

void ofApp::drawingTempoLine(bool _bTOnOff, bool _bTSizeOver, bool _bTOnOffOver, ofVec2f _vTSizePos, ofVec2f _vTOnOffPos){
    ofPushStyle();
    ofSetRectMode(OF_RECTMODE_CENTER);
    ofSetColor(ofColor::fromHsb(0,0,255,140));
    
    if (_bTOnOff){
        ofNoFill();
        ofSetColor(ofColor::fromHsb(0,0,255,140));
    }
    else{
        ofFill();
        ofSetColor(ofColor::fromHsb(0,0,255,40));
    }
    ofRect(_vTSizePos, controlPointSize, controlPointSize);
    
    ofRect( _vTOnOffPos, controlPointSize, controlPointSize );
    ofLine( _vTOnOffPos+ofVec2f(controlPointSize/2,0), _vTSizePos-ofVec2f(controlPointSize/2,0) );
    ofPopStyle();
}


void ofApp::draw(){
    ofPushMatrix();
    ofTranslate(0, ofGetHeight()/2+controlPointSize);
    
    drawingTempoLine(tempoLineDown.bBeingClick, tempoLineDown.bLengthOver, tempoLineDown.bOnOffOver, tempoLineDown.lengthRectPos, tempoLineDown.onOffRectPos);
    
    ofPushStyle();
    ofSetRectMode(OF_RECTMODE_CENTER);
    
    for (int i = 0; i<nElementLine; i++){
        if (elementLinesDown[i].onOffTrigger){
            if (!elementLinesDown[i].bBeingClick){
                elementLinesDown[i].triggerColor = 100;
            } else {
                elementLinesDown[i].triggerColor = 0;
            }
            elementLinesDown[i].onOffTrigger = false;
        } else {
            elementLinesDown[i].triggerColor = 0;
        }
        
        
        if (elementLinesDown[i].soundTrigger&&tempoLineDown.bBeingClick){
            ofFill();
            ofSetColor(ofColor::fromHsb(0,0,230+elementLinesDown[i].triggerColor,155+elementLinesDown[i].triggerColor));
            ofLine(elementLinesDown[i].onOffRect+ofVec2f(0,elementLinesDown[i].width/2), elementLinesDown[i].lengthRect+ofVec2f(0,-elementLinesDown[i].width)/2);
        } else {
            ofNoFill();
            ofSetColor(ofColor::fromHsb(0,0,230+elementLinesDown[i].triggerColor,50+elementLinesDown[i].triggerColor));
            ofLine(elementLinesDown[i].onOffRect+ofVec2f(0,elementLinesDown[i].width/2), elementLinesDown[i].lengthRect+ofVec2f(0,-elementLinesDown[i].width/2));
        }
        
        if (!elementLinesDown[i].bBeingClick) {
            ofNoFill();
        } else {
            ofFill();
        }
        ofRect(elementLinesDown[i].onOffRect, controlPointSize, controlPointSize);
        ofRect(elementLinesDown[i].lengthRect, controlPointSize, controlPointSize);
        
    }
    ofPopStyle();
    ofPopMatrix();
    
    
    ofPushMatrix();
    ofTranslate(0, ofGetHeight()/2-controlPointSize);
    
    drawingTempoLine(tempoLineUp.bBeingClick, tempoLineUp.bLengthOver, tempoLineUp.bOnOffOver, tempoLineUp.lengthRectPos, tempoLineUp.onOffRectPos);
    
    ofPushStyle();
    ofSetRectMode(OF_RECTMODE_CENTER);
    for (int i = 0; i<nElementLine; i++){
        
        if (elementLinesUp[i].onOffTrigger){
            if (!elementLinesUp[i].bBeingClick){
                elementLinesUp[i].triggerColor = 100;
            } else {
                elementLinesUp[i].triggerColor = 0;
            }
            elementLinesUp[i].onOffTrigger = false;
            
        } else {
            elementLinesUp[i].triggerColor = 0;
        }
        
        
        if (elementLinesUp[i].soundTrigger&&tempoLineUp.bBeingClick){
            ofFill();
            ofSetColor(ofColor::fromHsb(0,0,230+elementLinesUp[i].triggerColor,155+elementLinesUp[i].triggerColor));
            ofLine(elementLinesUp[i].onOffRect+ofVec2f(0,-elementLinesUp[i].width/2), elementLinesUp[i].lengthRect+ofVec2f(0,elementLinesUp[i].width/2));
        } else {
            ofNoFill();
            ofSetColor(ofColor::fromHsb(0,0,230+elementLinesUp[i].triggerColor,50+elementLinesUp[i].triggerColor));
            ofLine(elementLinesUp[i].onOffRect+ofVec2f(0,-elementLinesUp[i].width/2), elementLinesUp[i].lengthRect+ofVec2f(0,elementLinesUp[i].width/2));
        }
        
        if (!elementLinesUp[i].bBeingClick) {
            ofNoFill();
        } else {
            ofFill();
        }
        ofRect(elementLinesUp[i].onOffRect, controlPointSize, controlPointSize);
        ofRect(elementLinesUp[i].lengthRect, controlPointSize, controlPointSize);
        
    }
    ofPopStyle();
    ofPopMatrix();
    
    if (!tempoLineUp.bBeingClick&&tempoLineDown.bBeingClick){
        recordingLineDraw(tempoLineDown.recBlockPos);
    }
    if (!tempoLineDown.bBeingClick&&tempoLineUp.bBeingClick){
        recordingLineDraw(tempoLineUp.recBlockPos);
    }
    
    if ((!tempoLineUp.bBeingClick&&!tempoLineUp.bDownSoundRecordClick)||tempoLineDown.bBeingClick){
        tempoLineUp.bDownSoundRecordClick = true;
    }
    if ((!tempoLineDown.bBeingClick&&!tempoLineDown.bDownSoundRecordClick)||tempoLineUp.bBeingClick){
        tempoLineDown.bDownSoundRecordClick = true;
    }
    
    tempoLineDown.bDownSoundRecordPos = ofVec2f( tempoLineDown.recBlockPos.x,tempoLineDown.recBlockPos.y-(initialBufferSize/8-1)/2 );
    tempoLineUp.bDownSoundRecordPos = ofVec2f( tempoLineUp.recBlockPos.x,tempoLineUp.recBlockPos.y-(initialBufferSize/8-1)/2 );
    
    ofPushStyle();
    ofSetColor( ofColor::fromHsb(backgroundColorHue, 0, 220, 100) );
    //    if (tempoLineUp.bChangeSampleOver){
    ofPushStyle();
    if (tempoLineUp.bChangeSampleClick){
        ofSetColor( ofColor::fromHsb(backgroundColorHue, 0, 220, 160) );
        tempoLineUp.changeSampleIndex++;
        tempoLineUp.changeSampleIndex = tempoLineUp.changeSampleIndex%dir.size();
        for (int i = 0; i<nElementLine; i++){
            string fileNameUp = "sounds/samples/" + dir.getName(tempoLineUp.changeSampleIndex);
            elementLinesUp[i].samplePlay.loadSound(fileNameUp);
        }
        tempoLineUp.bChangeSampleClick = !tempoLineUp.bChangeSampleClick;
    }
    else{
        ofSetColor( ofColor::fromHsb(backgroundColorHue, 0, 220, 50) );
    }
    //        ofRect(tempoLineUp.changeSamplePos.x-tempoLineUp.changeSampleSize/2, tempoLineUp.changeSamplePos.y-tempoLineUp.changeSampleSize/2, tempoLineUp.changeSampleSize, tempoLineUp.changeSampleSize);
    //        ofNoFill();
    //        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, 80) );
    //        ofLine(tempoLineUp.changeSamplePos.x+tempoLineUp.changeSampleSize/2,tempoLineUp.changeSamplePos.y+tempoLineUp.changeSampleSize/2,tempoLineUp.lengthRectPos.x+3,tempoLineUp.lengthRectPos.y+ofGetHeight()/2-7);
    ofPopStyle();
    
    //    }
    //    if (tempoLineDown.bChangeSampleOver){
    ofPushStyle();
    if (tempoLineDown.bChangeSampleClick){
        ofSetColor( ofColor::fromHsb(backgroundColorHue, 0, 220, 160) );
        tempoLineDown.changeSampleIndex++;
        tempoLineDown.changeSampleIndex = tempoLineDown.changeSampleIndex%dir.size();
        for (int i = 0; i<nElementLine; i++){
            string fileNameDown = "sounds/samples/" + dir.getName(tempoLineDown.changeSampleIndex);
            elementLinesDown[i].samplePlay.loadSound(fileNameDown);
        }
        tempoLineDown.bChangeSampleClick = !tempoLineDown.bChangeSampleClick;        }
    else{
        ofSetColor( ofColor::fromHsb(backgroundColorHue, 0, 220, 50) );
    }
    //        ofRect(tempoLineDown.changeSamplePos.x-30, tempoLineDown.changeSamplePos.y-30, 60, 60);
    //        ofNoFill();
    //        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, 80) );
    //        ofLine(tempoLineDown.changeSamplePos.x+30,tempoLineDown.changeSamplePos.y-30,tempoLineDown.lengthRectPos.x+3,tempoLineDown.lengthRectPos.y+ofGetHeight()/2+7);
    ofPopStyle();
    //    }
    ofPopStyle();
    
    infomationWindow();
    
    ofLine(mouseX, 0, mouseX, ofGetHeight());
    ofLine(0, mouseY, ofGetWidth(), mouseY);
    
    ofDrawBitmapString(ofToString(ofGetFrameRate(),2), 10, 10);
    
}


void ofApp::infomationWindow(){
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
    
    float colorAlpha = 120;
    
    if (_vP.y == tempoLineDown.recBlockPos.y){
        ofPushStyle();
        if (tempoLineDown.bDownSoundRecordClick){
            tempoLineDown.rectBlockAlphaFactor = tempoLineDown.rectBlockAlphaFactor + 2.5;
            tempoLineDown.soundVolume = 1;
            ofFill();
            ofSetColor( ofColor::fromHsb( backgroundColorHue, 0, 230, abs(sin(ofDegToRad(tempoLineDown.rectBlockAlphaFactor))*colorAlpha*0.5) ) );
            ofRect( 0,-(initialBufferSize/8-1)/2,initialBufferSize/8-1,initialBufferSize/8-1 );
            ofNoFill();
        }
        else{
            tempoLineDown.rectBlockAlphaFactor = colorAlpha;
            tempoLineDown.soundVolume = 0;
            ofSetColor( ofColor::fromHsb( backgroundColorHue, 0, 230, abs(sin(ofDegToRad(tempoLineDown.rectBlockAlphaFactor))*colorAlpha*0.2) ) );
            ofRect( 0,-(initialBufferSize/8-1)/2,initialBufferSize/8-1,initialBufferSize/8-1 );
        }
        ofPushStyle();
        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, abs(sin(ofDegToRad(tempoLineDown.rectBlockAlphaFactor))*colorAlpha*0.3) ));
        ofLine( 0,-(initialBufferSize/8-1)/2,tempoLineDown.onOffRectPos.x-_vP.x-5,ofGetHeight()/2-_vP.y+5+3 );
        ofPopStyle();
        ofPopStyle();
    }
    else{
        ofPushStyle();
        if (tempoLineUp.bDownSoundRecordClick){
            tempoLineUp.rectBlockAlphaFactor = tempoLineUp.rectBlockAlphaFactor + 2.5;
            tempoLineUp.soundVolume = 1;
            ofFill();
            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, abs(sin(ofDegToRad(tempoLineUp.rectBlockAlphaFactor))*colorAlpha*0.5) ));
            ofRect(0,-(initialBufferSize/8-1)/2,initialBufferSize/8-1,initialBufferSize/8-1);
            ofNoFill();
        }
        else{
            tempoLineUp.rectBlockAlphaFactor = colorAlpha;
            tempoLineUp.soundVolume = 0;
            ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, abs(sin(ofDegToRad(tempoLineUp.rectBlockAlphaFactor))*colorAlpha*0.2) ));
            ofRect(0,-(initialBufferSize/8-1)/2,initialBufferSize/8-1,initialBufferSize/8-1);
        }
        ofPushStyle();
        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 230, abs(sin(ofDegToRad(tempoLineUp.rectBlockAlphaFactor))*colorAlpha*0.3) ));
        ofLine( 0,(initialBufferSize/8-1)/2,tempoLineUp.onOffRectPos.x-_vP.x-5,ofGetHeight()/2-_vP.y-5-3 );
        ofPopStyle();
        ofPopStyle();
    }
    ofPopStyle();
    
    
    
    for(int i = 0; i < initialBufferSize/8-1; i++){
        ofPushStyle();
        ofSetColor(ofColor::fromHsb(backgroundColorHue, 0, 220, 150));
        
        ofLine(i, buffer[i] * (initialBufferSize/8-1)/3, i+1, buffer[i+1] * -(initialBufferSize/8-1)/3);
        ofPopStyle();
        
        if ((abs(buffer[i+1]*50.0f)>5)&&!tempoLineDown.bDownSoundRecordClick){
            tempoLineDown.startTime = ofGetElapsedTimeMillis();
        }
        if ((abs(buffer[i+1]*50.0f)>5)&&!tempoLineUp.bDownSoundRecordClick){
            tempoLineUp.startTime = ofGetElapsedTimeMillis();
        }
    }
    
    ofPopMatrix();
    
    if (_vP.y == tempoLineDown.recBlockPos.y){
        tempoLineDown.recordingTime = 1000;
        tempoLineDown.timeStamp = ofGetElapsedTimeMillis() - tempoLineDown.startTime;
        
        if ((tempoLineDown.timeStamp<tempoLineDown.recordingTime)){
            if (tempoLineDown.recordState==0){
                tempoLineDown.recordState=1;
            }
            tempoLineDown.bTimerReached = false;
        }
        
        if ((tempoLineDown.timeStamp>=tempoLineDown.recordingTime)&&!tempoLineDown.bTimerReached){
            if (tempoLineDown.recordState==3){
                tempoLineDown.recordState=2;
            }
            tempoLineDown.bTimerReached = true;
            tempoLineDown.bDownSoundRecordClick = true;
        }
    }
    else {
        tempoLineUp.recordingTime = 1000;
        tempoLineUp.timeStamp = ofGetElapsedTimeMillis() - tempoLineUp.startTime;
        
        if ((tempoLineUp.timeStamp<tempoLineUp.recordingTime)){
            if (tempoLineUp.recordState==0){
                tempoLineUp.recordState=1;
            }
            tempoLineUp.bTimerReached = false;
        }
        
        if ((tempoLineUp.timeStamp>=tempoLineUp.recordingTime)&&!tempoLineUp.bTimerReached){
            if (tempoLineUp.recordState==3){
                tempoLineUp.recordState=2;
            }
            tempoLineUp.bTimerReached = true;
            tempoLineUp.bDownSoundRecordClick = true;
        }
    }
}

void ofApp::audioOut(float * output, int bufferSize, int nChannels){
    
//    tempo = (float)ofMap(tempoLineDown.length/12, 0, 1024/12, 360, 60);
//    
//    int _indexCounter = thredCounter%8;
//    
//    if ((elementLinesDown[_indexCounter].soundTrigger)&&tempoLineDown.bBeingClick){
//        elementLinesDown[_indexCounter].onOffTrigger = true;
//        elementLinesDown[_indexCounter].samplePlay.play();
//        //                    elementLinesDown[i].samplePlay.setVolume( ofRandom(0.325,0.95) * tempoLineDown.soundVolume);
//        elementLinesDown[_indexCounter].samplePlay.setVolume( tempoLineDown.soundVolume);
//        elementLinesDown[_indexCounter].samplePlay.setSpeed( ofMap(elementLinesDown[_indexCounter].lengthRect.y, 0, ofGetHeight()/2, 3.0, 0) * ofRandom(0.75,1.25) );
//        //                elementLinesDown[_indexCounter].samplePlay.setSpeed( ofMap(elementLinesDown[_indexCounter].lengthRect.y, 0, ofGetHeight()/2, 3.0, 0));
//    }
//    
//    triggerCounterDown++;

    //		for(int i = 0; i < bufferSize; i++){
    //			output[i * nChannels] = ofRandomf();
    //			output[i * nChannels + 1] = ofRandomf();
    //		}
	
}
void ofApp::audioIn(float * input, int bufferSize, int nChannels)
{
    
    if (initialBufferSize != bufferSize){
        ofLog(OF_LOG_ERROR, "your buffer size was set to %i - but the stream needs a buffer size of %i", initialBufferSize, bufferSize);
        return;
    }
    
    for (int i = 0; i < bufferSize; i++){
        buffer[i] = input[i];
    }
    bufferCounter++;
    
    if ((tempoLineDown.recordState==1)&&(soundRecordingDownOn)){
        tempoLineDown.recordState=3;
        tempoLineDown.myWavWriter.open(ofToDataPath("sounds/recordingDown.wav"), WAVFILE_WRITE);
    }
    
    if (tempoLineDown.recordState==3){
        tempoLineDown.myWavWriter.write(input, bufferSize*nChannels);
    }
    
    if (tempoLineDown.recordState==2){
        tempoLineDown.myWavWriter.close();
        tempoLineDown.recordState=0;
        for (int i = 0; i<nElementLine; i++)
        {
            elementLinesDown[i].samplePlay.loadSound("sounds/recordingDown.wav");
        }
    }
    
    if ((tempoLineUp.recordState==1)&&(soundRecordingDownOn)){
        tempoLineUp.recordState=3;
        tempoLineUp.myWavWriter.open(ofToDataPath("sounds/recordingUp.wav"), WAVFILE_WRITE);
    }
    
    if (tempoLineUp.recordState==3){
        tempoLineUp.myWavWriter.write(input, bufferSize*nChannels);
    }
    
    if (tempoLineUp.recordState==2){
        tempoLineUp.myWavWriter.close();
        tempoLineUp.recordState=0;
        for (int i = 0; i<nElementLine; i++){
            elementLinesUp[i].samplePlay.loadSound("sounds/recordingUp.wav");
        }
    }
    
}



bool ofApp::inOutCal(float x, float y, ofVec2f xyN, int distSize){
    float _diffx = x - xyN.x;
    float _diffy = y - xyN.y;
    float _diff = sqrt(_diffx*_diffx + _diffy*_diffy);
    if (_diff < distSize){
        return true;
    }
    else{
        return false;
    }
}

bool ofApp::onOffOut(float x, float y, ofVec2f xyN, int distSize, bool _b){
    float _diffx = x - xyN.x;
    float _diffy = y - xyN.y;
    float _diff = sqrt(_diffx*_diffx + _diffy*_diffy);
    if (_diff < distSize){
        return _b = !_b;
    }
    else{
        return _b = _b;
    }
}


void ofApp::exit(){
    
}


void ofApp::touchDown(ofTouchEventArgs & touch){
    
    float _contactControlPointSize = controlPointSize;
    
    tempoLineDown.bBeingClick = onOffOut(touch.x, touch.y - ofGetHeight()/2-controlPointSize, tempoLineDown.onOffRectPos, _contactControlPointSize, tempoLineDown.bBeingClick);
    tempoLineDown.bLengthBeingDragged = inOutCal(touch.x, touch.y - ofGetHeight()/2-controlPointSize, tempoLineDown.lengthRectPos, _contactControlPointSize);
    tempoLineUp.bBeingClick = onOffOut(touch.x, touch.y - ofGetHeight()/2+controlPointSize, tempoLineUp.onOffRectPos, _contactControlPointSize, tempoLineUp.bBeingClick);
    tempoLineUp.bLengthBeingDragged = inOutCal(touch.x, touch.y - ofGetHeight()/2+controlPointSize, tempoLineUp.lengthRectPos, _contactControlPointSize);
    
    tempoLineDown.bDownSoundRecordClick = onOffOut(touch.x, touch.y - ofGetHeight()/2-controlPointSize*1.5, tempoLineDown.bDownSoundRecordPos+ofVec2f(initialBufferSize/8/2,initialBufferSize/8/2+1), initialBufferSize/8/2, tempoLineDown.bDownSoundRecordClick);
    tempoLineUp.bDownSoundRecordClick = onOffOut(touch.x, touch.y - ofGetHeight()/2-controlPointSize*1.5, tempoLineUp.bDownSoundRecordPos+ofVec2f(initialBufferSize/8/2,initialBufferSize/8/2+1), initialBufferSize/8/2, tempoLineUp.bDownSoundRecordClick);
    
    for (int i = 0; i < nElementLine; i++){
        elementLinesDown[i].bLengthBeingDragged = inOutCal(touch.x, touch.y - ofGetHeight()/2-_contactControlPointSize*1.5, elementLinesDown[i].lengthRect, elementLinesDown[i].width);
        elementLinesUp[i].bLengthBeingDragged = inOutCal(touch.x-_contactControlPointSize/2, touch.y - ofGetHeight()/2+_contactControlPointSize/2, elementLinesUp[i].lengthRect, elementLinesUp[i].width);
        
        if (tempoLineDown.bBeingClick){
            elementLinesDown[i].bBeingClick = onOffOut(touch.x, touch.y - ofGetHeight()/2-_contactControlPointSize*1.5, elementLinesDown[i].onOffRect, _contactControlPointSize, elementLinesDown[i].bBeingClick);
            elementLinesDown[i].soundTrigger = onOffOut(touch.x, touch.y - ofGetHeight()/2-_contactControlPointSize*1.5, elementLinesDown[i].onOffRect, _contactControlPointSize, elementLinesDown[i].soundTrigger);
        }
        
        if (tempoLineUp.bBeingClick){
            elementLinesUp[i].bBeingClick = onOffOut(touch.x, touch.y - ofGetHeight()/2+_contactControlPointSize*1.5, elementLinesUp[i].onOffRect, _contactControlPointSize, elementLinesUp[i].bBeingClick);
            elementLinesUp[i].soundTrigger = onOffOut(touch.x, touch.y - ofGetHeight()/2+_contactControlPointSize*1.5, elementLinesUp[i].onOffRect, _contactControlPointSize, elementLinesUp[i].soundTrigger);
        }
    }
}

void ofApp::touchMoved(ofTouchEventArgs & touch){
    
    for (int i = 0; i < nElementLine; i++){
        if (elementLinesDown[i].bLengthBeingDragged == true){
            if (touch.y<ofGetHeight()/2+55){
                touch.y = ofGetHeight()/2+55;
            }
            if (touch.y>ofGetHeight()-20){
                touch.y = ofGetHeight()-20;
            }
            elementLinesDown[i].lengthRect.y = touch.y - ofGetHeight()/2-controlPointSize;
        }
    }
    
    for (int i = 0; i < nElementLine; i++){
        if (elementLinesUp[i].bLengthBeingDragged == true){
            if (touch.y>ofGetHeight()/2-55) {
                touch.y = ofGetHeight()/2-55;
            }
            if (touch.y<20) {
                touch.y = 20;
            }
            elementLinesUp[i].lengthRect.y = touch.y - ofGetHeight()/2+controlPointSize;
        }
    }
    
    if (tempoLineDown.bLengthBeingDragged == true){
        if (touch.x<ofGetWidth()/2+ofGetWidth()*0.07) {
            touch.x = ofGetWidth()/2+ofGetWidth()*0.07;
        }
        if (touch.x>ofGetWidth()-ofGetWidth()*0.11){
            touch.x = ofGetWidth()-ofGetWidth()*0.11;
        }
        tempoLineDown.lengthRectPos.x = touch.x;
    }
    
    if (tempoLineUp.bLengthBeingDragged == true){
        tempoLineUp.position.x = touch.x - (tempoLineUp.length/2+ofGetWidth()/2);
        if (tempoLineUp.position.x>49){
            tempoLineUp.position.x = 49;
        }
        if (tempoLineUp.position.x<-49){
            tempoLineUp.position.x = -49;
        }
    }
}


void ofApp::touchUp(ofTouchEventArgs & touch){
    //    tempoLineDown.bChangeSampleClick = onOffOut(touch.x, touch.y, tempoLineDown.changeSamplePos, 30, tempoLineDown.bChangeSampleClick);
    //    tempoLineUp.bChangeSampleClick = onOffOut(touch.x, touch.y, tempoLineUp.changeSamplePos, 30, tempoLineUp.bChangeSampleClick);
    //    if(inOutCal(touch.x, touch.y, tempoLineDown.changeSamplePos, 30)) tempoLineDown.bChangeSampleClick = false;
    //    if(inOutCal(touch.x, touch.y, tempoLineUp.changeSamplePos, 30)) tempoLineUp.bChangeSampleClick = false;
}

void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    tempoLineDown.bChangeSampleClick = onOffOut(touch.x, touch.y, tempoLineDown.changeSamplePos, 30, tempoLineDown.bChangeSampleClick);
    tempoLineUp.bChangeSampleClick = onOffOut(touch.x, touch.y, tempoLineUp.changeSamplePos, 30, tempoLineUp.bChangeSampleClick);
    
    if (touch.y>ofGetHeight()/2) {
        tempoLineDown.bChangeSampleClick = true;
    }
    
    if (touch.y<ofGetHeight()/2) {
        tempoLineUp.bChangeSampleClick = true;
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
