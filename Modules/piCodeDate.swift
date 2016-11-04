// PiCode Date for Swift 3.0
// A Swift-Lite Module File
// type:module
// name:piCodeDate

import Foundation

    func printToday(){
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        
        let dateString = dateFormatter.string(from: date as Date)
        
        print("FullStyle Date Format = \(dateString)") 
        
        }
        
