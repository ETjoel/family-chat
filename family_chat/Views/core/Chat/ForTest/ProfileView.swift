//
//  ProfileView.swift
//  family_chat
//
//  Created by Joel Tesfaye on 10/08/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

@MainActor
final class UpdateUserDB: FetchAndUpdate {
    
    func uploadImage(image: UIImage) async throws {
        guard let data = image.jpegData(compressionQuality: 0.3), let user = user else { return }
        Task {
            do {
                let returnedResult = try await StorageManager.shared.uploadImage(data: data)
                let field = [DBuser.CodingKeys.profileImagePath.rawValue: returnedResult.path]
                print(field)
                UserManager.shared.updateUserField(userId: user.userId, field: field)
                let url = try await StorageManager.shared.downloadDataWithUrl(path: returnedResult.path)
                let field1 = [DBuser.CodingKeys.profileImagePathUrl.rawValue: url.absoluteString]
                print(field1)
                UserManager.shared.updateUserField(userId: user.userId, field: field1)
                print("success")
            } catch {
                print("hello, image uploader to storage failer")
                print(error)
            }
        }
    }
    func getProfileImage() async throws -> UIImage {
        guard let user = user, user.profileImagePath != "" else {
            return UIImage()
        }
        var selectedImage: UIImage = UIImage()
        Task {
            do {
                let data = try await StorageManager.shared.downloadDataWithPath(user: user)
                selectedImage =  UIImage(data: data) ?? UIImage()
            } catch {
                print("error from getProfileImage: \(error)")
            }
        }
        return selectedImage
    }
    
}
struct ProfileView: View {
    @StateObject private var updateUserDB: UpdateUserDB = UpdateUserDB()
    @EnvironmentObject private var fetchAndUpdate: FetchAndUpdate
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var bio: String = ""
    @State var selectedImage: UIImage = UIImage()
    @State var selectedImageUrl = ""
    @State var profileImagePath = ""
    @State var profilePhoto: UIImage?
    
    @State var showSheet: Bool = false
    @Binding var showProfile: Bool
    var body: some View {
            VStack {
                if selectedImage != UIImage() {
                    Image(uiImage: selectedImage).resizable()
                        .frame(width: 120, height: 120)
                        .cornerRadius(60)
                } else if selectedImageUrl != "", let url = URL(string: selectedImageUrl) {
                    AsyncImage(url: url) {image in
                        image
                            .resizable()
                            .frame(width: 120, height: 120)
                            .cornerRadius(60)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 120, height: 120)
                    }
                } else {
                    Image("fam").resizable()
                        .frame(width: 120, height: 120)
                        .cornerRadius(60)
                }
                Button {
                    showSheet = true
                } label: {
                    Text("Change Profile")
                }
                if let user = fetchAndUpdate.user {
                    Text("email: \(user.email!)")
                }
                
                Form{
                    Section {
                        TextField("Frist Name", text: $firstName)
                            .autocapitalization(.none)
                        TextField("Last Name", text: $lastName)
                            .autocapitalization(.none)
                    }
                    Section {
                        TextField("bio", text: $bio)
                            .autocapitalization(.none)

                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            do {
                                try updateUser()
                                if selectedImage != UIImage() {
                                    try await updateUserDB.uploadImage(image: selectedImage)
                                    print("uploading Profile success")
                                }
                                try await fetchAndUpdate.loadCurrentUser()
                                print("then we did update on user")
                                print("...after printing this update the DB")
                                showProfile = false
                            } catch {
                                print("you failed again to update the portifolio")
                            }
                        }
                        
                    } label: {
                        Text("Done")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showProfile = false
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .task({
                setValues()
                if selectedImageUrl == "" {
                    selectedImage = try! await updateUserDB.getProfileImage()
                }
                print("user loaded")
            })
            .sheet(isPresented: $showSheet, content: {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
            })
            .navigationBarTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
    }
    func setValues() {
        if let user = fetchAndUpdate.user {
            firstName = user.firstName
            lastName = user.lastName!
            bio = user.bio!
            if user.profileImagePathUrl! != "" {
                selectedImageUrl = user.profileImagePathUrl!
            } else if user.PhotoURL! != "" {
                selectedImageUrl = user.PhotoURL!
            }
            profileImagePath = user.profileImagePath!
        }
    }
    func updateUser() throws {
        if let user = fetchAndUpdate.user {
            let temp = DBuser(userId: user.userId, firstName: firstName, lastName: lastName, bio: bio, email: user.email, PhotoURL: user.PhotoURL, dateCreated: Date(), isPremium: user.isPremium, profileImagePath: user.profileImagePath, profileImagePathUrl: user.profileImagePathUrl, families: [])
            try UserManager.shared.updateUser(user: temp)
        }
    }
    
//    func uploadImage(image: UIImage) async throws {
//        guard let data = image.jpegData(compressionQuality: 1.0), let user = updateUserDB.user else { return }
//        Task {
//            do {
//                let returnedResult = try await StorageManager.shared.uploadImage(data: data)
//                var field = [DBuser.CodingKeys.profileImagePath.rawValue: returnedResult.path]
//                try UserManager.shared.updateUserField(userId: user.userId, field: field)
//                let url = try await StorageManager.shared.downloadDataWithUrl(user: user)
//                field = [DBuser.CodingKeys.profileImagePathUrl.rawValue: url.absoluteString]
//                try UserManager.shared.updateUserField(userId: user.userId, field: field)
//                print("success")
//            } catch {
//                print("hello, image uploader to storage failer")
//                print(error)
//            }
//        }
//    }
//    func getProfileImage() async throws {
//        guard let user = updateUserDB.user, user.profileImagePath != "" else {return}
//        Task {
//            do {
//                let data = try await StorageManager.shared.downloadDataWithPath(user: user)
//                selectedImage = UIImage(data: data) ?? UIImage()
//            } catch {
//                print("error from getProfileImage: \(error)")
//            }
//        }
//    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(showProfile: .constant(false))
                .environmentObject(FetchAndUpdate())
        }
       
    }
}
