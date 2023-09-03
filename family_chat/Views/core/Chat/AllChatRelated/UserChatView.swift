//
//  UserChats.swift
//  family_chat
//
//  Created by Joel Tesfaye on 26/08/2023.
//
import SwiftUI

struct UserChatView: View {
    @StateObject var userChatViewModel = UserChatsViewModel()
    @EnvironmentObject var fetchAndUpdate: FetchAndUpdate
    
    @Binding var selectedUser: DBuser?
    var fromFamily: Bool
    @State var message: String = ""
    var chatter: DBuser
    var _width = UIScreen.main.bounds.width
    var _height = UIScreen.main.bounds.height
    @State var shiftHeight: CGFloat = 0
    var body: some View {
        ZStack {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(userChatViewModel.contents, id: \.self) { chat in
                        if chat.sender == fetchAndUpdate.user!.userId {
                            HStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 1){
                                        Text("\(chat.message)").font(.title2)
                                            .foregroundColor(.black.opacity(0.6))
                                    }
                                    .padding(5)
                                    .padding(.vertical, 3)
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
                                        Text("\(chat.message)").font(.title2)
                                    }
                                    .padding(5)
                                    .padding(.vertical, 3)
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
                .flippedUpsideDown()
                .frame(width: UIScreen.main.bounds.width)
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
                                .frame(width: 37, height: 37)
                                .overlay(
                                    Image(systemName: "arrow.up").font(.caption)
                                        .foregroundColor(.black.opacity(0.6))
                                )
                                .onTapGesture {
                                    guard let user = fetchAndUpdate.user else {
                                        print("error from onTapGesture send message")
                                        return
                                    }
                                    let chat = DBUsersChat(sender: user.userId, reciever: chatter.userId, message: message, time: Date())
                                    let temp = [chat] + userChatViewModel.contents
                                    withAnimation {
                                        userChatViewModel.contents = temp
                                    }
                                    message = ""
                                    userChatViewModel.sendContent(chat: chat)
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
            .navigationBarTitle("\(chatter.firstName) \(chatter.lastName!)")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            self.shiftHeight = KeyboardNotification().noti(viewHeight: 0)
        }
        .padding(4)
        .task {
            if let user = fetchAndUpdate.user {
                userChatViewModel.getContents(userId: user.userId, user2Id: chatter.userId)
            }
            
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if fromFamily {
                        fetchAndUpdate.getUserChats()
                    }
                    selectedUser = nil
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("chats")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                UserProfilePic(user: chatter, size: 50)
            }

        })
        
    }
}

struct UserChats_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserChatView(selectedUser: .constant(nil), fromFamily: false, chatter: DBuser(userId: "", firstName: "timmy", lastName: "dick", bio: "", email: "", PhotoURL: "", dateCreated: Date(), isPremium: false, profileImagePath: "", profileImagePathUrl: "", families: []))
                .environmentObject(FetchAndUpdate())
        }
        .previewInterfaceOrientation(.portrait)
        .preferredColorScheme(.light)
        
        
        
    }
}
