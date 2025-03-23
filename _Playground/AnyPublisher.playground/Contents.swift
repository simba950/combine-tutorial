import UIKit
import Combine


//func publisher1() -> Publisher.Sequence<[Int], Never>
//{
//    let publisher = [1,2,3].publisher
//    return publisher
//}


func publisher1() -> AnyPublisher<[Int], Never>
{
    let publisher = [1,2,3].publisher
        .eraseToAnyPublisher()
    return publisher
}

// 내부 구현 과정 및 오퍼레이터에 따라 리턴 타입이 매번 바뀐다.
// 이와같은 불편한 상황을 고려해 AnyPublisher 타입을 사용한다.
//func publisher2() -> URLSession.DataTaskPublisher {
func publisher2() -> AnyPublisher<Data, URLError> {
    let publisher = URLSession.shared.dataTaskPublisher(for: URL(string: "https://www.naver.com"))
    // transform 방식
    //        .map { (data: Data, response: URLResponse) in
    //            return data
    //        }
    //        .map { (data: Data, response: URLResponse) in
    //            data
    //        }
    // keyPath 방식
        .map(\.data)
        .eraseToAnyPublisher()
    
    return publisher
}

