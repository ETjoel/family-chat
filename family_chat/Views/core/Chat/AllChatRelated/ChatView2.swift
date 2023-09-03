//
//  ChatView2.swift
//  family_chat
//
//  Created by Joel Tesfaye on 22/08/2023.
//

import SwiftUI

struct ChatView2: View {
    @StateObject var chatView2Model = ChatView2Model()
    @EnvironmentObject var fetchAndUpdate: FetchAndUpdate
    
    
    @State var message: String = ""
    @State var showFamilyProfile: Bool = false
    var family: DBFamily
    @Binding var selectedFamily: DBFamily?
    var _width = UIScreen.main.bounds.width
    var _height = UIScreen.main.bounds.width
    @State var shiftHeight: CGFloat = 0
    var body: some View {
        ZStack {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 7) {
                        ForEach(chatView2Model.contents.reversed(), id: \.self) { chat in
                                if chat.sender == fetchAndUpdate.user!.userId {
                                    HStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 1){
                                                Text("\(chat.message)").font(.headline)
                                                Text("you")
                                                    .font(.caption)
                                            }
                                            .padding(5)
                                            .foregroundColor(Color.black.opacity(0.6))
                                            .background(LinearGradient(colors: [Color("whiteGreen"), Color.green], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .cornerRadius(8)
                                        }
                                        .frame(maxWidth: _width - _width / 6)
                                        
                                    }
                                    .padding(.horizontal, 5)
                                    .flippedUpsideDown()

                                } else {
                                    HStack {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 1){
                                                Text("\(chat.message)").font(.headline)
                                                Text("\(chatView2Model.users[chat.sender]?.firstName ?? "")")
                                                    .font(.caption)
                                            }
                                            .padding(5)
                                            .foregroundColor(Color.shared.mainTextColor)
                                            .background(Color.shared.chatBackground)
                                            .cornerRadius(8)
                                            Spacer()
                                        }
                                        .frame(maxWidth: _width - _width / 6)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 5)
                                    .flippedUpsideDown()
                                }
                            }
                    }
                }
                .flippedUpsideDown()
                .frame(width: _width)
                .background(Color.secondary.opacity(0.2))
                VStack {
                    HStack {
                        HStack {
                            TextField("send message", text: $message)
                                .padding(.horizontal)
                                .font(.headline).foregroundColor(Color.shared.mainTextColor)
                                .autocapitalization(.none)
                                .frame(height: _height * 0.05)
                                .background(Color("c_blue").opacity(0.01))
                                .cornerRadius(15)
                            Image(systemName: "paperclip")
                                .font(.title2).foregroundColor(.white.opacity(0.7))
                        }
                        .background(Color("c_blue").opacity(0.2))
                        .cornerRadius(10)
                        
                        if message.count > 0 {
                            Circle().fill(LinearGradient(colors: [Color("whiteGreen"), Color.green], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 35, height: 35)
                                .overlay(
                                    Image(systemName: "arrow.up").font(.caption)
                                        .foregroundColor(Color.black.opacity(0.6))
                                )
                                .onTapGesture {
                                    guard let user = fetchAndUpdate.user else {
                                        print("error from onTapGesture send message")
                                        return
                                    }
                                    let chat = DBFamilyChat(sender: user.userId, message: message, time: Date())
                                    withAnimation {
                                        chatView2Model.appendContent(chat: chat)
                                    }
                                    message = ""
                                    chatView2Model.sendContent(familyName: family.familyName, chat: chat)
                                    //chatView2Model.getContents(familyName: family.familyName)
                                }
                        } else {
                            Text("").padding(.horizontal, 21)
                        }
                    }
                    .padding(10)
                }
                .frame(width: UIScreen.main.bounds.width)
            }
            .offset(y: -shiftHeight)
            .animation(.spring(), value: shiftHeight)
            .navigationBarTitle("\(family.familyName)")
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .onAppear {
            self.shiftHeight = KeyboardNotification().noti(viewHeight: 0)
        }
        .padding()
        .task {
            chatView2Model.getContents(familyName: family.familyName)
            chatView2Model.getMembers(members: family.members!)
        }
        .fullScreenCover(isPresented: $showFamilyProfile, content: {
            NavigationView {
                FamilyProfileView(family: family, showFamilyProfile: $showFamilyProfile)
            }
            
        })
        .environmentObject(chatView2Model)
  
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                FamilyProfilePic(family: family, size: 50)
                    .onTapGesture {
                        showFamilyProfile = true
                    }
                                    
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button{
                    selectedFamily = nil
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("families")
                    }
                }
            }
        })
        
        
    }
}
struct FlippedUpsideDown: ViewModifier {
   func body(content: Content) -> some View {
    content
           .rotationEffect(Angle(radians: 22/7))
      .scaleEffect(x: -1, y: 1, anchor: .center)
   }
}
extension View{
   func flippedUpsideDown() -> some View{
     self.modifier(FlippedUpsideDown())
   }
}



struct ChatView2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView2(family: DBFamily(familyId: "70056E15-A7D4-49A9-B311-0BBAB0C6D4A9", familyName: "Sanji's Family", owner: "70056E15-A7D4-49A9-B311-0BBAB0C6D4A9", motto: "I love my wife", profilePhotoPath: "", profilePhotoPathUrl: "", members: []), selectedFamily: .constant(DBFamily(familyId: "70056E15-A7D4-49A9-B311-0BBAB0C6D4A9", familyName: "Sanji's Family", owner: "70056E15-A7D4-49A9-B311-0BBAB0C6D4A9", motto: "I love my wife", profilePhotoPath: "", profilePhotoPathUrl: "", members: [])))
                .environmentObject(FetchAndUpdate())
                .environmentObject(ChatView2Model())
        }
        .preferredColorScheme(.light)
       
       
    }
}
