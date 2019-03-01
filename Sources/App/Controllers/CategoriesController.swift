import Vapor

struct CategoriesController: RouteCollection {
  
  func boot(router: Router) throws {
    let categoriesRoute = router.grouped("api", "categories")
    
    categoriesRoute.get(use: getAllHandler)
    categoriesRoute.get(Category.parameter, use: getHandler)
    categoriesRoute.post(Category.self, use: createHandler)
    categoriesRoute.get(Category.parameter, "acronyms", use: getAcronyms)
  }
  
  func getAllHandler(_ req: Request) throws -> Future<[Category]> {
    return Category.query(on: req).all()
  }
  
  func getHandler(_ req: Request) throws -> Future<Category> {
    return try req.parameters.next(Category.self)
  }
  
  func createHandler(_ req: Request, category: Category) throws -> Future<Category> {
    return category.save(on: req)
  }
  
  func getAcronyms(_ req: Request) throws -> Future<[Acronym]> {
    return try req.parameters.next(Category.self)
      .flatMap { try $0.acronyms.query(on: req).all() }
  }
  
}
