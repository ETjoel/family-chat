//
//  ChatManager.swift
//  family_chat
//
//  Created by Joel Tesfaye on 22/08/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUsersChat: Codable, Hashable {
    let sender: String
    let reciever: String
    let message: String
    let time: Date
    
    init(sender: String, reciever: String, message: String, time: Date) {
        self.sender = sender
        self.reciever = reciever
        self.message = message
        self.time = time
    }
    
    init(chat: DBUsersChat) {
        self.sender = chat.sender
        self.reciever = chat.reciever
        self.message = chat.message
        self.time = chat.time
    }
    
    enum CodingKeys: String, CodingKey {
        case sender = "sender"
        case reciever = "reciever"
        case message = "message"
        case time = "time"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.sender, forKey: .sender)
        try container.encode(self.reciever, forKey: .reciever)
        try container.encode(self.message, forKey: .message)
        try container.encode(self.time, forKey: .time)
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sender = try container.decode(String.self, forKey: .sender)
        self.reciever = try container.decode(String.self, forKey: .reciever)
        self.message = try container.decode(String.self, forKey: .message)
        self.time = try container.decode(Date.self, forKey: .time)
    }
}

struct DBFamilyChat: Codable, Hashable {
    let sender: String
    let message: String
    let time: Date
    
    init(sender: String, message: String, time: Date) {
        self.sender = sender
        self.message = message
        self.time = time
    }
    
    init(chat: DBUsersChat) {
        self.sender = chat.sender
        self.message = chat.message
        self.time = chat.time
    }
    
    enum CodingKeys: String, CodingKey {
        case sender = "sender"
        case message = "message"
        case time = "time"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.sender, forKey: .sender)
        try container.encode(self.message, forKey: .message)
        try container.encode(self.time, forKey: .time)
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sender = try container.decode(String.self, forKey: .sender)
        self.message = try container.decode(String.self, forKey: .message)
        self.time = try container.decode(Date.self, forKey: .time)
    }
}

struct DBUserChatHistory: Codable, Hashable {
    let sentFromTo: String
    let time: Date
    
    init(sentFromTo: String, time: Date) {
        self.sentFromTo = sentFromTo
        self.time = time
    }
    
    init(chat: DBUserChatHistory) {
        self.sentFromTo = chat.sentFromTo
        self.time = chat.time
    }
    
    enum CodingKeys: String, CodingKey {
        case sentFromTo = "sent_from_to"
        case time = "time"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.sentFromTo, forKey: .sentFromTo)
        try container.encode(self.time, forKey: .time)
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sentFromTo = try container.decode(String.self, forKey: .sentFromTo)
        self.time = try container.decode(Date.self, forKey: .time)
    }
    
}

class ChatManager {
    static var shared = ChatManager()
    
    init() {}
    
    private let familyChats = Firestore.firestore().collection("FamilyChats")
    private let usersChats =   Firestore.firestore().collection("UsersChats")
    private let userChatsHistory = Firestore.firestore().collection("UsersChatsHistory")
    
    
    func familyChatCollection(familyName: String) -> DocumentReference {
        familyChats.document(familyName)
    }
    func storeFamilyChats(familyName: String, chat: DBFamilyChat) throws{
        try familyChatCollection(familyName: familyName).collection(familyName).document(UUID().uuidString).setData(from: chat, merge: false)
    }
    
    func getFamilyChats(familyName: String) async throws ->  QuerySnapshot{
        try await familyChatCollection(familyName: familyName).collection(familyName)
            .order(by: DBFamilyChat.CodingKeys.time.rawValue, descending: false)
            .limit(to: 50)
            .getDocuments()
    }
    
    
    
    func userChatCollection(user1Id: String, user2Id: String) -> DocumentReference {
        usersChats.document(user1Id > user2Id ? user1Id + user2Id : user2Id + user1Id)
    }
    
    func storeUsersChats(chat: DBUsersChat) throws {
        try userChatCollection(user1Id: chat.sender, user2Id: chat.reciever)
            .collection(chat.sender > chat.reciever ? chat.sender + chat.reciever : chat.reciever + chat.sender)
            .document(UUID().uuidString).setData(from: chat, merge: false)
        try createUserChatHistory(chat: chat)
    }
    func getUserChats(userId: String, user2Id: String) async throws ->  QuerySnapshot {
        try await userChatCollection(user1Id:userId, user2Id: user2Id)
            .collection(userId > user2Id ? userId + user2Id : user2Id + userId)
            .order(by: "time", descending: true)
            .limit(to: 50)
            .getDocuments()
    }
    
    func getUsersChatters(userId: String) async throws ->  QuerySnapshot {
        try await userChatHistoryCollection(user: userId)
            .collection(userId)
            .order(by: "time", descending: true)
            .getDocuments()
    }
    
    
    func userChatHistoryCollection(user: String) -> DocumentReference {
        userChatsHistory.document(user)
    }
    
    func createUserChatHistory(chat: DBUsersChat) throws {
        let temp = DBUserChatHistory(sentFromTo: chat.reciever, time: chat.time)
        try userChatHistoryCollection(user: chat.sender)
            .collection(chat.sender)
            .document(chat.sender > chat.reciever ? chat.sender + chat.reciever : chat.reciever + chat.sender)
            .setData(from: temp, merge: true)
        let temp2 = DBUserChatHistory(sentFromTo: chat.sender, time: chat.time)
        try userChatHistoryCollection(user: chat.reciever)
            .collection(chat.reciever)
            .document(chat.sender > chat.reciever ? chat.sender + chat.reciever : chat.reciever + chat.sender)
            .setData(from: temp2, merge: true)
        
    }
    
    //    func createFamilyChat(family: DBFamily, chat: DBchats) {
    //        familyChatCollection(familyName: family.familyName).setData(T##documentData: [String : Any]##[String : Any])
    //    }
    
//    func storeUserChats(chat: DBUsersChat) throws {
//        try userChatCollection(user1: chat.sender, user2: chat.reciever).setData(from: chat, merge: false)
//    }
}
//{ snapshot, error in
//    if let error = error {
//        print("error from getFamilyChats func")
//        print(error)
//        return
//    }
//    if let quary = snapshot?.documents {
//        for document in quary {
//            let chat = try? document.data(as: DBFamilyChat.self)
//            if chat != nil {
//                chats.append(chat!)
//                print("......\(chat!.message) from getFamilyChats func")
//            }
//        }
//    }
//}
