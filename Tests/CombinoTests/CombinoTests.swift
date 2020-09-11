import XCTest
import Combine
@testable import Combino

final class CombinoTests: XCTestCase {
    var bag = Set<AnyCancellable>()
    
    override func setUp() {
        bag = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        bag.forEach { $0.cancel() }
    }
    
    func testCombinoDo() {
        var isLooping = true
        
        Combino
            .do(withDelay: 5)
            .sink(.success { isLooping = false })
            .store(in: &bag)
        
        while isLooping {
            print("still looping")
        }
        
        XCTAssert(true)
    }
    
    func testCombinoDo_success() {
        let sema = DispatchSemaphore(value: 0)
        
        Combino
            .do(withDelay: 5) {
                "Hello World!"
        }
        .sink {
            [
                .completion {
                    sema.signal()
                },
                .success { value in
                    XCTAssertEqual(value, "Hello World!")
                },
                .failure { _ in
                    XCTAssert(false)
                }
            ]
        }
        .store(in: &bag)
        
        
        sema.wait()
    }
    
    func testCombinoDo_failure() throws {
        let sema = DispatchSemaphore(value: 0)
        
        Combino
            .do(withDelay: 5) {
                throw NSError(domain: "Combino", code: -1, userInfo: nil)
        }
        .sink {
            [
                .failure { _ in
                    XCTAssert(true)
                },
                .completion {
                    sema.signal()
                },
                .success {
                    XCTAssert(true)
                }
            ]
        }
        .store(in: &bag)
        
        sema.wait()
    }
    
    func testFetch() {
        let sema = DispatchSemaphore(value: 0)
        
        Combino
            .fetch(url: URL(string: "https://avatars0.githubusercontent.com/u/8268288?s=460&u=2cb09673ea7f5230fa929b9b14a438cb2a65751c&v=4")!)
            .sink {
                [
                    .failure { _ in
                        XCTAssert(true)
                    },
                    .completion {
                        sema.signal()
                    },
                    .success { _ in
                        XCTAssert(true)
                    }
                ]
        }
        .store(in: &bag)
        
        sema.wait()
    }
    
    func testPost_success() {
        let sema = DispatchSemaphore(value: 0)
        
        Combino
            .post(url: URL(string: "https://postman-echo.com/post")!) {
                "Some Data".data(using: .utf8)!
        }
            
        .sink {
            [
                .failure { _ in
                    XCTAssert(true)
                },
                .completion {
                    sema.signal()
                },
                .success { _ in
                    XCTAssert(true)
                }
            ]
        }
        .store(in: &bag)
        
        sema.wait()
    }
    
    func testPost_failure() {
        let sema = DispatchSemaphore(value: 0)
        
        Combino
            .post(url: URL(string: "https://github/0xLeif/Later")!)
            .sink {
                [
                    .failure { _ in
                        XCTAssert(true)
                    },
                    .completion {
                        sema.signal()
                    },
                    .success { _ in
                        XCTAssert(true)
                    }
                ]
        }
        .store(in: &bag)
        
        sema.wait()
    }
}
