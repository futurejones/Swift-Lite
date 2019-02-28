// PiCode Shell for Swift 3.0
// A Swift-Lite module file
// type:module
// name:PiCodeShell

import Foundation

	func shell(command: String) {
	  // Create a Task instance
	  let task = Task()

	  // Set the task parameters
	  task.launchPath = "/bin/bash"
	  task.arguments = ["-c", command]

	  // Launch the task
	  task.launch()
	  task.waitUntilExit()
	}
