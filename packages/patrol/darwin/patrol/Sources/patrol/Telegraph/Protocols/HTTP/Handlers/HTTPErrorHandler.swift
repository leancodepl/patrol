//
//  HTTPErrorHandler.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/4/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public protocol HTTPErrorHandler {
  func respond(to error: Error) -> HTTPResponse?
}
