#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "WavFile.h"


//#define LENGTH 44100 // 10 seconds


typedef struct
{
	ofVec2f position;
	bool 	bLengthBeingDragged;
	bool 	bBeingClick;
	bool 	bLengthOver;
	bool 	bOnOffOver;
	float 	width;
    ofVec2f onOffRectPos;
    ofVec2f pitchRectPos;
    bool onOffTrigger;
    bool soundTrigger;
    int counter;
    ofSoundPlayer samplePlay;
    int triggerColor;
}
controlElementLine;

typedef struct
{
	ofVec2f position;
	ofVec2f oldPosition;
	bool 	bLengthBeingDragged;
	bool 	bBeingClick;
	bool 	bLengthOver;
	bool 	bOnOffOver;
	float 	width;
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
    int recordState=0;
    bool bTimerReached;
    int timeStamp;
    
    ofVec2f bDownSoundRecordPos;
    bool bDownSoundRecordClick;
    float soundVolume;
    
    ofVec2f changeSamplePos;
    float changeSampleSize;
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
    
    int speedUp;
    int speedDown;
    
    string fileNameUp;
    string fileNameDown;
    
    float sampleMainVolume;
    
    ofSoundStream soundStream;

    void audioReceived(float * input, int bufferSize, int nChannels);
    void audioRequested(float *output, int bufferSize, int nChannels);

    int	initialBufferSize;
	int	sampleRate;
	int	drawCounter;
    int bufferCounter;
	float * buffer;
    
	bool bIsRecording;
	int channels;
    
    int nElementLine;
    controlElementLine elementDown[8];
    controlElementLine elementUp[8];
    
    float spacingLineDown;
    float spacingLineUp;
    
    controlTempoLine downPart;
    controlTempoLine upPart;
    
//    vector <ofSoundPlayer> draggedSound;
//    ofPoint dragPt;
    
    int backgroundColorHue;
    
    int tempoLineRelativePos;
    
    int tempoDistanceFactor;
    
    int triggerCounterUp;
    int triggerCounterDown;
    
    int startTime;
    int millisDown;
    bool bangUp;
    bool bangDown;
    
    void downPartDraw();
    void upPartDraw();
    
    float recBlockSize;
    
    ofDirectory dir;
    vector<ofSoundPlayer> soundsList;
    
    int currentSound;
    
    void drawingTempoLine(bool _bTOnOff, bool _bTSizeOver, bool _bTOnOffOver, ofVec2f _vTSizePos, ofVec2f _vTOnOffPos);
    
    bool soundRecordingDownOn;
    bool recordTrigger;
    
    void recordingLineDraw(ofVec2f _vP);
    
    void infomationWindow();
    
    float randomY[16];
    
    int controlRectSize;

    void setBPM(float targetBPM);
    int pos;
    float BPM;
    float lengthOfOneBeatInSamples;

    int counterBPM;
    bool startBeatDetected;
    int beatIndex;
    int beatIndexUp;
    int delayupPart;
    
    float speedTempo;
    
    void touchGuideLine();
    
    float rectSizeRatio;
    
    ofVec2f touchPos;
    
    int countBeat;
    int countBeatUp;
    int counterBPMUp;
    
    int indexBPM;
    

    int initialTime;
    float setTempoMilisecond;
    
    ofSoundPlayer samplePlay0;
    ofSoundPlayer samplePlay1;
    ofSoundPlayer samplePlay2;
    ofSoundPlayer samplePlay3;
    ofSoundPlayer samplePlay4;
    ofSoundPlayer samplePlay5;
    ofSoundPlayer samplePlay6;
    ofSoundPlayer samplePlay7;

    
    int testCounter;
    
};


