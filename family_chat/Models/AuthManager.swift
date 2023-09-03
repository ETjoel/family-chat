//
//  AuthManager.swift
//  family_chat
//
//  Created by Joel Tesfaye on 23/07/2023.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoURL: URL?
    
    init(uid: String, email: String?, photoURL: URL?){
        self.uid = uid
        self.email = email
        self.photoURL = photoURL
    }
    init(user: User){
        uid = user.uid
        email = user.email
        photoURL = user.photoURL
    }
}
struct GooglesignInResultModel {
    let idToken: String
    let accessToken: String
    let email: String?
    let name: String?
}

final class AuthManager {
    static let shared = AuthManager()
    private init(){}
    
    func createUser(email: String, password: String) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let result = AuthDataResultModel(
            uid: authDataResult.user.uid,
            email: authDataResult.user.email,
            photoURL: authDataResult.user.photoURL)
        return result
    }
    
    func signIn(email: String, password: String) async throws{
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let result = AuthDataResultModel(uid: authDataResult.user.uid,  email: authDataResult.user.email,
                                         photoURL: authDataResult.user.photoURL)
    }
    
    func getAllUsers() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
extension AuthManager {
//    func signInWithGoogle(token: GooglesignInResultModel) async throws -> AuthDataResultModel {
//        let credential = GoogleAuthProvider.credential(withIDToken: token.idToken, accessToken: token.accessToken)
//        return try await signIn(credential: credential)
//    }
//    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
//        let authDataResult = try await Auth.auth().signIn(with: credential)
//        return AuthDataResultModel(user: authDataResult.user)
//    }
    func signInWithGoogle(token: GooglesignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: token.idToken, accessToken: token.accessToken)
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
