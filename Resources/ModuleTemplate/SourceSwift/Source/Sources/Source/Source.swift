// ActionBee
//
// Executable Source Template - v1.0
//

import Definition
import Foundation

/*

 ⚠️

 Only changes within the current directory will be committed to the compiler,
     other modifications outside ./Source/Sources dir will be ignored when build.

 */

public enum ActionBee {
    public static func solutionMain(event: ArgumentData, completion: @escaping (RecipeData?) -> Never) throws {
        // do your workflow here, but avoid changing the pasteboard

        let appName = event.focusAppID
        let appID = event.focusAppID
        let content = event.pasteboardContent

        print(
            """
            ====================
            \(appName ?? "unknown app") - \(appID ?? "unknown app id")
            \(content)
            ====================
            """
        )

        // after your work is done, return the recipe and tell parent to do the job
        // return nil if failed to process
        let result = RecipeData(
            postAction: .speak,
            postContent: "Hello World",
            continueQueue: false
        )
        completion(result)
    }
}
