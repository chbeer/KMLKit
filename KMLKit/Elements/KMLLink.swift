//
//  Link.swift
//  KMLKit
//
//  Created by Weston Bustraan on 2/25/21.
//

import Foundation
import CoreGraphics
import XMLDocument

@objc public protocol KMLAbstractLink: class {
    var href: URL? { get set }
}

open class KMLBasicLink: KMLObject, KMLAbstractLink {
    @objc open var href: URL?
    
    public override init() {
        super.init()
    }

    public init(href: String) {
        super.init()
        self.href = URL(string: href)
    }
    
    public init(href: URL) {
        super.init()
        self.href = href
    }


    internal override init(_ attributes: [String : String]) {
        super.init(attributes)
    }

    // MARK: - XMLWriterNode

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "href", value: href?.description)
    }

}

/**
 &lt;Link&gt; specifies the location of any of the following:

 - KML files fetched by network links
 - Image files used in any Overlay (the &lt;Icon&gt; element specifies the image in an Overlay; &lt;Icon&gt; has the same fields as &lt;Link&gt;)
 - Model files used in the &lt;Model&gt; element
 
 The file is conditionally loaded and refreshed, depending on the refresh parameters supplied here. Two different sets of refresh parameters can be specified: one set is based on time (&lt;refreshMode&gt; and &lt;refreshInterval&gt;) and one is based on the current "camera" view (&lt;viewRefreshMode&gt; and &lt;viewRefreshTime&gt;). In addition, Link specifies whether to scale the bounding box parameters that are sent to the server (&lt;viewBoundScale&gt; and provides a set of optional viewing parameters that can be sent to the server (&lt;viewFormat&gt;) as well as a set of optional parameters containing version and language information.

 When a file is fetched, the URL that is sent to the server is composed of three pieces of information:

 - the href (Hypertext Reference) that specifies the file to load.
 - an arbitrary format string that is created from (a) parameters that you specify in the &lt;viewFormat&gt; element or (b) bounding box parameters (this is the default and is used if no &lt;viewFormat&gt; element is included in the file).
 - a second format string that is specified in the &lt;httpQuery&gt; element.
 
 If the file specified in &lt;href&gt; is a local file, the &lt;viewFormat&gt; and &lt;httpQuery&gt; elements are not used.

 The &lt;Link&gt; element replaces the &lt;Url&gt; element of &lt;NetworkLink&gt; contained in earlier KML releases and adds functionality for the &lt;Region&gt; element (introduced in KML 2.1). In Google Earth releases 3.0 and earlier, the &lt;Link&gt; element is ignored.
 */
open class KMLLink: KMLBasicLink {

    /** Specifies a time-based refresh mode */
    @objc open var refreshMode = KMLRefreshMode.onChange
    /** Indicates to refresh the file every n seconds. */
    @objc open var refreshInterval: Double = 4.0
    /** Specifies how the link is refreshed when the "camera" changes. */
    @objc open var viewRefreshMode = KMLViewRefreshMode.never
    /** After camera movement stops, specifies the number of seconds to wait before refreshing the view. (See *viewRefreshMode* and onStop above.) */
    @objc open var viewRefreshTime: Double = 4.0
    /** Scales the BBOX parameters before sending them to the server. A value less than 1 specifies to use less than the full view (screen). A value greater than 1 specifies to fetch an area that extends beyond the edges of the current view. */
    @objc open var viewBoundScale: Double = 1.0
    /**
     Specifies the format of the query string that is appended to the Link's &lt;href&gt; before the file is fetched.(If the &lt;href&gt; specifies a local file, this element is ignored.)
     
     If you specify a &lt;viewRefreshMode&gt; of onStop and do not include the &lt;viewFormat&gt; tag in the file, the following information is automatically appended to the query string:
     
     ```
     BBOX=[bboxWest],[bboxSouth],[bboxEast],[bboxNorth]
     ```
     
     This information matches the Web Map Service (WMS) bounding box specification.
     
     If you specify an empty &lt;viewFormat&gt; tag, no information is appended to the query string.
     
     You can also specify a custom set of viewing parameters to add to the query string. If you supply a format string, it is used instead of the BBOX information. If you also want the BBOX information, you need to add those parameters along with the custom parameters.
     
     You can use any of the following parameters in your format string (and Google Earth will substitute the appropriate current value at the time it creates the query string):
     
     - **[lookatLon]**, **[lookatLat]** - longitude and latitude of the point that &lt;LookAt&gt; is viewing
     - **[lookatRange]**, **[lookatTilt]**, **[lookatHeading]** - values used by the &lt;LookAt&gt; element (see descriptions of &lt;range&gt;, &lt;tilt&gt;, and &lt;heading&gt; in &lt;LookAt&gt;)
     - **[lookatTerrainLon]**, **[lookatTerrainLat]**, **[lookatTerrainAlt]** - point on the terrain in degrees/meters that &lt;LookAt&gt; is viewing
     - **[cameraLon]**, **[cameraLat]**, **[cameraAlt]** - degrees/meters of the eyepoint for the camera
     - **[horizFov]**, **[vertFov]** - horizontal, vertical field of view for the camera
     - **[horizPixels]**, **[vertPixels]** - size in pixels of the 3D viewer
     - **[terrainEnabled]** - indicates whether the 3D viewer is showing terrain*/
    @objc open var viewFormat: String?
    /**
     Appends information to the query string, based on the parameters specified.
     
     (Google Earth substitutes the appropriate current value at the time it creates the query string.) The following parameters are supported:
     - [clientVersion]
     - [kmlVersion]
     - [clientName]
     - [language]
     */
    @objc open var httpQuery: String?
    
    
    @objc public enum KMLRefreshMode: Int, CustomStringConvertible {
        /** refresh when the file is loaded and whenever the Link parameters change (the default). */
        case onChange
        /** refresh every n seconds (specified in &lt;refreshInterval&gt;). */
        case onInterval
        /** refresh the file when the expiration time is reached. If a fetched file has a NetworkLinkControl, the &lt;expires&gt; time takes precedence over expiration times specified in HTTP headers. If no &lt;expires&gt; time is specified, the HTTP max-age header is used (if present). If max-age is not present, the Expires HTTP header is used (if present). (See Section RFC261b of the Hypertext Transfer Protocol - HTTP 1.1 for details on HTTP header fields.) */
        case onExpire
        
        init(_ value: String) {
            switch value {
            case "onChange":
                self = .onChange
            case "onInterval":
                self = .onInterval
            case "onExpire":
                self = .onExpire
            default:
                self = .onChange
            }
        }

        public var description: String {
            switch self {
            case .onChange:
                return "onChange"
            case .onInterval:
                return "onInterval"
            case .onExpire:
                return "onExpire"
            }
        }
    }
    
    
    @objc public enum KMLViewRefreshMode: Int, CustomStringConvertible {
        /**  Ignore changes in the view. Also ignore &lt;viewFormat&gt; parameters, if any. */
        case never
        /** Refresh the file only when the user explicitly requests it. (For example, in Google Earth, the user right-clicks and selects Refresh in the Context menu.) */
        case onRequest
        /** Refresh the file *n* seconds after movement stops, where *n* is specified in &lt;viewRefreshTime&gt;. */
        case onStop
        /** Refresh the file when the Region becomes active. */
        case onRegion
        
        init(_ value: String) {
            switch value {
            case "never":
                self = .never
            case "onRequest":
                self = .onRequest
            case "onStop":
                self = .onStop
            case "onRegion":
                self = .onRegion
            default:
                self = .never
            }
        }
        
        public var description: String {
            switch self {
            case .never:
                return "never"
            case .onRequest:
                return "onRequest"
            case .onStop:
                return "onStop"
            case .onRegion:
                return "onRegion"
            }
        }
    }
    
    
    public override init() {
        super.init()
    }
    
    public override init(href: String) {
        super.init(href: href)
    }
    
    public override init(href: URL) {
        super.init(href: href)
    }
    
    internal override init(_ attributes: [String:String]) {
        super.init(attributes)
        if let href = attributes["href"] {
            self.href = URL(string: href)
        }
    }
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "refreshMode", let refreshMode = value as? KMLRefreshMode {
            self.refreshMode = refreshMode
        } else if key == "viewRefreshMode", let viewRefreshMode = value as? KMLViewRefreshMode {
            self.viewRefreshMode = viewRefreshMode
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        addSimpleChild(to: element, withName: "refreshMode", value: refreshMode.description, default: "onChange")
        addSimpleChild(to: element, withName: "refreshInterval", value: refreshInterval, default: 4.0)
        addSimpleChild(to: element, withName: "viewRefreshMode", value: viewRefreshMode.description, default: "never")
        addSimpleChild(to: element, withName: "viewRefreshTime", value: viewRefreshTime, default: 4.0)
        addSimpleChild(to: element, withName: "viewBoundScale", value: viewBoundScale, default: 1.0)
        addSimpleChild(to: element, withName: "viewFormat", value: viewFormat)
        addSimpleChild(to: element, withName: "httpQuery", value: httpQuery)
    }
}

/**
 Defines an image associated with an Icon style or overlay. The required &lt;href&gt; child element defines the location of the image to be used as the overlay or as the icon for the placemark. This location can either be on a local file system or a remote web server.
 */
open class KMLIcon: KMLLink {

    /** The &lt;gx:x&gt;, &lt;gx:y&gt;, &lt;gx:w&gt;, and &lt;gx:h&gt; elements are used to select one icon from an image that contains multiple icons (often referred to as an icon palette. */
    @objc var frame = CGRect()
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "x", let x = value as? Double {
            frame.origin.x = CGFloat(x)
        } else if key == "y", let y = value as? Double {
            frame.origin.y = CGFloat(y)
        } else if key == "w", let w = value as? Double {
            frame.size.width = CGFloat(w)
        } else if key == "h", let h = value as? Double {
            frame.size.height = CGFloat(h)
        } else {
            super.setValue(value, forKey: key)
        }
        
    }

    override func addChildNodes(to element: XMLElement, in doc: XMLDocument) {
        super.addChildNodes(to: element, in: doc)
        if frame != CGRect() {
            addSimpleChild(to: element, withName: "gx:x", value: frame.origin.x)
            addSimpleChild(to: element, withName: "gx:y", value: frame.origin.y)
            addSimpleChild(to: element, withName: "gx:w", value: frame.size.width)
            addSimpleChild(to: element, withName: "gx:h", value: frame.size.height)
        }
    }

}
