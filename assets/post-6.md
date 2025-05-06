---
title: "学习Swift"
date: 2025-04-22T02:01:58+05:30
description: "有想做的APP，所以我得先学一下Swift，跟着斯坦福CS193p打基础"
tags: [Note]
---
# lecture 1 assginment 1
1. 学习swift 6.1 的基础语法
### Control Flow
```swift
var optionalString: String? = "Hello"
print(optionalString == nil)
// Prints "false"


var optionalName: String? = "John Appleseed"
// means optionalName  either contain a String value or contain nil to idicate that a value is missing
//This creates an optional String variable named optionalName and sets its initial value to 'John Appleseed'.
var greeting = "Hello!"
if let name = optionalName {
    greeting = "Hello, \(name)"
}
//swift里的switch不会进入下一个case 掉进一个case之后会自动退出 【no implicit fallthrough】，但是我们C里需要break！！
```
### Functions
```swift
// functions are a first-class type
func makeIncrementer()->((Int)->Int){
    func addOne(number:Int)->Int{
        return 1+number
    }
    return addOne
}
var increment =makeIncrementer()
increment(7)

```
```swift
numbers.map({ (number: Int) -> Int in
    let result = 3 * number
    return result
})

//either
let mappedNumbers=numbers.map({number in 3*number})
```

```swift
let sortedNumbers = numbers.sorted { $0 > $1 }
print(sortedNumbers)
```
### Classes
```swift
class NamedShape {
    var numberOfSides: Int = 0
    var name: String

    init(name: String) {
       self.name = name
    }

    func simpleDescription() -> String {
       return "A shape with \(numberOfSides) sides."
    }
}

class Square: NamedShape {
    var sideLength: Double


    init(sideLength: Double, name: String) {
        self.sideLength = sideLength
        super.init(name: name) //initialize the superclass
        numberOfSides = 4
    }//let test = Square(sideLength: 5.2, name: "my test square")


    func area() -> Double {
        return sideLength * sideLength
    }


    override func simpleDescription() -> String {
        return "A square with sides of length \(sideLength)."
    }
}

class EquilateralTriangle: NamedShape {
    var sideLength: Double = 0.0


    init(sideLength: Double, name: String) {
        self.sideLength = sideLength
        super.init(name: name)
        numberOfSides = 3
    }

    var perimeter: Double {
        get {
             return 3.0 * sideLength
        }
        set {
            sideLength = newValue / 3.0
        }
    }/*用法：print(triangle.perimeter)
triangle.perimeter = 9.9
print(triangle.sideLength)*/


    override func simpleDescription() -> String {
        return "An equilateral triangle with sides of length \(sideLength)."
    }
}


class TriangleAndSquare {
    var triangle: EquilateralTriangle {
        willSet {//在创建新的triangle之前 ，newValue是默认的临时创建的值的名字
            square.sideLength = newValue.sideLength
        }
    }
    var square: Square {
        willSet {
            triangle.sideLength = newValue.sideLength
        }
    }
    init(size: Double, name: String) {
        square = Square(sideLength: size, name: name)
        triangle = EquilateralTriangle(sideLength: size, name: name)
    }
}

//optionalSquare 可以存Square值也可以是nil，这里初始化为Square(sideLength: 2.5, name: "optional square")实例，但是之后可以操作为nil
let optionalSquare: Square? = Square(sideLength: 2.5, name: "optional square")
//如果optionalSquare 是 nil，直接赋值sideLength为nil。反之访问.sideLength
let sideLength = optionalSquare?.sideLength

```
### Enumerations and Struct 
```swift
enum Rank: Int {
    case ace = 1//和C++一样本来rawValue默认从0开始，但这里自己设置了1
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king


    func simpleDescription() -> String {
        switch self {
        case .ace:
            return "ace"
        case .jack:
            return "jack"
        case .queen:
            return "queen"
        case .king:
            return "king"
        default:
            return String(self.rawValue)
        }
    }
}
let ace = Rank.ace
let aceRawValue = ace.rawValue
```
```swift
enum ServerResponse {
    case result(String, String)
    case failure(String)
}

// have values associated with the case
let success = ServerResponse.result("6:00 am", "8:09 pm")
let failure = ServerResponse.failure("Out of cheese.")
//开始匹配
switch success {
case let .result(sunrise, sunset):
    print("Sunrise is at \(sunrise) and sunset is at \(sunset).")
case let .failure(message):
    print("Failure...  \(message)")
}
```
One of the most important differences between structures and classes is that structures are always copied when they’re passed around in your code, but classes are passed by reference

### Generics
```swift
func anyCommonElements<T: Sequence, U: Sequence>(_ lhs: T, _ rhs: U) -> Bool//T 和 U 都是满足Sequence
    where T.Element: Equatable, T.Element == U.Element// T的元素要可以比较 T和U的元素是一样的类型
```