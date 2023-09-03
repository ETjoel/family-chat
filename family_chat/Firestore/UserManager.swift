//
//  UserManager.swift
//  family_chat
//
//  Created by Joel Tesfaye on 10/08/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBuser: Codable, Hashable {
    let userId: String
    let firstName: String
    let lastName: String?
    let bio: String?
    let email: String?
    let PhotoURL: String?
    let dateCreated: Date?
    let isPremium: Bool?
    let profileImagePath: String?
    let profileImagePathUrl: String?
    let families: [String]?
    
    init(user: DBuser) {
        userId = user.userId
        firstName = user.firstName
        lastName = user.lastName
        bio = user.bio
        email = user.email
        PhotoURL = user.PhotoURL
        dateCreated = user.dateCreated
        isPremium = user.isPremium
        profileImagePath = user.profileImagePath
        profileImagePathUrl = user.profileImagePathUrl
        families = user.families
    }
    init(userId: String,
         firstName: String,
         lastName: String?,
         bio: String?,
         email: String?,
         PhotoURL: String?,
         dateCreated: Date?,
         isPremium: Bool?,
         profileImagePath: String?,
         profileImagePathUrl: String?,
         families: [String]){
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
        self.email = email
        self.PhotoURL = PhotoURL
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.profileImagePath = profileImagePath
        self.profileImagePathUrl = profileImagePathUrl
        self.families = families
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
        case email = "email"
        case PhotoURL = "photo_URL"
        case dateCreated = "date_created"
        case isPremium = "is_premium"
        case profileImagePath = "profile_image_path"
        case profileImagePathUrl = "profile_image_path_url"
        case families = "families"
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.PhotoURL = try container.decodeIfPresent(String.self, forKey: .PhotoURL)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        self.profileImagePath = try container.decodeIfPresent(String.self, forKey: .profileImagePath)
        self.profileImagePathUrl = try container.decodeIfPresent(String.self, forKey: .profileImagePathUrl)
        self.families = try container.decodeIfPresent([String].self, forKey: .families)

    }
    
    func encode(to encoder: Encoder) throws { 
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.firstName, forKey: .firstName)
        try container.encodeIfPresent(self.bio, forKey: .bio)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.PhotoURL, forKey: .PhotoURL)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.profileImagePath, forKey: .profileImagePath)
        try container.encodeIfPresent(self.profileImagePathUrl, forKey: .profileImagePathUrl)
        try container.encodeIfPresent(self.families, forKey: .families)
    }
}

final class UserManager {
    static let shared = UserManager()
    private init() {}
    
//    private let endcoder: Firestore.Encoder = {
//        let encoder = Firestore.Encoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        return encoder
//    } ()
//
//    private let decoder: Firestore.Decoder = {
//        let decoder = Firestore.Decoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return decoder
//    } ()
    private let userCollection = Firestore.firestore().collection("users")
    
    func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    func createNewUser(user: DBuser) throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    func getUser(userId: String) async throws -> DBuser {
        try await userDocument(userId: userId).getDocument(as: DBuser.self)
    }
    func updateUser(user: DBuser) throws {
        try userDocument(userId: user.userId).setData(from: user, merge: true)
    }
    func updateUserField(userId: String, field : [String: Any])  {
        userDocument(userId: userId).updateData(field)
    }
    func searchUserWithFirstName(firstName: String) async throws -> QuerySnapshot{
        try await userCollection.whereField(DBuser.CodingKeys.firstName.rawValue, isEqualTo: firstName).getDocuments()
    }
//    func createNewUser(auth: AuthDataResultModel) async throws{
//        var userData: [String: Any] = [
//            "user_id" : auth.uid,
//            "user_name" : "guest",
//            "data_created" : Timestamp()
//        ]
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        if let photo = auth.photoURL {
//            userData["photo_URL"] = photo
//        }
//        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
//    }
//    func getUser(user_id: String) async throws -> DBuser {
//        let snapshot = try await Firestore.firestore().collection("users").document(user_id).getDocument()
//
//        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//        let email = data["email"] as? String
//        let date = data["data_created"] as? Date
//        let photoURL = data["photo_URL"] as? String
//        let name = data["user_name"] as? String
//
//        return DBuser(userId: userId, userName: name, email: email, PhotoURL: photoURL, dataCreated: date)
//    }
}
