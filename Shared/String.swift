//
//  String.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 21.01.2021.
//

import Foundation

extension String {
    func separated(separator: String = " ", stride: Int = 2) -> String {
        enumerated().map { $0.isMultiple(of: stride) && ($0 != 0) ? "\(separator)\($1)" : String($1) }.joined()
    }
}
