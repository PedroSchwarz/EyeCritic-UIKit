//
//  NetworkInfo.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 21/08/21.
//

import Foundation
import Network

protocol NetworkInfo {
    func isConnected() -> Bool
}

struct NetworkInfoImpl: NetworkInfo {
    var monitor: NWPathMonitor
    
    func isConnected() -> Bool {
        return monitor.currentPath.status == .satisfied
    }
}
