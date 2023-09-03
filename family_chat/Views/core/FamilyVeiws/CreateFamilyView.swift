//
//  CreateFamilyView.swift
//  family_chat
//
//  Created by Joel Tesfaye on 17/08/2023.
//

import SwiftUI
final class CreateFamilyViewModel: ObservableObject {
    func createFamily(family: DBFamily, users: [DBuser]) throws {
        try FamilyManager.shared.createFamily(family: family)
        for user in users {
            if var currentArray = user.families {
                currentArray.append(family.familyId)
                UserManager.shared.updateUserField(userId: user.userId, field: [DBuser.CodingKeys.families.rawValue : currentArray])
            } else {
                UserManager.shared.updateUserField(userId: user.userId, field: [DBuser.CodingKeys.families.rawValue : [family.familyId]])
            }
        }
        
    }
    
    func uploadImage(familyId: String, image: UIImage) async throws {
        guard let data = image.jpegData(compressionQuality: 0.2) else {
            print("looks like you failed to upload image")
            return
        }
        Task {
            do {
                let uploadResult = try await StorageManager.shared.uploadFamImage(data: data)
                var field = [DBFamily.CodingKeys.profilePhotoPath.rawValue : uploadResult.path]
                FamilyManager.shared.updateFamily(field: field, familyId: familyId)
                let url = try await StorageManager.shared.downloadDataWithUrl(path: uploadResult.path)
                field = [DBFamily.CodingKeys.profilePhotoPathUrl.rawValue : url.absoluteString]
                FamilyManager.shared.updateFamily(field: field, familyId: familyId)
            } catch {
                print("Something happend in uploadImage funtion in RegisteredProfileView")
                print(error)
            }
        }
    }
}

struct CreateFamilyView: View {
    @StateObject var createFamilyViewModel: CreateFamilyViewModel = CreateFamilyViewModel()
    @EnvironmentObject var fetchAndUpdate: FetchAndUpdate
//    @EnvironmentObject var familiesVeiwModel: FamiliesVeiwModel
    
    var _width = UIScreen.main.bounds.width
    
    @State var selectedImage: UIImage = UIImage()
    @State var familyName: String = ""
    @State var motto: String = ""
    @State var user: String = ""
    @State var users: [DBuser] = []
    @State var selectedUser: DBuser?
    @State var showSheet: Bool = false
    @State var showSearchResult: Bool = false
    
    @Binding var showCreateFamily: Bool
    var body: some View {
        ZStack {
            VStack {
                if selectedImage == UIImage() {
                    Image("fam").resizable()
                        .frame(width: 120, height: 120)
                        .cornerRadius(60)
                } else {
                    Image(uiImage: selectedImage).resizable()
                        .frame(width: 120, height: 120)
                        .cornerRadius(60)
                }
                Button {
                    showSheet = true
                } label: {
                    Text("Set Profile")
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
                        
                        Text("Add Members").foregroundColor(Color.shared.mainTextColor.opacity(0.5))
                        HStack {
                            TextField("user name", text: $user).font(.title2).autocapitalization(.none).disableAutocorrection(true)
                                .padding()
                                .frame(width: _width - _width/2.6, height: 60)
                                .background(Color.shared.secondaryColor)
                                .cornerRadius(10)
                            Image(systemName: "magnifyingglass").font(.title)
                                .foregroundColor(user.count > 0 ? .green : .white)
                                .onTapGesture {
                                    getUserWithFirstName()
                                }
                            
                        }
                        .padding()
                        .frame(width: _width - _width/3.7, height: 60)
                        .background(Color.shared.secondaryColor.opacity(0.2))
                        .cornerRadius(10)
                        if showSearchResult {
                            Text("Add \"\(user)\"").font(.title2).bold()
                                .frame(width: _width/1.8, height: 58)
                                .background(.green.opacity(0.6))
                                .cornerRadius(10)
                                .onTapGesture {
                                    if let user = selectedUser {
                                        users.append(user)
                                        self.user = ""
                                        showSearchResult = false
                                    }
                                }
                        }
                        VStack {
                            ForEach(users, id: \.self) { user in
                                HStack(spacing: 5) {
                                    UserProfilePic(user: user, size: 60)
                                    Text(user.firstName).font(.title3)
                                        .foregroundColor(Color.shared.mainTextColor)
                                    Spacer()
                                }
                                .padding()
                                .frame(width: _width - _width/9, height: 70)
                                .background(Color.shared.chatBackground)
                                .cornerRadius(10)
                            }
                        }
                        Spacer()
                    }
                }
                .padding()
                .frame(width: _width)
                .background(Color.secondary.opacity(0.2))
            }
        }.sheet(isPresented: $showSheet, content: {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
        })
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if let user = fetchAndUpdate.user, familyName.count > 1 {
                        var members: [String] = [user.userId]
                        users.append(user)
                        for user in users {
                            members.append(user.userId)
                        }
                        let temp = DBFamily(familyId: UUID().uuidString, familyName: familyName, owner: user.userId, motto: motto, profilePhotoPath: "", profilePhotoPathUrl: "", members: members)
                        
                        Task {
                            do {
                                try createFamilyViewModel.createFamily(family: temp, users: users)
                                if selectedImage != UIImage() {
                                    try await createFamilyViewModel.uploadImage(familyId: temp.familyId, image: selectedImage)
                                }
                                try await fetchAndUpdate.loadCurrentUser()
                                fetchAndUpdate.getUserFamilies()
                                showCreateFamily = false
                            } catch {
                                print("you have got some error on Done button on CreateFamilyView")
                            }
                        }
                    }
                } label: {
                    Text("Done")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showCreateFamily = false
                } label: {
                    Text("Cancel")
                }
            }
        })
        .navigationTitle("Create Family")
        .navigationBarTitleDisplayMode(.inline)
    }
    func getUserWithFirstName() {
        if user.count > 0 {
            Task {
                do {
                    let snapshot = try await UserManager.shared.searchUserWithFirstName(firstName: user)
                    
                    for documents in snapshot.documents {
                        selectedUser = try documents.data(as: DBuser.self)
                        print("............please print firstName: \(selectedUser?.firstName ?? "not this")")
                    }
                    showSearchResult = true
                } catch {
                    print("it looks like we have a situation in getUserWithFirstName func")
                }
            }
        }
    }
}

struct CreateFamilyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateFamilyView(showCreateFamily: .constant(false))
                .environmentObject(FetchAndUpdate())
//                .environmentObject(FamiliesVeiwModel())

        }
        .preferredColorScheme(.dark)
      
    }
}
