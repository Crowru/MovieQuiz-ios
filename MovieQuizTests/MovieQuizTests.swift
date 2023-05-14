import XCTest

struct ArithmeticOperations {
    func addition(num1: Int, num2: Int) -> Int {
        return num1 + num2
    }
    
    func subtraction(num1: Int, num2: Int) -> Int {
        return num1 - num2
    }
    
    func multiplication(num1: Int, num2: Int) -> Int {
        return num1 * num2
    }
}

// Синхронные тесты
// Как вы могли заметить, функции наших арифметических операций — синхронные, то есть результат их выполнения известен сразу. При работе с синхронными функциями принято использовать методологию Given — When — Then:

class MovieQuizTests: XCTestCase {
    func testAddition() throws {
        // Given
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 1
        let num2 = 2
        
        // When
        let result = arithmeticOperations.addition(num1: num1, num2: num2)
        
        // Then
        XCTAssertEqual(result, 3) // сравниваем результат выполнения функции и наши ожидания
    }
    
    func testAdditionAsync() throws {
        // Given
        let arithmeticOperations = ArithmeticOperationsAsync()
        let num1 = 1
        let num2 = 2
        
        // When
        let expectation = expectation(description: "Addition function expectation")
        
        arithmeticOperations.addition(num1: num1, num2: num2) { result in
            // Then
            XCTAssertEqual(result, 3)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
}

// XCTAssertNotEqual — сравниваем два результата и ожидаем, что они не равны
// XCTAssertFalse — проверяем, что результат — это false
// XCTAssertTrue — проверяем, что результат — это true
// XCTAssertGreaterThan — сравниваем два результата и ожидаем, что первый больше второго
// XCTAssertGreaterThanOrEqual — сравниваем два результата и ожидаем, что первый больше или равен второму
// XCTAssertLessThan — сравниваем два результата и ожидаем, что первый меньше второго
// XCTAssertLessThanOrEqual — сравниваем два результата и ожидаем, что первый меньше или равен второму
// XCTAssertNil — проверяем что результат — это nil
// XCTAssertNotNil — проверяем что результат — это не nil
// XCTAssertNoThrow — проверяем, что в процессе получения результата не произошло ошибки
// XCTAssertThrowsError — проверяем, что в процессе получения результата произошла ошибка

// Асинхронные тесты

struct ArithmeticOperationsAsync {
    func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 + num2)
        }
    }
    
    func subtraction(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 - num2)
        }
    }
    
    func multiplication(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 * num2)
        }
    }
}

// Теперь наши функции возвращают результат асинхронно — через 1 секунду. Попробуем обновить тест, чтобы проверить функцию суммирования. Снова изменим ожидаемый результат на 4 и запустим его
