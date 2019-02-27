import Vapor

struct UsersController: RouteCollection {
  
  func boot(router: Router) throws {
    let usersRouter = router.grouped("api", "users")
    usersRouter.post(User.self, use: createHandler)
  }
  
  func createHandler(_ req: Request, user: User) throws -> Future<User> {
    return user.save(on: req)
  }
  
}
