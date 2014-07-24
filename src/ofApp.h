#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "WavFile.h"

#include "ThreadedObject.h"

typedef struct
{
	ofVec2f position;
	bool 	bLengthBeingDragged;
	bool 	bBeingClick;
	bool 	bLengthOver;
	bool 	bOnOffOver;
	float 	width;
    ofVec2f onOffRect;
    ofVec2f lengthRect;
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
    
    bool inOutCal(float x, float y, ofVec2f xyN, int distSize);
    bool onOffOut(float x, float y, ofVec2f xyN, int distSize, bool _b);
    
    int speedUp;
    int speedDown;
    
    string fileNameUp;
    string fileNameDown;
    
    float highVolume;
    
    void audioIn(float * input, int bufferSize, int nChannels);
    
    int	initialBufferSize;
	int	sampleRate;
	int	drawCounter;
    int bufferCounter;
	float * buffer;
    
    ofSoundStream soundStream;
	bool bIsRecording;
	int channels;
    
    int nElementLine;
    controlElementLine elementLinesDown[8];
    controlElementLine elementLinesUp[8];
    
    float spacingLineDown;
    float spacingLineUp;
    
    controlTempoLine tempoLineDown;
    controlTempoLine tempoLineUp;
    
    vector <ofSoundPlayer> draggedSound;
    ofPoint dragPt;
    
    int backgroundColorHue;
    
    int tempoLineRelativePos;
    
    int tempoDistanceFactor;
    
    int triggerCounterUp;
    int triggerCounterDown;
    
    int startTime;
    int millisDown;
    bool bangUp;
    bool bangDown;
    
    
    
    ofDirectory dir;
    vector<ofSoundPlayer> soundsList;
    
    int currentSound;
    
    void drawingTempoLine(bool _bTOnOff, bool _bTSizeOver, bool _bTOnOffOver, ofVec2f _vTSizePos, ofVec2f _vTOnOffPos);
    
    bool soundRecordingDownOn;
    bool recordTrigger;
    
    void recordingLineDraw(ofVec2f _vP);
    
    void infomationWindow();
    
    float randomY[16];
    
    int controlPointSize;

    
    ThreadedObject TO;
};


