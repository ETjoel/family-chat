//
//  HomeView.swift
//  family_chat
//
//  Created by Joel Tesfaye on 26/07/2023.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var fetchAndUpdate: FetchAndUpdate
    @State private var showProfile: Bool = false
    @State var showChatView2: Bool = false
    @State var selectedUser: DBuser?
    @State var profileImgae: UIImage = UIImage(named: "fam")!
    @State var message: String = ""
    var _width = UIScreen.main.bounds.width
    var _height = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Spacer()
                    Text("Chats").font(.headline).bold()
                }
                .frame(width: _width, height: _height * 0.08)
                .background(Color("tabView"))
                    
                VStack {}.frame(height: 1)
                VStack {
                    ScrollView(.vertical, showsIndicators: false, content: {
                        VStack(spacing: 1) {
                            ForEach(fetchAndUpdate.userChats, id: \.self, content: { (user: DBuser) in
                                NavigationLink(tag: user, selection: $selectedUser){
                                    NavigationView {
                                        UserChatView(selectedUser: $selectedUser, fromFamily: false, chatter: user)
                                            
                                    }
                                    .navigationBarHidden(true)
                                } label: {
                                    HStack {
                                        UserProfilePic(user: user, size: 65)
                                        VStack(alignment: .leading) {
                                            Text("\(user.firstName) \(user.lastName!)").font(.title2).bold()
                                            Text("\(user.bio!)")
                                        }
                                        .foregroundColor(Color.shared.mainTextColor)
                                        
                                        Spacer()
                                    }
                                    .padding(5)
                                    .frame(width: _width, height: 70)
                                    .background(Color.shared.chatBackground)
                                }
                            })
                            Spacer()
                        }
                    })
                    .frame(width: _width, height: _height * 0.77)
                }
                .frame(width: _width, height: _height * 0.9)
                .background(Color.secondary.opacity(0.2))
            }
        }
        .ignoresSafeArea(edges: .top)
        .fullScreenCover(isPresented: $showProfile) {
            NavigationView {
                ProfileView(showProfile: $showProfile)
            }
        }
    }
}

struct UserProfilePic: View {
    var user: DBuser
    var size: CGFloat
    var body: some View {
        if user.profileImagePathUrl != nil, let url = URL(string: user.profileImagePathUrl!) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .cornerRadius(size / 2)
            } placeholder: {
                Image(systemName: "circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: size, height: size)
                    .overlay {
                        Text("\("\(user.firstName.first!)" + "\(user.firstName.last!)")").font(.largeTitle).bold()
                            .foregroundColor(.white)
                    }
            }
        } else {
            Image(systemName: "circle.fill")
                .resizable()
                .foregroundColor(.gray)
                .frame(width: size, height: size)
                .overlay {
                    Text("\("\(user.firstName.first!)" + "\(user.firstName.last!)")").font(.largeTitle).bold()
                        .foregroundColor(.white)
                }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView().environmentObject(FetchAndUpdate())
        .preferredColorScheme(.light)
    }
}
