#pragma once

#include "ofMain.h"
#include "ofThread.h"

class ofApp;

class ThreadedObject : public ofThread
{
    
public:
    
    ThreadedObject();
    
    void setup();
//    void start();
    void start(ofApp* p);
    void stop();
    
    int notes;
    int notesPerPhrase;

//    void setTempo(float _tempo);
    
    void threadedFunction();
    void getCount();

//    void draw();
//    void play();
//    
//    int count;
//    
//    float tempo;
//    bool trigger;
    
    ofApp* parent;

//    void audioOut(float * output, int bufferSize, int nChannels);
//    ofSoundPlayer samplePlayer0;
    
};
