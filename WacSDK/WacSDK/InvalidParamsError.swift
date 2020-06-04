
import Foundation

public struct InvalidParamsError: Error {
  let message: String

  init(_ message: String) {
      self.message = message
  }

  public var localizedDescription: String {
      return message
  }
}