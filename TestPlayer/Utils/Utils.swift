//
//  Player+Utils.swift
//  Client
//
//  Created by Shannon Wu on 12/24/15.
//  Copyright © 2015 36Kr. All rights reserved.
//

import UIKit

extension CGFloat {
    var valueBetweenZeroAndOne: CGFloat {
        return abs(self) > 1 ? 1 : abs(self)
    }
}

extension String {
    var URL: NSURL? {
        func escape(string: String) -> String {
            let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
            let subDelimitersToEncode = "!$&'()*+,;="
            
            let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
            allowedCharacterSet.removeCharactersInString(generalDelimitersToEncode + subDelimitersToEncode)
            
            var escaped = ""
            escaped = string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? string
            
            return escaped
        }
        
        let urlComponents = NSURLComponents(string: self)
        if let query = urlComponents?.query {
            urlComponents?.query = escape(query)
        }
        
        return urlComponents?.URL
    }
}

extension CGRect {
    
    /// 返回 Rect 的 Center 位置
    var center: CGPoint {
        get {
            return CGPoint(x: size.width / 2, y: size.height / 2)
        }
        set {
            self.origin = CGPoint(x: newValue.x - size.width / 2, y: newValue.y - size.height / 2)
        }
    }
    
    var bottom: CGFloat {
        return self.origin.y + self.size.height
    }
    
    var x: CGFloat {
        return self.origin.x
    }
    
    var y: CGFloat {
        return self.origin.y
    }
    
    var width: CGFloat {
        return self.size.width
    }
    
    var height: CGFloat {
        return self.size.height
    }
    
}
