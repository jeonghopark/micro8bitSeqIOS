#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "WavFile.h"

//#include "ThreadedObject.h"

#include "ofxTonic.h"

using namespace Tonic;

//#define DEBUG_MODE
//
//#ifdef DEBUG_MODE
//bool debug_mode = true;
//#endif


typedef struct{
    ofVec2f position;
    bool 	bLengthBeingDragged;
    bool 	bBeingClick;
    bool 	bLengthOver;
    bool 	bOnOffOver;
    ofVec2f onOffPos;
    ofVec2f pitchPos;
    bool onOffTrigger;
    bool soundTrigger;
    int counter;
    ofSoundPlayer samplePlay;
    int triggerColor;
}
controlElementLine;

typedef struct{
    ofVec2f position;
    bool 	bLengthBeingDragged;
    bool 	bBeingClick;
    bool 	bLengthOver;
    bool 	bOnOffOver;
    ofVec2f onOffPos;
    ofVec2f lengthPos;
    float length;
    ofVec2f delayPos;
    bool 	bDelayPosOver;
    bool    bDelayPosDragged;
    
    ofVec2f recBlockPos;
    float rectBlockAlphaFactor;
    float recordingTime;
    float startTime;
    
    WavFile myWavWriter;
    int recordState;
    bool bTimerReached;
    float timeStamp;
    
    ofVec2f bDownSoundRecordPos;
    bool bDownSoundRecordClick;
    float soundVolume;
    
    ofVec2f changeSamplePos;
    bool bChangeSampleClick;
    bool bChangeSampleOver;
    int changeSampleIndex;
}
controlTempoLine;


class ofApp : public ofxiOSApp{
    
    ofxTonicSynth synthMain;
    
    
public:
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    void threadedFunction();
    
    bool inOutCal(ofVec2f input, ofVec2f xyN, int distSize);
    bool onOffOut(ofVec2f input, ofVec2f xyN, int distSize, bool _b);
    
    string fileNameUp;
    string fileNameDown;
    
    float sampleMainVolume;
    
    ofSoundStream soundStream;
    
    void audioReceived(float * input, int bufferSize, int nChannels);
    void audioRequested(float *output, int bufferSize, int nChannels);
    
    int	initialBufferSize;
    int	sampleRate;
    int	drawCounter;
    float * buffer;
    
    int nElementLine;
    controlElementLine elementDown[8];
    controlElementLine elementUp[8];
    
    float spacingLineDown;
    float spacingLineUp;
    
    controlTempoLine downPart;
    controlTempoLine upPart;
    
    int backgroundColorHue;
    
    int startTime;
    
    void downPartDraw();
    void upPartDraw();
    
    float recBlockSize;
    
    ofDirectory dir;
    
    void drawMainLine(bool _bTOnOff, bool _bTSizeOver, bool _bTOnOffOver, ofVec2f _vTSizePos, ofVec2f _vTOnOffPos);
    
    
    void recordingLineDraw(ofVec2f _vP);
    
    float randomY[16];
    
    int ctrlRectSize;
    
    int delayupPart;
    
    void touchGuideLine();
    
    float rectSizeRatio;
    
    ofVec2f touchPos;
    
    // Thread
    //    ThreadedObject threadedObject;
    float tempo;
    void phraseUpComplete(int _index, int _min, int _max);
    void phraseDnComplete();
    //    int calculateNoteDuration();
    
    int threadDownCounter;
    int threadUpCounter;
    int indexCounterDn;
    int indexCounterUp;
    
    int upIndex;
    int dnIndex;
    
    // Menu
    void recordDraw();
    void drawSampleChangeButton();
    void stopStartDraw();
    void menuSetting();
    ofRectangle sampleChangeButton;
    ofRectangle mainStartStop;
    ofRectangle waveRecord;
    ofVec2f waveRecordPos;
    bool bSampleChange;
    bool bMainStartStop;
    bool bWaveRect;
    
    //tempo
    float maxLine;
    float minLine;
    float maxTempo;
    float minTempo;
    
    float minRecordRectPosX;
    float sampleRecordingTime;
    
    
    int menuStartStopSize, menuStartRectSpacing;
    
    // MODE
    bool debugMode;
    void debugModeView(int _i, string _pos);
    
    
    // Tonic
    int screenW, screenH;
    int maxSpeed, minSpeed;
    void synthSetting();
    ControlGenerator bpm;
    ControlGenerator metro;
    ofEvent<float> * metroOut;
    void triggerReceive(float & metro);
    int index;
    int noteIndex;
    void noteTrigger();
    
    //New Control
    float delayTouchDownPos;
    float delayTouchMovingPos;
    float delayValueSaved;
    float delayValue;
    int movingFactor;
    
    float tempoTouchDownPos;
    float tempoTouchMovingPos;
    float tempoValueSaved;
    float tempoValue;
    int tempoMovingFactor;
    
};


