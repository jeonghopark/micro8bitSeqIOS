//
//  ThreadedObject.cpp
//  microSeqiOS
//
//  Created by JH.Park on 19.03.14.
//
//

#include "ThreadedObject.h"


//--------------------------
ThreadedObject::ThreadedObject(){
    count = 0;
}

void ThreadedObject::setup(){
    
}

void ThreadedObject::start(){
    startThread(true, false);   // blocking, verbose
}

void ThreadedObject::stop(){
    
    count = 0;
    
    stopThread();
}


void ThreadedObject::setTempo(float _tempo){
    tempo = round(60000.0/_tempo);
}


//--------------------------
void ThreadedObject::threadedFunction(){
    
    while( isThreadRunning() != 0 ){
        if( lock() ){
            count++;
            if(count > 50000) count = 0;
            unlock();
            ofSleepMillis(1 * tempo);
            trigger = true;
        } else {
            trigger = false;
        }
    }
}

//--------------------------
void ThreadedObject::draw(){
    
    string str = "I am a slowly increasing thread. \nmy current count is: ";
    
    if( lock() ){
        str += ofToString(count);
        unlock();
    }else{
        str = "can't lock!\neither an error\nor the thread has stopped";
    }
    ofDrawBitmapString(str, 50, 56);
    
}

void ThreadedObject::play(){
    
}

