//
//  KMLSimpleField.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/28/21.
//

import Foundation
import XMLDocument

open class KMLSimpleField: NSObject {
    
    public enum KMLSimpleFieldType: String {
        case string
        case int
        case uint
        case short
        case ushort
        case float
        case double
        case bool
    }
    
    /**
     Type of field
     
     The type can be one of the following:
     - string
     - int
     - uint
     - short
     - ushort
     - float
     - double
     - bool
     */
    open var type: KMLSimpleFieldType
    open var name: String
    open var uom: URL?
    /** The name, if any, to be used when the field name is displayed to the Google Earth user. Use the [CDATA] element to escape standard HTML markup. */
    @objc open var displayName: String?
    
    public init(name: String, type: KMLSimpleFieldType) {
        self.name = name
        self.type = type
        super.init()
    }
    
    internal init(_ attributes: [String:String]) {
        self.type = attributes["type"].flatMap { KMLSimpleFieldType(rawValue: $0) } ?? .string
        self.name = attributes["name"] ?? ""
        if let uom = attributes["uom"] {
            self.uom = URL(string: uom)
        }
    }
}

extension KMLSimpleField: KMLWriterNode {
    static let elementName = "SimpleField"
    
    func toElement(in doc: XMLDocument) -> XMLElement {
        let element = XMLElement(name: Swift.type(of: self).elementName)
        
        element.addAttribute(XMLNode.attribute(withName: "type", stringValue: self.type.rawValue) as! XMLNode)
        element.addAttribute(XMLNode.attribute(withName: "name", stringValue: self.name) as! XMLNode)
        
        if let uom = self.uom {
            let attr = XMLNode.attribute(withName: "uom", stringValue: uom.description) as! XMLNode
            element.addAttribute(attr)
        }
        
        addSimpleChild(to: element, withName: "displayName", value: displayName)        
        return element
    }
}


open class KMLSimpleArrayField: KMLSimpleField {
    
}
