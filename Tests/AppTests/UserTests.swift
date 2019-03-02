@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
  
  func testUsersCanBeRetrievedFromAPI() throws {
    // revert
    let revertEnvironmentArgs = ["vapor", "revert", "--all", "-y"]
    
    var revertConfig = Config.default()
    var revertServices = Services.default()
    var revertEnv = Environment.testing
    revertEnv.arguments = revertEnvironmentArgs
    try App.configure(&revertConfig, &revertEnv, &revertServices)
    
    let revertApp = try Application(config: revertConfig, environment: revertEnv, services: revertServices)
    try App.boot(revertApp)
    try revertApp.asyncRun().wait()
    
    // migrate
    let migrateEnvironmentArgs = ["vapor", "migrate", "-y"]
    
    var migrateConfig = Config.default()
    var migrateServices = Services.default()
    var migrateEnvironment = Environment.testing
    migrateEnvironment.arguments = migrateEnvironmentArgs
    try App.configure(&migrateConfig, &migrateEnvironment, &migrateServices)
    
    let migrateApp = try Application(config: migrateConfig, environment: migrateEnvironment, services: migrateServices)
    try App.boot(migrateApp)
    try migrateApp.asyncRun().wait()
    
    // 1
    let expectedName = "Alice"
    let expectedUserName = "alice"
    
    // 2
    var config = Config.default()
    var services = Services.default()
    var env = Environment.testing
    try App.configure(&config, &env, &services)
    let app = try Application(config: config, environment: env, services: services)
    try App.boot(app)
    
    // 3
    let conn = try app.newConnection(to: .psql).wait()
    
    // 4
    let user = User(name: expectedName, description: expectedUserName)
    let savedUser = try user.save(on: conn).wait()
    
    _ = try User(name: "Luke", description: "luke").save(on: conn).wait()
    
    // 5
    let responder = try app.make(Responder.self)
    
    // 6
    let request = HTTPRequest(method: .GET, url: URL(string: "/api/users")!)
    let wrappedRequest = Request(http: request, using: app)
    
    // 7
    let response = try responder.respond(to: wrappedRequest).wait()
    
    // 8
    let data = response.http.body.data
    let users = try JSONDecoder().decode([User].self, from: data!)
    
    // 9
    XCTAssertEqual(users.count, 2)
    XCTAssertEqual(users[0].name, expectedName)
    XCTAssertEqual(users[0].description, expectedUserName)
    XCTAssertEqual(users[0].id, savedUser.id)
    
    // 10
    conn.close()
  }
  
}
