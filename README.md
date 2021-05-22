# Combino

## ⚠️ Development has been moved to [Task](https://github.com/0xLeif/Task)

### promise
```swift
promise<T>(work: @escaping (@escaping Future<T, Error>.Promise) -> Void) -> Future<T, Error>

promise(work: @escaping (@escaping Future<Void, Error>.Promise) -> Void) -> Future<Void, Error>
```

### do
```swift
do<T>(withDelay delay: UInt32 = 0,
                               work: @escaping () throws -> T) -> Future<T, Error>

do(withDelay delay: UInt32 = 0,
                            work: @escaping () throws -> Void = {}) -> Future<Void, Error>
```

### main
```swift
main<T>(withDelay delay: UInt32 = 0,
                               work: @escaping () throws -> T) -> Future<T, Error>

main(withDelay delay: UInt32 = 0,
                            work: @escaping () throws -> Void = {}) -> Future<Void, Error>
```

### fetch
```swift
fetch(url: URLRequest) -> Future<(Data?, URLResponse?), Error>

fetch(url: URL) -> Future<(Data?, URLResponse?), Error>
```

### post
```swift
post(request: URLRequest) -> Future<(Data?, URLResponse?), Error>

post(url: URL, withData data: (() -> Data)? = nil) -> Future<(Data?, URLResponse?), Error>
```

## Combino Examples

### .sink(SinkEvent)
```swift
Combino
    .do(withDelay: 5)
    .sink(.success { someFunction() })
    .store(in: &bag)
```

### .sink(() -> [SinkEvent])
```swift
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
```
