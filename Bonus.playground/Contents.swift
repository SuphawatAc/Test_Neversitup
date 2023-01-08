import UIKit

func fibonacci(n: Int) -> [Int] {
//Fn = Fn-1 + Fn-2
    assert(n > 1)

    var array = [0, 1]

    while array.count < n {
        
        array.append(array[array.count - 1] + array[array.count - 2])

    }
    return array
}


func isPrime(_ number: Int) -> Bool {
    if number <= 1 {
        return false
    }
    for i in 2..<number {
        if number % i == 0 {
            return false
        }
    }
    return true
}

func generatePrimes(upTo number: Int) -> [Int] {
    var primes = [Int]()
    for i in 2...number {
        if isPrime(i) {
            primes.append(i)
        }
    }
    return primes
}

let upperBound = 100
let primes = generatePrimes(upTo: upperBound)


print(fibonacci(n: 20))
print(primes)

var dataArray = [Int]()
fibonacci(n: 20).forEach{i in
    if primes.contains(i) {
        print(i)
        dataArray.append(i)
    }
    
}
print(dataArray)





