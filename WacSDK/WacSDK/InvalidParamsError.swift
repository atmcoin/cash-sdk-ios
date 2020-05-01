//
//  InvalidParamsError.swift
//  WacSDK
//
//  Created by David Fernandez on 2020-05-01.
//

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
