//
//  ThreadedObject.cpp
//  microSeqiOS
//
//  Created by JH.Park on 19.03.14.
//
//

#include "ThreadedObject.h"
#include "ofApp.h"


//--------------------------
ThreadedObject::ThreadedObject(){
//    count = 0;
}

void ThreadedObject::setup(){
    
//    samplePlayer0.loadSound("tap_01.wav");
    
}
//
//void ThreadedObject::start(){
//    startThread();   // blocking, verbose
//}

void ThreadedObject::start(ofApp* p){

    parent = p;
    notes = 0;
    startThread();

}

void ThreadedObject::stop(){
    
//    count = 0;
    
    stopThread();
}


//void ThreadedObject::setTempo(float _tempo){
//    tempo = round(60000.0*0.25/(_tempo));
//}


//--------------------------
void ThreadedObject::threadedFunction(){
    
    while( isThreadRunning() != 0 ){
        if( lock() ){
            notes++;
            if(notes > 50000) notes = 0;
//            trigger = true;
            unlock();
            // Phrase complete
            if (notes >= notesPerPhrase) {
                
                // Call function on main app
                parent->phraseComplete();
                
                // Reset count
                notes = 0;
                
//                samplePlayer0.play();
                
            }
            
            // Sleep for duration of one note
            ofSleepMillis(parent->calculateNoteDuration());
        }
    }
}

//void ThreadedObject::audioOut(float * output, int bufferSize, int nChannels){
//    
//	
//}


////--------------------------
//void ThreadedObject::draw(){
//    
//    string str = "I am a slowly increasing thread. \nmy current count is: ";
//    
//    if( lock() ){
//        str += ofToString(count);
//        unlock();
//    }else{
//        str = "can't lock!\neither an error\nor the thread has stopped";
//    }
//    ofDrawBitmapString(str, 50, 56);
//    
//}
//
//void ThreadedObject::play(){
//    
//}

