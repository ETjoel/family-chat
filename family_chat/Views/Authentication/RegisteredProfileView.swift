//
//  RegisteredProfileView.swift
//  family_chat
//
//  Created by Joel Tesfaye on 11/08/2023.
//

import SwiftUI
@MainActor
final class CreateUserDB: ObservableObject {
    
    @Published var selectedImage = UIImage()
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var bio = ""
    
    func uploadToDB() throws {
        let returnedResult = try AuthManager.shared.getAllUsers()
        let user = DBuser(userId: returnedResult.uid, firstName: firstName, lastName: lastName, bio: bio, email: returnedResult.email, PhotoURL: returnedResult.photoURL == nil ? "" : returnedResult.photoURL?.absoluteString, dateCreated: Date(), isPremium: false, profileImagePath: "", profileImagePathUrl: "", families: [])
        try  UserManager.shared.createNewUser(user: user)
    }
    func uploadImage(image: UIImage) async throws {
        guard let data = image.jpegData(compressionQuality: 0.3), let currentUser = try? AuthManager.shared.getAllUsers() else {
            print("looks like you failed to upload image")
            return
        }
        Task {
            do {
                let uploadResult = try await StorageManager.shared.uploadImage(data: data)
                var field = [DBuser.CodingKeys.profileImagePath.rawValue : uploadResult.path]
                try UserManager.shared.updateUserField(userId: currentUser.uid, field: field)
                let url = try await StorageManager.shared.downloadDataWithUrl(path: uploadResult.path)
                field = [DBuser.CodingKeys.profileImagePathUrl.rawValue : url.absoluteString]
                try UserManager.shared.updateUserField(userId: currentUser.uid, field: field)
            } catch {
                print("Something happend in uploadImage funtion in RegisteredProfileView")
                print(error)
            }
        }
    }
}

struct RegisteredProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    //@State private var isEditing: Bool = false
    @Binding var showRegistedProfile: Bool
    @Binding var showRegister: Bool
    
    @State var showSheet: Bool = false
    
    @StateObject private var createUserDB = CreateUserDB()
    @EnvironmentObject var fetchAndUpdate: FetchAndUpdate
    var body: some View {
        VStack {
            Image("fam").resizable()
                .frame(width: 120, height: 120)
                .cornerRadius(60)
                .overlay {
                    Image(uiImage: createUserDB.selectedImage).resizable()
                        .frame(width: 120, height: 120)
                        .cornerRadius(60)

                }
           
            Button {
                showSheet = true
            } label: {
                Text("Set Profile")
            }
            Form{
                Section {
                    TextField("First Name", text: $createUserDB.firstName)
                    TextField("Last Name", text: $createUserDB.lastName)
                }.autocapitalization(.none).disableAutocorrection(true)
                Section {
                    TextField("bio", text: $createUserDB.bio)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showSheet, content: {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $createUserDB.selectedImage)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if createUserDB.firstName.count > 1 {
                        Task {
                            do {
                                try createUserDB.uploadToDB()
                                if createUserDB.selectedImage != UIImage() {
                                    try await createUserDB.uploadImage(image: createUserDB.selectedImage)
                                    print("upload image succcessful from RegistedProfileView")
                                }
                                try await fetchAndUpdate.loadCurrentUser()
                                fetchAndUpdate.getUserFamilies()
                                fetchAndUpdate.getUserChats()
                                showRegistedProfile = false
                                showRegister = false
                            } catch {
                                print("Try again the upload part didn't work")
                            }
                        }
                    }
                } label: {
                    Text("Done")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showRegistedProfile = false
                } label: {
                    Text("Cancel")
                }
            }
        }
    }
}

struct RegisteredProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisteredProfileView(showRegistedProfile: .constant(false), showRegister: .constant(false))
                .preferredColorScheme(.light)
        }
       
    }
}
