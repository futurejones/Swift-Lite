// Ultrasonics for Swift 4
// A Swift-Lite project file
// type:project
// name:ultrasonics
// include:time.swift

import Glibc
import Foundation
import Dispatch
import GPIO

// auto detect board type (detects all boards with 40 GPIO pins)
let gpios = autoDetectBoardType()

// set trigger pin
var gp_trigger = gpios[.P9]!
gp_trigger.direction = .OUT
gp_trigger.value = 0

// set echo pin
var gp_echo = gpios[.P11]!
gp_echo.direction = .IN
gp_echo.value = 0

// set echo time start/end variables
var startTime = DispatchTime.now()
var endTime = DispatchTime.now()

// Allow unit to stabilize for 0.5sec
wait(time: 0.5)

func getDistance() -> String {

    // Send a 10 micro second pulse to trigger
    gp_trigger.value = 1
    wait(time: 0.00001) // wait for 10 microseconds
    gp_trigger.value = 0

    // listen for echo return
    while (gp_echo.value == 0) {
        startTime = DispatchTime.now()
    }
    while (gp_echo.value == 1) {
        endTime = DispatchTime.now()
    }

    // Caculate echo time
    let timeInterval = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    print("echo time: \(timeInterval) nanoseconds")
    // multiplied by the speed of sound (cm/nanoseconds)
    var distance:Double = Double(timeInterval) * 0.000034300
    // Divide by 2 as it was a return distance
    distance = distance / 2
    // limit result to 2 decimal places
    let cm = String(format: "%0.2fcm", distance)

    return cm
}

var counter = 5  // set number of measurments

while (counter > 0) {
    let measurment = getDistance()
    print ("Distance : \(measurment)")
    counter -= 1

    wait(time: 1)  // allow 1 second between measurments
}
