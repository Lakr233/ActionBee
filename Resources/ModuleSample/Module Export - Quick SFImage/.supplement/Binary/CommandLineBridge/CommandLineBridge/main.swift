//
//  main.swift
//  CommandLineBridge
//
//  Created by Lakr Aream on 2022/8/13.
//

import Communicator
import Definition
import Foundation
import Source

guard let data = Communicator.retrieveParentData() else {
    fatalError("unable to receive argument data")
}

guard let argument = ArgumentData.retrieve(withData: data) else {
    fatalError("unable to receive argument object")
}

private let defaultRecipe: RecipeData = .init(
    postAction: .none,
    postContent: "",
    continueQueue: true
)

let completion: ((RecipeData?) -> Never) = { recipe in
    guard let recipe = recipe else {
        Communicator.sendRecipeDataAndExit(defaultRecipe.compileBase64()!)
        fatalError("malformed program flow")
    }
    guard let recipeBase64String = recipe.compileBase64() else {
        fatalError("failed to compile recipe data")
    }
    Communicator.sendRecipeDataAndExit(recipeBase64String)
    fatalError("malformed program flow")
}

do {
    try ActionBee.solutionMain(event: argument, completion: completion)
} catch {
    print(error.localizedDescription)
    Communicator.sendRecipeDataAndExit(defaultRecipe.compileBase64()!)
    fatalError("malformed program flow")
}

CFRunLoopRun()
