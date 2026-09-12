//
//  phpReplicas.swift
//  DevEnvironment
//
//  Created by Raghul S on 28/02/25.
//

import Foundation

public func str_replace(_ search: String, _ replace: String, in originalString: String) -> String {
    return originalString.replacingOccurrences(of: search, with: replace)
}
