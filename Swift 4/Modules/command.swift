// Command for Swift 4
// A Swift-Lite module file
// type:module
// name:command.swift

import Foundation

	func shell(command: String) {
	  // Create a Task instance
	  let task = Process()

	  // Set the task parameters
	  task.launchPath = "/bin/bash"
	  task.arguments = ["-c", command]

	  // Launch the task
	  task.launch()
	  task.waitUntilExit()
	}
