//
//  Result.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/16.
//

import Foundation

public extension Result where Success == Void {
    static var success: Result { .success(()) }
}
