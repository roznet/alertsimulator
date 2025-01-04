//  MIT License
//
//  Created on 04/01/2025 for alertsimulator
//
//  Copyright (c) 2025 Brice Rosenzweig
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//



import Foundation
import SwiftUI

extension Button {
    func standardButton() -> some View {
        return self.buttonStyle(.bordered)
    }
}
struct RoundedCornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
extension Text {
    func casAnnuciation(category : CASMessage.Category) -> some View {
        switch category {
        case .emergency:
            return AnyView(Text("Warning")
                .padding()
                .bold()
                .background(RoundedCornerShape(corners: [.topLeft, .topRight], radius: 10).fill(.red))
                .foregroundColor(.white)
            )
        case .abnormal:
            return AnyView(Text("Caution")
                .padding()
                .bold()
                .background(RoundedCornerShape(corners: [.topLeft, .topRight], radius: 10).fill(.yellow))
                .foregroundColor(.black)
            )
        case .normal:
            return AnyView(Text("Alerts")
                .padding()
                .bold()
                .background(RoundedCornerShape(corners: [.topLeft, .topRight], radius: 10).fill(.black))
                .overlay( RoundedCornerShape(corners: [.topLeft, .topRight], radius: 10).stroke(Color.white, lineWidth: 1))
                .foregroundColor(.white)
            )
        }
    }
    
    func casMessage(category : CASMessage.Category) -> some View {
        switch category {
        case .emergency:
            self.padding()
                .bold()
                .background(.black)
                .foregroundColor(.red)
        case .abnormal:
            self.padding()
                .bold()
                .background(.black)
                .foregroundColor(.yellow)
        case .normal:
            self.padding()
                .bold()
                .background(.black)
                .foregroundColor(.white)
        }
    }
    func casSubMessage(category : CASMessage.Category) -> some View {
        self.padding()
            .background(.black)
            .foregroundColor(.white)
    }
}

