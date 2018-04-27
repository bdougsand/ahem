//
//  FeedParser.swift
//  Ahem
//
//  Created by Brian Sanders on 4/23/18.
//  Copyright © 2018 Brian Sanders. All rights reserved.
//

import Cocoa

func pad(_ n: Int) -> String {
    return String(repeating: "\t", count: n)
}

protocol FeedNode {
    var allText: String { get }
    var text: String { get }
    var childElements: [FeedElement] { get }
    var textElements: [String] { get }
}

protocol FeedNodeCollection {
    var childElements: [FeedElement] { get }
    var text: String { get }

    func withTag(tagName: String) -> [FeedElement]
}

extension Array: FeedNodeCollection where Element: FeedNode {
    var childElements: [FeedElement] {
        get {
            return self.flatMap { $0.childElements }
        }
    }
    var text: String {
        get {
            return self.text
        }
    }
    
    func withTag(tagName: String) -> [FeedElement] {
        return self.childElements.filter { $0.tagName == tagName }
    }
}

extension String : FeedNode {
    var childElements: [FeedElement] { return [] }
    var textElements: [String] { return [] }
    
    var allText: String { return self }
    var text: String { return self }
}
//
//enum FeedNode {
//    indirect case element(
//        tag: String,
//        attrs: [String: String],
//        children: [FeedNode])
//    case text(String)
//}

protocol FeedNav { }
extension String: FeedNav { }
//extension Int: FeedNav { }


class FeedElement: NSObject, FeedNode {
    var tagName: String!
    var children: [FeedNode] = []
    var attributes: [String: String] = [:]
    
    var childElements: [FeedElement] {
        return children.compactMap { $0 as? FeedElement }
    }
    
    var textElements: [String] {
        return children.compactMap( { $0 as? String })
    }
    
    var text: String {
        return textElements.joined()
    }
    
    var allText: String {
        return children.flatMap { (node) -> [String] in
            return [node.text]
        }.joined()
    }
    
    init(tagName: String, attributes: [String: String] = [:]) {
        self.tagName = tagName.lowercased()
        self.attributes = attributes
    }
    
    subscript(tagName: String) -> [FeedElement] {
        return childElements.filter { $0.tagName == tagName }
    }
    
    subscript(tagName: String) -> FeedElement? {
        return childElements.first(where: { $0.tagName == tagName })
    }
    
    subscript<T: Collection>(path: T) -> FeedElement? where T.Element: FeedNav {
        if let pathItem = path.first {
            if let pathItem = pathItem as? String {
                return (self[pathItem] )?[path.dropFirst()]
            }
        } else {
            return self
        }
        
        return nil
    }
}

class FeedParser: NSObject, XMLParserDelegate {
    var url: URL! = nil
    var complete = false
    var success = false
    var completeHandler: ((FeedParser) -> Void)? = nil
    
    private var level = 0
    private var elements: [FeedNode] = []
    var roots: [FeedElement] = []
    
    var childElements: [FeedElement] {
        return roots.childElements
    }
    
    init(url: URL) {
        self.url = url
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        elements.append(
            FeedElement(tagName: elementName, attributes: attributeDict))

    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let element = elements.popLast() {
            if let parent = elements.last as? FeedElement {
                parent.children.append(element)
            } else {
                let rootElement = element as! FeedElement
                roots.append(rootElement)
                rootElementAvailable(rootElement)
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let element = elements.last as? FeedElement {
            element.children.append(string)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        complete = true
    }
    
    func rootElementAvailable(_ rootElement: FeedElement) {
        print("A '\(rootElement.tagName)' root element is now available")
    }

    func start(handler: ((FeedParser) -> Void)? = nil) {
        if let parser = XMLParser(contentsOf: url) {
            parser.delegate = self
            DispatchQueue.global(qos: .background).async {
                self.success = parser.parse()
                self.complete = true
                if let handler = handler {
                    DispatchQueue.main.async {
                        handler(self)
                    }
                }
            }
        }
    }
}
