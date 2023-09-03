//
//  Families.swift
//  family_chat
//
//  Created by Joel Tesfaye on 26/07/2023.
//

import SwiftUI

struct FamiliesVeiw: View {
    @EnvironmentObject var fetchAndUpdate: FetchAndUpdate
    
    @State var searchedUser: DBuser?
    @State var searchUser: String = ""
    @State var selectedFamily: DBFamily?
    @State var showCreateFamily: Bool = false
    @State var showSearch: Bool = false
    @State var showSearchResult: Bool = false
    @State var showChatView2: Bool = false
    
    
    @Binding var selectedTag: ChooseTag
    var _width = UIScreen.main.bounds.width
    var _height = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Spacer()
                    Text("Families").font(.headline).bold()
                }
                .frame(width: _width, height: _height * 0.08)
                .background(Color("tabView"))
                VStack {}.frame(height: 1)
                Button {
                    showCreateFamily.toggle()
                } label: {
                    Text("Create new Family").font(.title2).bold()
                        .foregroundColor(.white)
                        .frame(width: _width - _width/9, height: 60)
                        .background(Color.shared.accentColor)
                        .cornerRadius(10)
                }
                VStack {
                    Text("families").foregroundColor(Color.shared.mainTextColor.opacity(0.4))
                    ScrollView(showsIndicators: false) {
                        if fetchAndUpdate.userFamilies.count > 0{
                            VStack(spacing: 3) {
                                ForEach(fetchAndUpdate.userFamilies, id: \.self) { family in
                                    NavigationLink(tag: family, selection: $selectedFamily) {
                                        NavigationView {
                                            ChatView2(family: family, selectedFamily: $selectedFamily)
                                        }
                                        .navigationBarHidden(true)
                                    } label: {
                                        HStack {
                                            FamilyProfilePic(family: family, size: 65)
                                            VStack(alignment: .leading) {
                                                Text("\(family.familyName)").font(.title3)
                                                    .foregroundColor(Color.shared.mainTextColor).bold()
                                                Text("\(family.motto ?? "")")
                                                    .foregroundColor(Color.shared.mainTextColor)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(5)
                                        .frame(width: _width, height: 70)
                                        .background(Color.shared.chatBackground)
                                        
                                    }
                                }
                                Spacer()
                            }
                            
                        } else {
                            VStack {}.frame(width: _width, height: 70)
                        }
                        
                    }
                }
                .padding(3)
                .frame(width: _width, height: _height * 0.8)
                .background(Color.secondary.opacity(0.2))
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .fullScreenCover(isPresented: $showCreateFamily) {
                NavigationView {
                    CreateFamilyView(showCreateFamily: $showCreateFamily)
                }
            }
            
        }
        .ignoresSafeArea(edges: .top)
    }
}

struct FamilyProfilePic: View {
    var family: DBFamily
    var size: CGFloat
    var body: some View {
        if family.profilePhotoPathUrl != nil, let url = URL(string: family.profilePhotoPathUrl!) {
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
                        Text("\("\(family.familyName.first!)" + "\(family.familyName.last!)")").font(.largeTitle).bold()
                            .foregroundColor(.white)
                    }
            }
        } else {
            Image(systemName: "circle.fill")
                .resizable()
                .foregroundColor(.gray)
                .frame(width: size, height: size)
                .overlay {
                    Text("\("\(family.familyName.first!)" + "\(family.familyName.last!)")").font(.largeTitle).bold()
                        .foregroundColor(.white)
                }
        }
    }
}

struct Families_Previews: PreviewProvider {
    static var previews: some View {
        FamiliesVeiw(selectedTag: .constant(ChooseTag.chat))
            .environmentObject(FetchAndUpdate())
    }
}
