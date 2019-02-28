import Vapor

struct UsersController: RouteCollection {
  
  func boot(router: Router) throws {
    let usersRouter = router.grouped("api", "users")
    
    usersRouter.post(User.self, use: createHandler)
    usersRouter.get(use: getAllHandler)
    usersRouter.get(User.parameter, use: getHandler)
    usersRouter.get(User.parameter, "acronyms", use: getAcronymsHandler)
  }
  
  func createHandler(_ req: Request, user: User) throws -> Future<User> {
    return user.save(on: req)
  }
  
  func getAllHandler(_ req: Request) throws -> Future<[User]> {
    return User.query(on: req).all()
  }
  
  func getHandler(_ req: Request) throws -> Future<User> {
    return try req.parameters.next(User.self)
  }
  
  func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
    return try req.parameters.next(User.self)
      .flatMap { try $0.acronyms.query(on: req).all() }
  }
  
}
