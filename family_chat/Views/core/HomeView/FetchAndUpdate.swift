//
//  FetchAndUpdate.swift
//  family_chat
//
//  Created by Joel Tesfaye on 04/09/2023.
//

import Foundation
import SwiftUI

@MainActor
class FetchAndUpdate: ObservableObject {
    @Published private(set) var user: DBuser? = nil
    @Published private(set) var userFamilies: [DBFamily] = []
    @Published private(set) var userChats: [DBuser] = []
    
    init() {
        Task {
            do {
                try await loadCurrentUser()
                getUserFamilies()
                getUserChats()
            } catch {
                print("problem in loaded the user from FetchAndUpdate")
                print(error)
            }
        }
    }
    
    func loadCurrentUser()  async throws {
        let authResult = try  AuthManager.shared.getAllUsers()
        print("...........are you correct now\(authResult.uid)")
        self.user = try await UserManager.shared.getUser(userId: authResult.uid)
    }
    
    func getUserFamilies() {
        guard let user = user else {
            print(".....(1) problem from getUserFamilies func..........")
            return
        }
        self.userFamilies = []
        for family in user.families! {
            Task {
                do {
                    let _family = try await FamilyManager.shared.getFamilies(familyId: family)
                    print("......(2) \(_family.familyName) from getUserFamilies func....")
                    self.userFamilies.append(_family)
                } catch {
                    print(".....(2) problem from getUserFamilies func..........")
                    print(error)
                }
            }
        }
    }
    func getUserChats() {
        guard let user = user else {
            print(".....(1) problem from getUserChats func..........")
            return
        }
        self.userChats = []
        Task {
            do {
                let snapshot = try await ChatManager.shared.getUsersChatters(userId: user.userId)
                for document in snapshot.documents {
                    let chatHistory = try? document.data(as: DBUserChatHistory.self)
                    if chatHistory != nil {
                        let chatter = try await UserManager.shared.getUser(userId: chatHistory!.sentFromTo)
                        self.userChats.append(chatter)
                    }
                }
            } catch {
                print(".....(2) problem from getUserChats func..........")
                print(error)
            }
        }
    }
}

