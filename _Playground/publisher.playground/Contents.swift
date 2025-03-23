import UIKit
import Combine


let upstream = [1,2,3,4,5].publisher

let transformedStream = upstream.map { $0 * 3 }

// transformedStream에서 데이터를 가공해서 전달.

// ⭐️ Upstream은 Downstream이 구독(Subscribe)해야 동작한다. (lazy 방식)
let last = transformedStream.sink { value in
    print("stream tutorial : \(value)")
}

// Sequence Publisher - Array
[1,2,3].publisher
    .sink { completion in
        switch completion {
        case .finished:
            print("완료")
        case .failure(let error):
            print("에러 발생")
        }
    } receiveValue: { num in
        print(num)
    }

// Sequence Publisher - Set
Set([1,2,3]).publisher
    .sink { completion in
        switch completion {
        case .finished:
            print("완료")
        case .failure(let error):
            print("에러 발생")
        }
    } receiveValue: { num in
        print(num)
    }

// Sequence Publisher - Dictionary
["A" : 1, "B" : 2, "C" : 3].publisher
    .sink { key, value in
        print("key: ", key, "value: ", value)
    }

// Just - 값을 한 번만 방출하는 퍼블리셔
Just("Hi").sink { string in
    print(string)
}

Just(1)
    .sink { num in
        print(num)
    }

// Empty - 값을 하나도 방출 안하는 퍼블리셔
// completeImmediately 값이 false로 설정되어 있을 경우 finished 되지 않음.
//let emptyPublisher = Empty<Int, Never>() == Empty<Int, Never>(completeImmediately: true)
let emptyPublisher = Empty<Int, Never>(completeImmediately: false)

emptyPublisher.sink { completion in
    print(completion)
} receiveValue: { num in
    print(num)
}

// Fail - 무조건 에러를 발생시키는 퍼블리셔
// 값을 방출하지 않으며, 에러를 발생하는 완료를 한다.
enum MyError : Error {
    case myError
    case otherError
}

let failPublisher = Fail<Int, MyError>(error: .myError)

failPublisher.sink { completion in
    switch completion {
    case .finished:
        print("Fail Publisher not finished")
    case .failure(let error):
        print("Error : \(error)")
    }
} receiveValue: { num in
    print("Fail Publisher not emit value!")
}

//
func fetchSite() -> AnyPublisher<Data, URLError> {
    guard let url = URL(string: "https://www.naver.com") else {
        return Empty<Data, URLError>()
            .eraseToAnyPublisher()
    }
    
    let publisher = URLSession.shared.dataTaskPublisher(for: url)
        .map { (data: Data, response: URLResponse) in
            return data
        }
        .eraseToAnyPublisher()
    
    return publisher
}

let subscription = fetchSite()
    .sink { completion in
        switch completion {
        case .finished:
            print("완료")
        case .failure(let error):
            print("에러 발생")
        }
    } receiveValue: { data in
        print("\(data)")
    }


// Future - 클로저를 통해 일정 작업을 수행하고, 그 콜백을 단일 값으로 방출하고 싶을 때 사용.
// Future 퍼블리셔는 구독자가 있던없던 상관없이 내부 클로저를 실행한다.
// Deferred 퍼블리셔와 함께 사용해 lazy하게 만들 수 있다.
// 또한, Future 퍼블리셔의 경우 promise로 value나 error를 방출하면 finished 된다.
let futureData = Future<Data, Never> { promise in
    // 내부에 비동키 코드를 넣어 callback 함수를 구현할 수 있다.
    URLSession.shared.dataTask(with: URL(string: "https://www.naver.com")!) { data, response, error in
        if let data = data {
            promise(.success(data))
        }
    }
    .resume()
}
.sink { data in
    print("\(data)")
}

// deferred 활용 -> 구독자가 없을 경우 클로저는 실행이 안됨.
let deferredFutureData = Deferred {
    Future<Data, Never> { promise in
        // 내부에 비동키 코드를 넣어 callback 함수를 구현할 수 있다.
        URLSession.shared.dataTask(with: URL(string: "https://www.naver.com")!) { data, response, error in
            if let data = data {
                promise(.success(data))
            }
        }
        .resume()
    }
}

