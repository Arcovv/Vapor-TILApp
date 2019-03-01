import FluentPostgreSQL
import struct Foundation.UUID

final class AcronymCategoryPivot: PostgreSQLUUIDPivot {
  var id: UUID?
  
  var acronymID: Acronym.ID
  var categoryID: Category.ID
  
  typealias Left = Acronym
  typealias Right = Category
  
  static let leftIDKey: LeftIDKey = \.acronymID
  static let rightIDKey: RightIDKey = \.categoryID
  
  init(_ acronym: Acronym, _ category: Category) throws {
    self.acronymID = try acronym.requireID()
    self.categoryID = try category.requireID()
  }
}

extension AcronymCategoryPivot: Migration {
  static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: conn) { builder in
      try addProperties(to: builder)
      builder.reference(from: \.acronymID, to: \Acronym.id, onDelete: .cascade)
      builder.reference(from: \.categoryID, to: \Category.id, onDelete: .cascade)
    }
  }
}
extension AcronymCategoryPivot: ModifiablePivot { }
