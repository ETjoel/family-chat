//
//  ChatView2Model.swift
//  family_chat
//
//  Created by Joel Tesfaye on 04/09/2023.
//

import Foundation
import SwiftUI


final class ChatView2Model: ObservableObject {
    @Published private(set) var contents: [DBFamilyChat] = []
    @Published private(set) var users: [String: DBuser] = [:]
    
    func sendContent(familyName: String, chat: DBFamilyChat) {
        Task {
            do {
                try ChatManager.shared.storeFamilyChats(familyName: familyName, chat: chat)
            } catch {
                print("error from sendContent")
                print(error)
            }
        }
    }
    
    func getContents(familyName: String) {
        Task {
            do {
                let snapshot = try await ChatManager.shared.getFamilyChats(familyName: familyName)
                for document in snapshot.documents {
                    let chat = try? document.data(as: DBFamilyChat.self)
                    if chat != nil {
                        contents.append(chat!)
                        print("......\(chat!.message) from getFamilyChats func")
                    }
                }
            } catch {
                print("error from getContents")
                print(error)
            }
        }
    }
    func getMembers(members: [String]) {
        self.users = [:]
        Task {
            do {
                for userId in members {
                    let user = try await UserManager.shared.getUser(userId: userId)
                    self.users[userId] = user
                }
                
            } catch {
                
            }
        }
    }
    func appendContent(chat: DBFamilyChat) {
        self.contents.append(chat)
    }
    func appendUsers(user: DBuser) {
        self.users[user.userId] = user
    }
}

