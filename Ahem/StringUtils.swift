//
//  StringUtils.swift
//  Ahem
//
//  Created by Brian Sanders on 5/1/18.
//  Copyright © 2018 Brian Sanders. All rights reserved.
//

import Foundation

protocol MatchGroups {
    func matchString(str: String) -> [String?]?
}

protocol RangeString {
    func makeString(range: NSRange) -> String
}

extension String: RangeString {
    func makeString(range: NSRange) -> String {
        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(start, offsetBy: range.length)
        return String(self[start..<end])
    }
}

extension NSRegularExpression: MatchGroups {
    func matchString(str: String) -> [String?]? {
        if let match = self.firstMatch(in: str, options: .anchored, range: NSMakeRange(0, str.count)) {
            return (0..<match.numberOfRanges).map {
                let range = match.range(at: $0)
                if range.lowerBound == NSNotFound {
                    return nil
                } else {
                    return str.makeString(range: range)
                }
            }
        }
        
        return nil
    }
}
