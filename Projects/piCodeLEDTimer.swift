// Created with PiCode for Swift 3.0
// A Swift-Lite project file
// type:project
// name:piCodeflashLED
// include:piCodeGPIO.swift

import Glibc
import Foundation

// auto detect board type (detects all boards with 40 GPIO pins)
let gpios = autoDetectBoardType()

// for older boards with 26 GPIO pins please set board type manually
//let gpios = PiCodeGPIO.RPIRev1
//let gpios = PiCodeGPIO.RPIRev2

// set output pin
var gp = gpios[.P17]!
gp.direction = .OUT
gp.value = 1


var  intervalTimer: Timer!
var flashTimer: Timer!

var flashNumber = 5


func runIntervalTimer() {
    intervalTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: {(_) in flashOnLED()})
}
func runflashTimer() {
    flashTimer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false, block: {(_) in flashOffLED()})
}

func flashOnLED() {
    print("flash on")
    gp.value = 1
    runflashTimer()    
}

func flashOffLED() {
    gp.value = 0
    print("flash off")
    flashNumber -= 1
    if flashNumber == 0 {
        intervalTimer.invalidate()
        print("finished")
    }
    
}

runIntervalTimer()

let flashLEDLoop = RunLoop.current
flashLEDLoop.add(intervalTimer, forMode: .defaultRunLoopMode)


flashLEDLoop.run(until: Date(timeIntervalSinceNow: 11))

