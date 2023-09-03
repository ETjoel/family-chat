//
//  SettingView.swift
//  family_chat
//
//  Created by Joel Tesfaye on 26/07/2023.
//

import SwiftUI


struct SettingView: View {
    @StateObject private var settingViewModel = SettingViewModel()
    @EnvironmentObject var fetchAndUpdate: FetchAndUpdate
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var bio: String = ""
    @State var email: String = ""
    @State var selectedImage: UIImage = UIImage()
    @State var selectedImageUrl = ""
    @State var profileImagePath = ""
    @State var profilePhoto: UIImage?
    @State var showSheet: Bool = false
    @State var editingMode: Bool = false
    @Binding var showSignInView: Bool
    
    var _width = UIScreen.main.bounds.width
    var _height = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Spacer()
                    HStack {
                        HStack {
                            if editingMode {
                                Button {
                                    editingMode = false
                                } label: {
                                    Text("Cancel")
                                }
                            }
                            
                            Spacer()
                        }
                            .padding(.horizontal, _width * 0.07)
                            .frame(width: _width/3)
                        
                        Spacer()
                        Text("Setting").font(.headline).bold().frame(width: _width/3)
                        Spacer()
                        HStack{
                            Spacer()
                            Button {
                                editBAction()
                            } label: {
                                Text(editingMode ? "Done" : "Edit")
                            }
                        }
                            .padding(.horizontal, _width * 0.07)
                            .frame(width: _width/3)
                    }
                }
                .padding(.horizontal)
                .frame(width: _width, height: _height * 0.08)
                .background(Color("tabView"))
                VStack {}.frame(height: 1)
                Spacer()
                if selectedImage != UIImage() {
                    Image(uiImage: selectedImage).resizable()
                        .frame(width: 120, height: 120)
                        .cornerRadius(60)
                }else if fetchAndUpdate.user != nil {
                    UserProfilePic(user: fetchAndUpdate.user!, size: 120)
                }
                else {
                    VStack {}.frame(height: 120)
                }
                if editingMode {
                    Button {
                        showSheet = true
                    } label: {
                        Text("Change Profile").foregroundColor(Color.shared.accentColor)
                    }
                }
                VStack {
                    Text("user info").foregroundColor(Color.shared.mainTextColor.opacity(0.4))
                    VStack(alignment: .leading, spacing: 1) {
                        VStack {
                            if editingMode {
                                VStack {
                                    TextField("First Name", text: $firstName)
                                    Rectangle().fill(Color.shared.mainTextColor.opacity(0.5)).frame(height: 1)
                                    TextField("Last Name", text: $lastName)
                                    Rectangle().fill(Color.shared.mainTextColor.opacity(0.5)).frame(height: 1)
                                    TextField("bio", text: $bio)
                                }
                                .frame(width: _width - _width/9, height: 120)
                                
                            } else {
                                VStack(alignment: .leading) {
                                    Text("\(firstName != "" ? firstName : "Full Name") \(lastName)")
                                    Rectangle().fill(Color.shared.mainTextColor.opacity(0.5)).frame(height: 1)
                                    Text("\(bio != "" ? bio : "bio")")
                                }.frame(width: _width - _width/9, height: 80)
                            }
                        }
                        .font(.title3)
                        .padding()
                        .foregroundColor(Color.shared.mainTextColor)
                        .background(Color.shared.chatBackground)
                        .cornerRadius(10)
                        
                    }
                    
                    Text("\(email)").foregroundColor(.white.opacity(0.5))
                    if !editingMode {
                        VStack {
                            Button {
                                Task {
                                    do {
                                        try settingViewModel.logOut()
                                        showSignInView = true
                                    } catch {
                                        print("Failed to log out for some reason")
                                    }
                                }
                                
                            } label: {
                                Text("Log out").font(.title3)
                                    .frame(height: 40)
                                    .foregroundColor(.white)
                            }
                            Rectangle().fill(.black.opacity(0.1))
                                .frame(height: 1)
                            Button {
                                Task {
                                    do {
                                        try await settingViewModel.resetPassword()
                                        print("a message is sent to your email")
                                    } catch {
                                        print("Failded to reset a password")
                                    }
                                }
                            } label: {
                                Text("Reset Password")
                                    .frame(height: 40).font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: _width/2)
                        .background(Color.shared.accentColor)
                        .cornerRadius(10)
                    }
                    Spacer()
                }
                .frame(width: _width, height: _height * 0.68)
                .background(Color.secondary.opacity(0.1))
            }
        }
        .ignoresSafeArea( edges: .top)
        .padding()
        .environmentObject(settingViewModel)
        .task({
            setValues()
            if selectedImageUrl == "", let user = fetchAndUpdate.user {
                selectedImage = try! await settingViewModel.getProfileImage(user: user)
            }
            print("user loaded")
        })
        .sheet(isPresented: $showSheet, content: {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
            }
            ToolbarItem(placement: .navigationBarLeading) {
                if editingMode {
                    Button {
                        editingMode = false
                    } label: {
                        Text("cancel")
                    }
                }
            }
        }
    }
    func setValues() {
        if let user = fetchAndUpdate.user {
            firstName = user.firstName
            lastName = user.lastName!
            bio = user.bio!
            email = user.email!
            if user.profileImagePathUrl! != "" {
                selectedImageUrl = user.profileImagePathUrl!
            } else if user.PhotoURL! != "" {
                selectedImageUrl = user.PhotoURL!
            }
            profileImagePath = user.profileImagePath!
        }
    }
    func editBAction() {
        if editingMode {
            if let user = fetchAndUpdate.user, firstName.count > 1 {
                Task {
                    do {
                        let temp = DBuser(userId: user.userId, firstName: firstName, lastName: lastName, bio: bio, email: user.email, PhotoURL: user.PhotoURL, dateCreated: Date(), isPremium: user.isPremium, profileImagePath: user.profileImagePath, profileImagePathUrl: user.profileImagePathUrl, families: [])
                        try? UserManager.shared.updateUser(user: temp)
                        if selectedImage != UIImage() {
                            try await settingViewModel.uploadImage(user: user, image: selectedImage)
                            print("uploading Profile success")
                        }
                        try await fetchAndUpdate.loadCurrentUser()
                        print("then we did update on user")
                        print("...after printing this update the DB")
                        selectedImage = UIImage()
                        editingMode = false
                    } catch {
                        print("you failed again to update the portifolio")
                    }
                }
            }
            
        } else {
            editingMode = true
        }

    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(showSignInView: .constant(false))
            .environmentObject(FetchAndUpdate())
        .preferredColorScheme(.light)
    }
}
