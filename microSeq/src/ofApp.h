#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "WavFile.h"

#include "ThreadedObject.h"

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
    ofVec2f onOffRectPos;
    ofVec2f pitchRectPos;
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
    ofVec2f onOffRectPos;
    ofVec2f lengthRectPos;
    float length;
    ofVec2f delayPos;
    bool 	bDelayPosOver;
    bool    bDelayPosDragged;
    
    ofVec2f recBlockPos;
    float rectBlockAlphaFactor;
    int recordingTime;
    int startTime;
    
    WavFile myWavWriter;
    int recordState;
    bool bTimerReached;
    int timeStamp;
    
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
    
    void drawingTempoLine(bool _bTOnOff, bool _bTSizeOver, bool _bTOnOffOver, ofVec2f _vTSizePos, ofVec2f _vTOnOffPos);
    
    bool soundRecordingDownOn;
    bool recordTrigger;
    
    void recordingLineDraw(ofVec2f _vP);
    
    void fadeInBackground();
    
    float randomY[16];
    
    int ctrlRectSize;
    
    int delayupPart;
    
    void touchGuideLine();
    
    float rectSizeRatio;
    
    ofVec2f touchPos;
    
    // Thread
    ThreadedObject threadedObject;
    float tempo;
    void phraseComplete();
    int calculateNoteDuration();
    
    int thredCounter;
    int indexCounterDn;
    int indexCounterUp;
    
    int upIndex;
    int dnIndex;
    
    // Menu
    void menuDraw();
    void menuSetting();
    ofRectangle sampleChange;
    ofRectangle mainMenu;
    ofRectangle waveRecord;
    ofVec2f waveRecordPos;
    bool sampleChangeMenu;
    bool mainStartStop;
    int mainTempo;
    bool bWaveRect;
    
    //tempo
    float maxLine;
    float minLine;
    float maxTempo;
    float minTempo;
    
    float minRecordRectPosX;
    float sampleRecordingTime;
    
    float upIndexOldTimer;
    
    int menuStartRectSize, menuStartRectSpacing;
    
    // MODE
    bool debugMode;
    void debugModeView(int _i, string _pos);
  
    float volumeParameter;
    
};

