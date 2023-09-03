//
//  SettingViewModel.swift
//  family_chat
//
//  Created by Joel Tesfaye on 04/09/2023.
//

import Foundation
import SwiftUI

@MainActor
final class SettingViewModel: ObservableObject {
    
    func uploadImage(user: DBuser?, image: UIImage) async throws {
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
    func getProfileImage(user: DBuser?) async throws -> UIImage {
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
    
    func updateUser(user: DBuser) throws {
        try UserManager.shared.updateUser(user: user)
    }
    
    func logOut() throws {
        try AuthManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let user = try AuthManager.shared.getAllUsers()
        guard let email = user.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthManager.shared.resetPassword(email: email)
    }
    
    
}

