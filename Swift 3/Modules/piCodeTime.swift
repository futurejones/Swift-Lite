// Created with PiCode for Swift 3.0
// A Swift-Lite module file
// type:module
// name:piCodeTime

import Glibc
import Foundation
import Dispatch

// function for inserting wait time in seconds
func wait(time: Double) {
    let nanoTime = time * 1000000000  // convert to nanoseconds
    let UI64Time = UInt64(nanoTime)  // convert to UInt64
    let pauseTime = DispatchTime.now().uptimeNanoseconds
    while (DispatchTime.now().uptimeNanoseconds <= pauseTime + UI64Time) {
        // wait time
    }   
}
