//
// ARMode.swift
// Created by Brandon Williams
//

import Foundation

// MARK: - AR Mode
// This enum defines the different navigation modes the user can choose.
//
// Enums (short for "enumerations") let us define a type with a fixed number of options.
// Here, the user can switch the app between map, split-screen, or full AR view.
enum ARMode {
    
    /// Full map view only
    case map
    
    /// Split-screen: half map, half AR view
    case split
    
    /// Full AR view
    case ar
}
