//
//  URL.swift
//  OTPHub
//
//  Created by Дмитрий Лисин on 28.01.2021.
//

import Foundation

extension URL {
    subscript(queryParam: String) -> String {
        guard let url = URLComponents(string: absoluteString) else { return "" }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value ?? ""
    }
}
