// ActionBee
//
// Executable Source Template - v1.0
//

import Definition
import Foundation
import Cocoa

public enum ActionBee {
    
    public static func solutionMain(event: ArgumentData, completion: @escaping (RecipeData?) -> Never) throws {        
        let text = event.pasteboardContent
        let types: NSTextCheckingResult.CheckingType = .link
        let detector = try? NSDataDetector(types: types.rawValue)
        guard let detect = detector else {
            completion(.none)
        }
        let matches = detect.matches(
            in: text,
            options: .reportCompletion,
            range: NSMakeRange(0, text.count)
        )
        
        var stringComps: [StringComps] = [
            .init(isLink: false, messgae: "")
        ]
        
        guard !matches.isEmpty else {
            completion(.none)
        }
        
        // lazy man slow process but it works~
        for idx in 0 ..< text.count {
            let char = text[idx]
            var isLink = false
            for match in matches {
                if match.range.contains(idx) {
                    isLink = true
                    break
                }
            }
            if stringComps[stringComps.count - 1].isLink == isLink {
                stringComps[stringComps.count - 1].messgae += String(char)
            } else {
                stringComps.append(.init(isLink: isLink, messgae: String(char)))
            }
        }
        
        var processed = false
        stringComps = stringComps.map { comps -> StringComps in
            if !comps.isLink { return comps }
            guard let url = URL(string: comps.messgae) else {
                return comps
            }
            for cleaner in cleaners {
                if cleaner.isPotentialCandidate(original: url),
                   let newUrl = cleaner.process(original: url)
                {
                    processed = true
                    return .init(isLink: comps.isLink, messgae: newUrl.absoluteString)
                }
            }
            return comps
        }
        
        let newText = stringComps
            .map(\.messgae)
            .joined()
        
        guard processed else {
            completion(.none)
        }
        
        let result = RecipeData(
            postAction: .overwrite,
            postContent: newText,
            continueQueue: true
        )
        completion(result)
    }
    
    struct StringComps {
        var isLink: Bool
        var messgae: String
    }
    
}

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}
