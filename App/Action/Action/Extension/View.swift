//
//  View.swift
//  Action
//
//  Created by Lakr Aream on 2022/7/25.
//

import SwiftUI

extension View {
    func usePreferredContentSize() -> some View {
        frame(
            minWidth: 400, idealWidth: 500, maxWidth: .infinity,
            minHeight: 300, idealHeight: 350, maxHeight: .infinity,
            alignment: .center
        )
    }
}
