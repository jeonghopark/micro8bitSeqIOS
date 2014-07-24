#pragma once

#ifndef _THREADED_OBJECT
#define _THREADED_OBJECT

#include "ofMain.h"

class ThreadedObject : public ofThread{
    
public:
    
    ThreadedObject();
    
    void setup();
    void start();
    void stop();
    
    void setTempo(float _tempo);
    
    void threadedFunction();
    
    void draw();
    void play();
    
    int count;
    
    float tempo;
    bool trigger;
    

};

#endif
