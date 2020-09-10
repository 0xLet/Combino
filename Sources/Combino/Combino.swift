import Foundation
import Combine

public class Combino {
    @discardableResult
    public static func `do`<T>(withDelay delay: UInt32 = 0,
                               work: @escaping () throws -> T) -> Future<T, Error> {
        Future { promise in
            DispatchQueue.global().async {
                sleep(delay)
                do {
                    promise(.success(try work()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    @discardableResult
    public static func `do`(withDelay delay: UInt32 = 0,
                            work: @escaping () throws -> Void) -> Future<Void, Error> {
        Future { promise in
            DispatchQueue.global().async {
                sleep(delay)
                do {
                    promise(.success(try work()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    @discardableResult
    public static func main<T>(withDelay delay: UInt32 = 0,
                               work: @escaping () throws -> T) -> Future<T, Error> {
        Future { promise in
            sleep(delay)
            DispatchQueue.main.async {
                do {
                    promise(.success(try work()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    @discardableResult
    public static func `repeat`(withDelay delay: TimeInterval = 0,
                                on runLoop: RunLoop = .current,
                                in runLoopMode: RunLoop.Mode = .common) -> Timer.TimerPublisher {
        Timer.publish(every: delay,
                      on: runLoop,
                      in: runLoopMode)
    }
}

public class Contract<Value> {
    public enum ContractError: Error {
        case resigned
    }
    
    private var isValid = true
    private var promise: ((Result<Value?, Error>) -> Void)?
    private var task: AnyCancellable?
    
    private var onResign: ((Value?) -> Void)?
    private var onChange: ((Value?) -> Void)?
    
    public var value: Value? {
        didSet {
            promise?(.success(value))
        }
    }
    
    public init(initialValue: Value? = nil,
                onResignHandler: ((Value?) -> Void)? = nil,
                onChangeHandler: ((Value?) -> Void)? = nil) {
        onResign = onResignHandler
        onChange = onChangeHandler
        value = initialValue
        start()
        promise?(.success(value))
    }
    
    @discardableResult
    public func onChange(onChangeHandler: ((Value?) -> Void)? = nil) -> Self {
        onChange = onChangeHandler
        
        return self
    }
    
    @discardableResult
    public func onResign(onResignHandler: ((Value?) -> Void)? = nil) -> Self {
        onResign = onResignHandler
        
        return self
    }
    
    public func resign() {
        guard isValid else {
            return
        }
        
        isValid = false
        
        onResign?(value)
        promise?(.failure(ContractError.resigned))
        
        promise = nil
        onChange = nil
        value = nil
    }
    
    private func start() {
        guard isValid else {
            return
        }
        
        task = Future { (promise) in
            self.promise = promise
        }
        .sink(receiveCompletion: {_ in}) { [weak self] (value) in
            self?.onChange?(value)
            self?.start()
        }
    }
}
