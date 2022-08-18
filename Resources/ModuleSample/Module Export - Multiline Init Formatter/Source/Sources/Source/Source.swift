// ActionBee
//
// Executable Source Template - v1.0
//

import Definition
import Foundation

/*

 ⚠️

 Only changes within the current directory will be committed to the compiler,
     other modifications outside Source dir will be ignored when build.

 You can add any package dependencies in Package.swift, process your need, and
     build us a recipe.

 */

public enum ActionBee {
    public static func solutionMain(event: ArgumentData, completion: @escaping (RecipeData?) -> Never) throws {
        guard event.pasteboardContent.hasPrefix("init("),
              event.pasteboardContent.hasSuffix(")")
        else {
            completion(.none)
        }
        
        var payload = event.pasteboardContent
        payload.removeFirst("init(".count)
        payload.removeLast(")".count)
        payload = payload
            .components(separatedBy: ",")
            .joined(separator: ",\n")
        
        payload = "init(\n\(payload)\n)"
        
        completion(RecipeData(
            postAction: .overwrite,
            postContent: payload,
            continueQueue: false
        ))
    }
}
