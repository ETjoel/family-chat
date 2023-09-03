//
//  ContentView.swift
//  family_chat
//
//  Created by Joel Tesfaye on 22/07/2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

@MainActor
final class SignInUsingEmail: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var yes = false
    func signIn() async throws {
        try await AuthManager.shared.signIn(email: email, password: password)
    }
    func signInGoogle() async throws {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.cannotFindHost)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        let email = gidSignInResult.user.profile?.email
        let name = gidSignInResult.user.profile?.name
        //        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let token = GooglesignInResultModel(idToken: idToken, accessToken: accessToken, email: email, name: name)
        try await AuthManager.shared.signInWithGoogle(token: token)
        //try await UserManager.shared.createNewUser(auth: authResult)
    }
    
}

struct LoginView: View {
    @StateObject private var signIn = SignInUsingEmail()
    @EnvironmentObject var fetchAndUpdate: FetchAndUpdate
    
    var nameWidth = UIScreen.main.bounds.width
    var nameHeight = UIScreen.main.bounds.height
    
    @State var error: Bool = false
    
    @Binding var showSignInView: Bool
    @Binding var showLogin: Bool
    @Binding var chooseTag: ChooseTag
    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("Family Chat").font(.largeTitle).bold()
                        .foregroundColor(Color.shared.mainTextColor)
                        
                    Text("Welcom back ...")
                        .foregroundColor(Color.shared.mainTextColor)
                }
                VStack {}.frame(height: 30)
                
                VStack(spacing: 10){
                    //Spacer(minLength: 3)
                    TextField("email", text: $signIn.email)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 20)
                        .autocapitalization(.none)
                        .foregroundColor(Color.shared.mainTextColor)
                        .font(.title2)
                        .frame(width: nameWidth - nameWidth/10, height: nameHeight/12)
                        .background(Color.shared.tertiaryColor)
                        .cornerRadius(10)
                    //  .shadow(color: .black, radius: 35, x: 0, y: 50)
                    SecureField("password", text: $signIn.password)
                        .padding(.horizontal, 20)
                        .foregroundColor(Color.shared.mainTextColor)
                        .font(.title2)
                        .frame(width: nameWidth - nameWidth/10, height: nameHeight/12)
                        .background(Color.shared.tertiaryColor)
                        .cornerRadius(10)
                    //  .shadow(color: .black, radius: 35, x: 0, y: 50)
                    //_VSpacer(minHeight: 5)
                    VStack(alignment: .trailing) {
                        HStack {
                            Spacer()
                            if error {
                                Text("Either the email or password is wrong")
                                    .foregroundColor(Color.shared._red)
                            }
                            
                        }
                        
                    }.frame(width: nameWidth - nameWidth/10, height: 15)
                    HStack {
                        Text("Login")
                            .foregroundColor(.white)
                            .font(.title2).bold()
                    }
                    .frame(width: nameWidth - nameWidth/10, height: nameHeight/12)
                    .background(Color.shared.accentColor)
                    .cornerRadius(10)
                    .padding(.vertical, 20)
                    .onTapGesture {
                        Task {
                            do {
                                guard !signIn.email.isEmpty, !signIn.password.isEmpty else {
                                    error = true
                                    print("Either email or password invalid")
                                    return
                                }
                                try await signIn.signIn()
                                try await fetchAndUpdate.loadCurrentUser()
                                fetchAndUpdate.getUserFamilies()
                                fetchAndUpdate.getUserChats()
                                showSignInView = false
                                chooseTag = ChooseTag.families
                            } catch {
                                self.error = true
                                print("Well doom day is not that far!")
                            }
                        }
                    }
                    HStack {
                        Button{
                        } label: {
                            Text("Forgot Password?")
                                .foregroundColor(Color.shared.mainTextColor)
                        }
                    }
                    .frame(width: nameWidth - nameWidth/10, height: nameHeight/19, alignment: .trailing)
                    //.padding(.vertical, 20)
                    HStack {
                        Rectangle().frame(height: 1)
                        Text("or Login with").font(.headline)
                        Rectangle().frame(height: 1)
                    }
                    .foregroundColor(Color.shared.mainTextColor)
                    .frame(width: nameWidth - nameWidth/10)
                    HStack(spacing: 1) {
                        HStack(spacing: 0){
                            Image("google_logo").resizable().frame(width: 50, height: 50)
                            Text("oogle").font(.title3).bold().foregroundColor(.black.opacity(0.6))
                        }.frame(width: (nameWidth - nameWidth/10)/2, height: nameHeight/15)
                            .background(Color.shared.quaternaryColor)
                            .cornerRadius(5)
                            .onTapGesture {
                                Task {
                                    do {
                                        try await signIn.signInGoogle()
                                        try await fetchAndUpdate.loadCurrentUser()
                                        fetchAndUpdate.getUserFamilies()
                                        fetchAndUpdate.getUserChats()
                                        showSignInView = false
                                        chooseTag = ChooseTag.families
                                    } catch {
                                        print("Well failded again for google signIn")
                                    }
                                }
                            }
                        HStack(spacing: 1){
                            Image("Apple_logo").resizable().frame(width: 50, height: 50)
                                .background(.clear)
                            Text("Apple").font(.title3).bold().foregroundColor(.black.opacity(0.6))
                        }.frame(width: (nameWidth - nameWidth/10)/2, height: nameHeight/15)
                            .background(Color.shared.quaternaryColor)
                            .cornerRadius(5)
                            .onTapGesture {
                                
                            }
                    }
                    
                    HStack {
                        Text("Don't have an account?").foregroundColor(Color.shared.mainTextColor)
                        Button {
                            showLogin = false
                        } label: {
                            Text("Sign up").foregroundColor(Color.shared.accentColor).font(.title2).bold()
                        }
                        
                    }
                    .padding(.vertical, 30)
                    Spacer()
                }
                .padding(.vertical)
                .frame(width: nameWidth, height: nameHeight/1.5)
            }
            
            
        }
        .edgesIgnoringSafeArea(.top)
        
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showSignInView: .constant(false), showLogin: .constant(false), chooseTag: .constant(ChooseTag.families))
            .preferredColorScheme(.dark)
    }
}
