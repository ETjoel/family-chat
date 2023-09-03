//
//  Colors.swift
//  family_chat
//
//  Created by Joel Tesfaye on 30/08/2023.
//

import Foundation
import SwiftUI

extension Color {
    static let shared = ColorTheme()
}

struct ColorTheme {
    let accentColor = Color("accentColor-1")
    let secondaryColor = Color("secondaryColor")
    let tertiaryColor = Color("tertiaryColor")
    let quaternaryColor = Color("quaternaryColor")
    let mainTextColor = Color("mainTextColor")
    let chatBackground = Color("chatBackground")
    let _red = Color.red
    let _green = Color.green
    
}
