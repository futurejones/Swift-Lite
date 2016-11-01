// Created with SwiftPi
// A Swift-Lite Module File
// type:module
// name:date

import Foundation

    func printToday(){
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        
        let dateString = dateFormatter.string(from: date as Date)
        
        print("FullStyle Date Format = \(dateString)") 
        
        }
        
