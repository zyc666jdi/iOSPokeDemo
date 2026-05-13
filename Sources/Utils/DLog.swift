import Foundation

#if DEBUG
func DLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let output = items.map { "\($0)" }
                      .joined(separator: separator)
                      .replacingOccurrences(of: "\\n", with: "\n")
    print(output, terminator: terminator)
}
#else
func DLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {}
#endif
