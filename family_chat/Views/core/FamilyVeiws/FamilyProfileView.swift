//
//  FamilyProfileView.swift
//  family_chat
//
//  Created by Joel Tesfaye on 27/08/2023.
//

import SwiftUI

final class FamilyProfileViewModel: ObservableObject {
    func addNewMember(family: DBFamily?, user: DBuser?) {
        guard let family = family, let user = user else {
            print("either family or user missing in addNewMember func")
            return
        }
        var currentArray = user.families
        currentArray?.append(family.familyId)
        UserManager.shared.updateUserField(userId: user.userId, field: [DBuser.CodingKeys.families.rawValue : currentArray!])
        var currentArray1 = family.members
        currentArray1?.append(user.userId)
        FamilyManager.shared.updateFamily(field: [DBFamily.CodingKeys.members.rawValue : currentArray1!], familyId: family.familyId)
        
    }
    
    func uploadImage(familyId: String, image: UIImage) async throws {
        guard let data = image.jpegData(compressionQuality: 0.2) else {
            print("........looks like you failed to upload image........")
            return
        }
        Task {
            do {
                let uploadResult = try await StorageManager.shared.uploadFamImage(data: data)
                print(".......from uploadImage FamilyProfile.... ")
                print("........path: \(uploadResult.path)")
                var field = [DBFamily.CodingKeys.profilePhotoPath.rawValue : uploadResult.path]
                FamilyManager.shared.updateFamily(field: field, familyId: familyId)
                let url = try await StorageManager.shared.downloadDataWithUrl(path: uploadResult.path)
                field = [DBFamily.CodingKeys.profilePhotoPathUrl.rawValue : url.absoluteString]
                FamilyManager.shared.updateFamily(field: field, familyId: familyId)
            } catch {
                print(".......Something happend in uploadImage funtion in FamilyProfileView...........")
                print(error)
            }
        }
    }
}

struct FamilyProfileView: View {
    @StateObject var familyProfileViewModel = FamilyProfileViewModel()
    @EnvironmentObject var fetchAndUpdate: FetchAndUpdate
    @EnvironmentObject var chatView2Model: ChatView2Model
    
    var family: DBFamily
    @Binding var showFamilyProfile: Bool
    
    @State var familyName: String = ""
    @State var motto: String = ""
    @State var selectedImage: UIImage = UIImage()
    @State var showSheet: Bool = false
    @State var searchedUser: DBuser?
    @State var searchUser: String = ""
    @State var showSearch: Bool = false
    @State var showSearchResult: Bool = false
    @State var newlyAddedUsers: [String] = []
    @State var newlyAddedUsersDBuser: [DBuser] = []
    @State var selectedUser: DBuser?
    
    var _width = UIScreen.main.bounds.width
    var body: some View {
        ZStack {
            VStack {
                if selectedImage != UIImage() {
                    Image(uiImage: selectedImage).resizable()
                        .frame(width: 120, height: 120)
                        .cornerRadius(60)
                } else  {
                    FamilyProfilePic(family: family, size: 120)
                }
                Button {
                    showSheet = true
                } label: {
                    Text("Change Profile")
                }
                
                
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            TextField("Family Name", text: $familyName)
                                .autocapitalization(.none).font(.title2)
                            Rectangle().fill(Color.shared.mainTextColor.opacity(0.3)).frame(height: 1)
                            TextField("motto", text: $motto)
                                .autocapitalization(.none).font(.title2)
                        }
                        .padding()
                        .frame(width: _width - _width/9, height: 80)
                        .foregroundColor(Color.shared.mainTextColor)
                        .background(Color.shared.chatBackground)
                        .cornerRadius(10)
                        Button {
                            withAnimation {
                                showSearch.toggle()
                            }
                        } label: {
                            Text("Add new Members").font(.title2).bold()
                                .frame(width: _width - _width/9, height: 60)
                                .foregroundColor(.white)
                                .background(Color.shared.accentColor).cornerRadius(10)
                            
                        }
                        
                        if showSearch {
                            HStack {
                                TextField("user name", text: $searchUser).font(.title2).autocapitalization(.none).disableAutocorrection(true)
                                    .foregroundColor(Color.shared.mainTextColor)
                                    .padding()
                                    .frame(width: _width - _width/2.6, height: 60)
                                    .background(Color.shared.secondaryColor)
                                    .cornerRadius(10)
                                Image(systemName: "magnifyingglass").font(.title)
                                    .foregroundColor(searchUser.count > 0 ? .green : .white)
                                    .frame(width: 40, height: 60)
                                    .onTapGesture {
                                        if searchUser.count > 0 {
                                            Task {
                                                do {
                                                    let snapshot = try await UserManager.shared.searchUserWithFirstName(firstName: searchUser)
                                                    
                                                    for documents in snapshot.documents {
                                                        searchedUser = try documents.data(as: DBuser.self)
                                                        print("............please print firstName: \(searchedUser?.firstName ?? "not this")")
                                                    }
                                                    if searchedUser != nil {
                                                        showSearchResult = true
                                                    }
                                                   
                                                } catch {
                                                    print("it looks like we have a situation in getUserWithFirstName func")
                                                }
                                            }
                                        }
                                    }
                                
                            }.padding()
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: _width - _width/3.7, height: 60)
                            .background(Color.shared.secondaryColor.opacity(0.2))
                            .cornerRadius(10)
                        }
                        if showSearchResult {
                            Text("\(searchedUser?.firstName ?? "Not Found")").font(.title2).bold()
                                .frame(width: _width/1.8, height: 58)
                                .background(.green.opacity(0.6))
                                .cornerRadius(10)
                                .onTapGesture {
                                    guard searchedUser != nil else {
                                        showSearchResult = false
                                        print("......error from show searched user")
                                        return
                                    }
                                    print("......success from show searched user.......")
                                    newlyAddedUsers.append(searchedUser!.userId)
                                    newlyAddedUsersDBuser.append(searchedUser!)
                                    searchUser = ""
                                    showSearchResult = false
                                }
                        }
                        Text("members").foregroundColor(Color.shared.mainTextColor.opacity(0.4))
                        VStack {
                            ForEach(Array(chatView2Model.users.values) + newlyAddedUsersDBuser , id: \.self) { user in
                                NavigationLink(tag: user, selection: $selectedUser){
                                    NavigationView {
                                        UserChatView(selectedUser: $selectedUser, fromFamily: true, chatter: user)
                                    }
                                    .navigationBarHidden(true)
                                } label: {
                                    HStack(spacing: 5) {
                                        UserProfilePic(user: user, size: 60)
                                        Text("\(user.firstName) \(user.lastName!) ").font(.headline)
                                            .foregroundColor(Color.shared.mainTextColor)
                                        Spacer()
                                    }
                                    .padding()
                                    .frame(width: _width - _width/9, height: 70)
                                    .background(Color.shared.chatBackground)
                                    .cornerRadius(10)
                                }

                            }
                        }
                        Spacer()
                        
                    }
                }
                .padding()
                .frame(width: _width)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(10)
            }
        }
        .onAppear(perform: {
            setValue()
        })
        .sheet(isPresented: $showSheet, content: {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
        })
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showFamilyProfile = false
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        do {
                            if familyName.count > 0 {
                                var temp = family.members ?? []
                                for userId in newlyAddedUsers {
                                    temp.append(userId)
                                    print("......frum button.......\(userId)")
                                }
                                for userId in temp {
                                    print("......frum button\(userId)")
                                }
                                FamilyManager.shared.updateFamily(field: [DBFamily.CodingKeys.members.rawValue : temp], familyId: family.familyId)
                                for user in newlyAddedUsersDBuser {
                                    if var currentArray = user.families {
                                        currentArray.append(family.familyId)
                                        UserManager.shared.updateUserField(userId: user.userId, field: [DBuser.CodingKeys.families.rawValue : currentArray])
                                    } else {
                                        UserManager.shared.updateUserField(userId: user.userId, field: [DBuser.CodingKeys.families.rawValue : [family.familyId]])
                                    }
                                }
                                if selectedImage != UIImage() {
                                    print(".........looks like image is selected...........")
                                    try await familyProfileViewModel.uploadImage(familyId: family.familyId, image: selectedImage)
                                }
                               
                                fetchAndUpdate.getUserFamilies()
                                chatView2Model.getMembers(members: temp)
                                showFamilyProfile = false
                            }
                            
                        } catch {
                            print("......errrrroorrrr from done button FamilyProfileView...... most probably the upload image fuck")
                        }
                    }
                } label: {
                    Text("Done")
                }
            }
        })
        .onChange(of: searchUser, perform: { newValue in
            showSearchResult = false
        })
        .navigationBarTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(chatView2Model)
    }
    func setValue() {
        familyName = family.familyName
        motto = family.motto ?? ""
        
    }
}

struct FamilyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FamilyProfileView(family:  DBFamily(familyId: "", familyName: "Monkey", owner: "", motto: "i will be pirate king", profilePhotoPath: "", profilePhotoPathUrl: "", members: []), showFamilyProfile: .constant(false))
                .environmentObject(ChatView2Model())
                .environmentObject(FetchAndUpdate())
            
                
        }
       
    }
}
