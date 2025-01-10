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



import SwiftUI
import RZUtilsSwift

class CASViewModel : ObservableObject {
    typealias CCategory = CASMessage.Category
    @Published var category: CCategory
    @Published var message: String
    @Published var submessage: String
    
    init(casMessage: CASMessage) {
        self.message = casMessage.message
        self.submessage = casMessage.submessage
        self.category = casMessage.category
    }
}
struct CASView: View {
    @Binding var casMessage: CASMessage
    
    var body: some View {
        VStack {
            if !$casMessage.wrappedValue.message.isEmpty {
                Text($casMessage.wrappedValue.message)
                    .casMessage(category: $casMessage.wrappedValue.category)
                    .frame(maxWidth: .infinity,alignment: .trailing)
                    .padding([.bottom,.top])

            }
            Spacer()
            HStack {
                Spacer()
                VStack() {
                    Text("Alerts")
                        .foregroundColor(.white)
                    Divider()
                        .background(Color.white)
                        .padding([.bottom])
                    if !$casMessage.wrappedValue.submessage.isEmpty {
                        Text($casMessage.wrappedValue.detailedMessage)
                            .casSubMessage(category: $casMessage.wrappedValue.category)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity,alignment: .leading)
                    }else {
                        Text($casMessage.wrappedValue.submessage)
                            .casSubMessage(category: $casMessage.wrappedValue.category)
                            .frame(maxWidth: .infinity,alignment: .leading)
                        
                    }
                }
                .background(.black)
                .frame(maxWidth:600, alignment: .trailing)
                .cornerRadius(10)
                .overlay( RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 1))
                .padding([.leading,.top,.bottom])
            }
            
            Text($casMessage.wrappedValue.categoryDescription)
                .casAnnuciation(category: $casMessage.wrappedValue.category)
                .frame(maxWidth: .infinity,alignment: .trailing)
            .background(Color.black)
        }
        .background(Color.brown)
    }
}


#Preview {
    @Previewable @State var casMessage1: CASMessage = SampleLoader.sampleCAS(category: .abnormal).first!
    @Previewable @State var casMessage2: CASMessage = SampleLoader.sampleCAS(category: .emergency).first!
    @Previewable @State var casMessage3: CASMessage = CASMessage()
    @Previewable @State var casMessage4: CASMessage = SampleLoader.sampleCAS(category: .abnormal, type:.situation).first!
    
    CASView(casMessage: $casMessage1)
        .padding(.bottom)
    CASView(casMessage: $casMessage2)
        .padding(.bottom)
    CASView(casMessage: $casMessage3)
        .padding(.bottom)
    CASView(casMessage: $casMessage4)
        .padding(.bottom)
}
