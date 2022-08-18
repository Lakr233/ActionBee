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
        completion(RecipeData(
           postAction: .speak,
           postContent: event.pasteboardContent,
           continueQueue: false
       ))
    }
}
