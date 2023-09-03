//
//  TestView.swift
//  family_chat
//
//  Created by Joel Tesfaye on 23/08/2023.
//

import SwiftUI
final class TestViewModel: ObservableObject {
    func noti(viewHeight: CGFloat) -> CGFloat {
        var _height: CGFloat = 0
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            let value2 = viewHeight - value.height
            _height = value2 > 0 ? 0: value2
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
            _height = 0
        }
        return _height
    }
    
}

struct TestView: View {
    @State var text = ""
    @State var text1 = ""
    @State var red: Bool = false
    @State var _height: CGFloat = 0
    @State var viewHeight: CGFloat = 0
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    ForEach(0..<15) {text in
                        TextField("hello", text: $text1)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .background(red ?.red: .green)
                            .onTapGesture {
                                red.toggle()
    //                                let val1 = geomery.frame(in: .global)
    //                                viewHeight = UIScreen.main.bounds.height - val1.origin.y - 60
    //                                text1 += "\(viewHeight)"
                            }
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
                .background(Color.secondary.opacity(0.2))
                Spacer()
                TextField("hello", text: $text1)
                    .background(red ?.red: .green)
                    .onTapGesture {
//                        red.toggle()
//                        viewHeight = 0
//                        text1 += "\(viewHeight)"
                    }

            }
            .navigationBarTitle("Test")
            .navigationBarTitleDisplayMode(.inline)
        }
        .offset(y: -_height)
        .animation(.spring(), value: _height)
//        .onAppear {
//        _height = KeyboardNotification().noti(viewHeight: viewHeight)
//        }
        .padding()
        
    }
    
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestView()
        }
  
       
    }
}
