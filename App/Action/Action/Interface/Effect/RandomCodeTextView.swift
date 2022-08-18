//
//  RandomCodeTextView.swift
//  Action
//
//  Created by Lakr Aream on 2022/8/16.
//

import SwiftUI

struct RandomCodeTextView: View {
    @State var code = "Made with love by @Lakr233 "

    let timer = Timer
        .publish(every: 0.1, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        Text(code)
            .font(.system(.footnote, design: .monospaced))
            .lineLimit(1)
            .onReceive(timer) { _ in
                if code.count > 50 { code = "" }
                for _ in 0 ... Int.random(in: 1 ... 3) {
                    if let c = "`1234567890-=qwertyuiop[]asdfghjkl;'\\zxcvbnm,./".randomElement() {
                        code += String(c)
                    }
                }
            }
    }
}
