// Flash LED Timer for Swift 4
// A Swift-Lite project file
// type:project
// name:flashLEDTimer

import Foundation
import GPIO

// auto detect board type
let gpios = autoDetectBoardType()

// setup the GPIO pins
var gp = gpios[.P17]!   // Pin to conect the LED to
gp.direction = .OUT     // Pin connection direction - OUT - when turned on the pin will output 5v
gp.value = 0            // Set intial value 0 = off 1 = on


var intervalTimer: Timer!   // this timer controls the time intervals the LED turns on. As this is a repeating timer it needs to be added to a runloop.
var flashTimer: Timer!      // this timer controls the length of time the LED remains on.

var flashNumber = 5     // the number of flashes

var flashIntervalTime: Double = 2.0     // the time between the start of each flash

var flashLengthTime: Double = 0.75  // the length of time of each flash

var runLoopTime: Double = 11    // the lenghth of time the runloop will run - set this to be longer than the time for all the flashes to complete
// the runloop can be set to continous if the is action you need.


func runIntervalTimer() {
    intervalTimer = Timer.scheduledTimer(withTimeInterval: flashIntervalTime, repeats: true, block: {(_) in flashOnLED()})
}

func runflashTimer() {
    flashTimer = Timer.scheduledTimer(withTimeInterval: flashLengthTime, repeats: false, block: {(_) in flashOffLED()})
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

flashLEDLoop.run(until: Date(timeIntervalSinceNow: runLoopTime))

