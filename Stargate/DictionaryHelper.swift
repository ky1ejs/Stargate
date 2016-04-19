//
//  DictionaryHelper.swift
//  Stargate
//
//  Created by Kyle McAlpine on 19/04/2016.
//
//

import Foundation

func + <KeyType, ValueType> (left: [KeyType : ValueType], right: [KeyType : ValueType]) -> [KeyType : ValueType] {
    var mutableLeft = left
    for (k, v) in right {
        mutableLeft.updateValue(v, forKey: k)
    }
    return mutableLeft
}

