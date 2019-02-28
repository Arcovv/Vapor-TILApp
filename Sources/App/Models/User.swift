import Foundation
import Vapor
import FluentPostgreSQL

final class User: Codable {
  var id: UUID?
  var name: String
  var description: String
  
  init(name: String, description: String) {
    self.name = name
    self.description = description
  }
}

extension User: PostgreSQLUUIDModel { }
extension User: Content { }
extension User: Migration { }
extension User: Parameter { }

extension User {
  var acronyms: Children<User, Acronym> {
    return children(\.userID)
  }
}
