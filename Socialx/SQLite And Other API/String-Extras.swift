//
//  String-Extras.swift
//  socialx
//
//  Created by Muhammad Riaz on 12/6/14.
//  Copyright (c) 2014 Muhammad Riaz. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import AppKit
#endif

extension String {
    func positionOf(sub:String)->Int {
        var pos = -1
        if let range = range(of:sub) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
    func subString(start:Int, length:Int = -1)->String {
        var len = length
        if len == -1 {
            len = self.count - start
        }
        let st = self.index(startIndex, offsetBy:start)
        let en = self.index(st, offsetBy:len)
        let range = st ..< en
        return substring(with:range)
    }
    
    func urlEncoded()->String {
        let res:NSString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, self as NSString, nil,
                                                                   "!*'();:@&=+$,/?%#[]" as CFString?, CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue))
        return res as String
    }
    
    func urlDecoded()->String {
        let res:NSString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, self as NSString, "" as CFString?, CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue))
        return res as String
    }
    
    //    func range()->Range<String.Index> {
    //        return Range<String.Index>(startIndex ..< endIndex)
    //    }
    
    //MARK: For SQLiteDB to work properly. I have added following code extra for string extension.
    var lastPathComponent: String {
        
        get {
            return (self as NSString).lastPathComponent
        }
    }
    var pathExtension: String {
        
        get {
            
            return (self as NSString).pathExtension
        }
    }
    var stringByDeletingLastPathComponent: String {
        
        get {
            
            return (self as NSString).deletingLastPathComponent
        }
    }
    var stringByDeletingPathExtension: String {
        
        get {
            
            return (self as NSString).deletingPathExtension
        }
    }
    var pathComponents: [String] {
        
        get {
            
            return (self as NSString).pathComponents
        }
    }
    
    func stringByAppendingPathComponent(_ path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.appendingPathComponent(path)
    }
    
    func stringByAppendingPathExtension(_ ext: String) -> String? {
        
        let nsSt = self as NSString
        
        return nsSt.appendingPathExtension(ext)
    }
    
    mutating func addString(_ str: String) {
        self = self + str
    }
}

