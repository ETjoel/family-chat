//
//  RegisterView.swift
//  family_chat
//
//  Created by Joel Tesfaye on 23/07/2023.
//

import SwiftUI

@MainActor
final class SignUpUsingEmail: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var yes = false
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Either email or password invalid")
            return
        }
        
        _ = try await AuthManager.shared.createUser(email: email, password: password)
    }
    
}

struct RegisterView: View {
    //@Environment(\.presentationMode) var presentationMode
    
    @StateObject private var signUp = SignUpUsingEmail()
    @StateObject private var signIn = SignInUsingEmail()
    
    @State private var confirmpassowrd = ""
    
    @Binding var showLogin: Bool
    @Binding var showSignIn: Bool
    @Binding var chooseTag: ChooseTag
    
    @State var showRegisterProfile: Bool = false
    
    var nameWidth = UIScreen.main.bounds.width
    var nameHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("Family Chat").font(.largeTitle).bold()
                        .foregroundColor(Color.shared.mainTextColor)
                }
                VStack {}.frame(height: 30)
                VStack(spacing: 10){
                    TextField("email", text: $signUp.email)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 20)
                        .autocapitalization(.none)
                        .foregroundColor(Color.shared.mainTextColor)
                        .font(.title2)
                        .frame(width: nameWidth - nameWidth/10, height: nameHeight/12)
                        .background(Color.shared.tertiaryColor)
                        .cornerRadius(10)
                    //.shadow(color: .black, radius: 35, x: 0, y: 50)
                    SecureField("password", text: $signUp.password)
                        .padding(.horizontal, 20)
                        .foregroundColor(Color.shared.mainTextColor)
                        .font(.title2)
                        .frame(width: nameWidth - nameWidth/10, height: nameHeight/12)
                        .background(Color.shared.tertiaryColor)
                        .cornerRadius(10)
                    //.shadow(color: .black, radius: 35, x: 0, y: 50)
                    //_VSpacer(minHeight: 5)
                    VStack {}.frame(width: nameWidth - nameWidth/10, height: 15)
                    HStack {
                        Text("Sign Up")
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
                                try await signUp.signUp()
                                chooseTag = ChooseTag.families
                                withAnimation {
                                    showRegisterProfile = true
                                }
                            } catch {
                                print("Failed as always")
                                print(error)
                            }
                        }
                    }
                    Spacer()
                    HStack {
                        Rectangle().frame(height: 1)
                        Text("or Signup  with").font(.headline)
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
                                        chooseTag = ChooseTag.families
                                        withAnimation {
                                            showRegisterProfile = true
                                        }
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
                        Text("Already have an account?")
                            .foregroundColor(Color.shared.mainTextColor)
                        Button {
                            showLogin = true
                        } label: {
                            Text("Sign in")
                                .foregroundColor(Color.shared.accentColor).font(.title2).bold()
                        }
                        
                    }
                    .padding(.vertical, 30)
                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $showRegisterProfile, content: {
                NavigationView {
                    RegisteredProfileView(showRegistedProfile: $showRegisterProfile, showRegister: $showSignIn)
                        .transition(._slide)
                }
                .navigationBarHidden(true)
            })
        }
        //.edgesIgnoringSafeArea(.top)
        
    }
}

struct SlideTransition: ViewModifier {
    var offset: CGSize

    func body(content: Content) -> some View {
        content
            .offset(offset)
    }
}

extension AnyTransition {
    static var _slide: AnyTransition {
        let insertion = AnyTransition.modifier(
            active: SlideTransition(offset: CGSize(width: UIScreen.main.bounds.width, height: 0)),
            identity: SlideTransition(offset: .zero)
        )
        let removal = AnyTransition.modifier(
            active: SlideTransition(offset: CGSize(width: -UIScreen.main.bounds.width, height: 0)),
            identity: SlideTransition(offset: .zero)
        )
        return .asymmetric(insertion: insertion, removal: removal)
    }
}


struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView(showLogin: .constant(false), showSignIn: .constant(false), chooseTag: .constant(ChooseTag.families))
        }
        
        
    }
}
