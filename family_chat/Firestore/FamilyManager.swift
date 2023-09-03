//
//  FamilyManager.swift
//  family_chat
//
//  Created by Joel Tesfaye on 17/08/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBFamily: Codable, Hashable {
    let familyId: String
    let familyName: String
    let motto: String?
    let profilePhotoPath: String?
    let profilePhotoPathUrl: String?
    let members: [String]?
    let owner: String
    
    init(family: DBFamily) {
        familyId = family.familyId
        familyName = family.familyName
        motto = family.motto
        profilePhotoPath = family.profilePhotoPath
        profilePhotoPathUrl = family.profilePhotoPathUrl
        members = family.members
        owner = family.owner
    }
    init(familyId: String, familyName: String, owner: String, motto: String?,  profilePhotoPath: String?, profilePhotoPathUrl: String?, members: [String]?) {
        self.familyId = familyId
        self.familyName = familyName
        self.owner = owner
        self.motto = motto
        self.profilePhotoPath = profilePhotoPath
        self.profilePhotoPathUrl = profilePhotoPathUrl
        self.members = members
    }
    
    enum CodingKeys: String, CodingKey {
        case familyId = "family_id"
        case familyName = "family_name"
        case motto = "motto"
        case profilePhotoPath = "profile_photo_path"
        case profilePhotoPathUrl = "profile_photo_path_url"
        case members = "members"
        case owner = "owner"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.familyId, forKey: .familyId)
        try container.encode(self.familyName, forKey: .familyName)
        try container.encode(self.motto, forKey: .motto)
        try container.encode(self.profilePhotoPath, forKey: .profilePhotoPath)
        try container.encode(self.profilePhotoPathUrl, forKey: .profilePhotoPathUrl)
        try container.encode(self.members, forKey: .members)
        try container.encode(self.owner, forKey: .owner)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.familyId = try container.decode(String.self, forKey: .familyId)
        self.familyName = try container.decode(String.self, forKey: .familyName)
        self.motto = try container.decode(String.self, forKey: .motto)
        self.profilePhotoPath = try container.decode(String.self, forKey: .profilePhotoPath)
        self.profilePhotoPathUrl = try container.decode(String.self, forKey: .profilePhotoPathUrl)
        self.members = try container.decode([String].self, forKey: .members)
        self.owner = try container.decode(String.self, forKey: .owner)
    }
    
}

final class FamilyManager {
    static var shared = FamilyManager()
    
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("Families")
    
    func userDocument(familyId: String) -> DocumentReference {
        userCollection.document(familyId)
    }
    
    func createFamily(family: DBFamily) throws {
        try userDocument(familyId: family.familyId).setData(from: family, merge: false)
    }
    
    func getFamilies(familyId: String) async throws -> DBFamily {
       try await userDocument(familyId: familyId).getDocument(as: DBFamily.self)
    }
    
    func updateFamily(family: DBFamily) throws {
        try userDocument(familyId: family.familyId).setData(from: family, merge: true)
    }
    
    func updateFamily(field: [String: Any], familyId: String) {
         userDocument(familyId: familyId).updateData(field)
    }
}
