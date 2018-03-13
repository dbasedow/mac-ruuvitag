import Foundation
import Cocoa

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate

let ret = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
