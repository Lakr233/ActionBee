// ActionBee
//
// Executable Source Template - v1.0
//

import Definition
import Foundation
import Cocoa

/*

 ⚠️

 Only changes within the current directory will be committed to the compiler,
     other modifications outside Source dir will be ignored when build.

 You can add any package dependencies in Package.swift, process your need, and
     build us a recipe.

 */

public enum ActionBee {
    public static func solutionMain(event: ArgumentData, completion: @escaping (RecipeData?) -> Never) throws {

        let text = event.pasteboardContent
        
        if #available(macOS 11.0, *) {
            if NSImage(systemSymbolName: text, accessibilityDescription: nil) != nil {
                completion(.init(
                    postAction: .overwrite,
                    postContent: "Image(systemName: \"\(event.pasteboardContent)\")",
                    continueQueue: false
                ))
            }
        }
        
        completion(.none)
    }
}
