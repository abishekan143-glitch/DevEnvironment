//
//  cppReplicas.swift
//  DevEnvironment
//
//  Created by Raghul S on 02/03/25.
//

import Foundation

public extension String{
    subscript(i:Int) -> Character{
        return self[index(startIndex, offsetBy: i)]
    }
}
