import Foundation

private let decoder = JSONDecoder()
private let encoder = JSONEncoder()

public struct ArgumentData: Codable {
    public let focusAppID: String?
    public let focusAppName: String?
    public let pasteboardContent: String

    public init(focusAppID: String?, focusAppName: String?, pasteboardContent: String) {
        self.focusAppID = focusAppID
        self.focusAppName = focusAppName
        self.pasteboardContent = pasteboardContent
    }

    public func compileBase64() -> String? {
        (try? encoder.encode(self))?.base64EncodedString()
    }

    public static func retrieve(withData data: Data) -> ArgumentData? {
        try? decoder.decode(ArgumentData.self, from: data)
    }
}

public struct RecipeData: Codable {
    public let postAction: PostAction
    public let postContent: String
    public let continueQueue: Bool

    public enum PostAction: String, Codable {
        case overwrite
        case speak
        case none
    }

    public init(postAction: PostAction, postContent: String, continueQueue: Bool) {
        self.postAction = postAction
        self.postContent = postContent
        self.continueQueue = continueQueue
    }

    public func compileBase64() -> String? {
        (try? encoder.encode(self))?.base64EncodedString()
    }

    public static func retrieve(withData data: Data) -> Self? {
        try? decoder.decode(Self.self, from: data)
    }
}
