//
//  md5.swift
//  LoginScreenApp
//
//  Created by user on 2018/8/11.
//  Copyright © 2018年 kaleidosstudio. All rights reserved.
//

import Foundation
// MARK: MD5


extension String {
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        
        return String(format: hash as String)
    }
    func IsDigit()->Bool{
        
        if self.characters.last == "x"{
            
            return false
            
        }
        
        var result = ""
        // - 1、创建规则
        let pattern1 = "(^[0-9]*$)"

        // - 2、创建正则表达式对象
        let regex1 = try! NSRegularExpression(pattern: pattern1, options: NSRegularExpression.Options.caseInsensitive)
        // - 3、开始匹配
        let res = regex1.matches(in: self, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, self.characters.count))
        // 输出结果
        for checkingRes in res {
            result = result + (self as NSString).substring(with: checkingRes.range)
        }
        if result == self{
            return true
        }else{
            return false
        }
        
    }
    
    
}

extension String {
    subscript(value: NSRange) -> Substring {
        return self[value.lowerBound..<value.upperBound]
    }
}

extension String {
    subscript(value: CountableClosedRange<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)...index(at: value.upperBound)]
        }
    }
    
    subscript(value: CountableRange<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)..<index(at: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(at: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(at: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)...]
        }
    }
    
    func index(at offset: Int) -> String.Index {
        return index(startIndex, offsetBy: offset)
    }
}
