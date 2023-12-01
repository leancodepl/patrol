//
//  DispatchTimer.swift
//  Telegraph
//
//  Created by Yvo van Beek on 2/23/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

public final class DispatchTimer {
  private let interval: TimeInterval
  private let queue: DispatchQueue
  private let block: () -> Void
  private var timer: DispatchSourceTimer?

  /// Creates a dispatch timer.
  init(interval: TimeInterval = 0, queue: DispatchQueue, execute block: @escaping () -> Void) {
    self.interval = interval
    self.queue = queue
    self.block = block
  }

  /// (Re)starts the timer, next run at a specific date.
  func start(at startDate: Date) {
    stop()

    // Create a new timer
    timer = DispatchSource.makeTimerSource(queue: queue)
    timer?.setEventHandler(handler: block)

    // Schedule the timer to start at a specific time or after the interval
    let deadline = DispatchWallTime(date: startDate)

    if interval > 0 {
      timer?.schedule(wallDeadline: deadline, repeating: interval)
    } else {
      timer?.schedule(wallDeadline: deadline)
    }

    // Activate the timer
    timer?.resume()
  }

  /// (Re)starts the timer, next run will be immediately or after the interval.
  func start() {
    start(at: Date().addingTimeInterval(interval))
  }

  /// Stops the timer.
  func stop() {
    timer?.cancel()
    timer = nil
  }
}

// MARK: DispatchTimer convenience methods

public extension DispatchTimer {
  /// Creates and starts a timer that runs multiple times with a specific interval.
  static func run(interval: TimeInterval, queue: DispatchQueue, execute block: @escaping () -> Void) -> DispatchTimer {
    let timer = DispatchTimer(interval: interval, queue: queue, execute: block)
    timer.start()
    return timer
  }

  /// Creates and starts a timer that runs at a specfic data, optionally repeating with a specific interval.
  static func run(at: Date, interval: TimeInterval = 0, queue: DispatchQueue, execute block: @escaping () -> Void) -> DispatchTimer {
    let timer = DispatchTimer(interval: interval, queue: queue, execute: block)
    timer.start(at: at)
    return timer
  }
}

// MARK: DispatchWallTime convenience initializers

private extension DispatchWallTime {
  /// Creates a dispatch wall time from a date.
  init(date: Date) {
    let (seconds, frac) = modf(date.timeIntervalSince1970)
    let wallTime = timespec(tv_sec: Int(seconds), tv_nsec: Int(frac * Double(NSEC_PER_SEC)))
    self.init(timespec: wallTime)
  }
}
