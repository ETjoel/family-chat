//
//  UserChatsViewModel.swift
//  family_chat
//
//  Created by Joel Tesfaye on 04/09/2023.
//

import Foundation
import SwiftUI

final class UserChatsViewModel: ObservableObject {
    @Published var contents: [DBUsersChat] = []
    
    func sendContent(chat: DBUsersChat) {
        Task {
            do {
                try ChatManager.shared.storeUsersChats(chat: chat)
            } catch {
                print("error from sendContent")
                print(error)
            }
        }
    }
    
    func getContents(userId: String, user2Id: String) {
        Task {
            do {
                let snapshot = try await ChatManager.shared.getUserChats(userId: userId, user2Id: user2Id)
                for document in snapshot.documents {
                    let chat = try? document.data(as: DBUsersChat.self)
                    if chat != nil {
                        contents.append(chat!)
                        print("......\(chat!.message) from getContents func")
                    }
                }
            } catch {
                print("error from getContents")
                print(error)
            }
        }
    }
}

