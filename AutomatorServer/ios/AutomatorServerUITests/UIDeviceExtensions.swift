//import Foundation
//import UIKit
//
//extension UIDevice {
//  func wifiIPAddress() -> String? {
//    var interfaces: UnsafeMutablePointer<UnsafeMutablePointer<ifaddrs>?>? = nil;
//    var tempAddr: UnsafeMutablePointer<UnsafeMutablePointer<ifaddrs>?>? = nil;
//    let success = getifaddrs(interfaces)
//    if success != 0 {
//      freeifaddrs(interfaces?.pointee)
//      return nil
//    }
//
//    var address: String? = nil;
//    tempAddr = interfaces;
//    while (tempAddr != nil) {
//      if (tempAddr!.pointee!.pointee.ifa_addr.pointee.sa_family != AF_INET) {
//        let a: UnsafeMutablePointer<ifaddrs>? = UnsafeMutablePointer(tempAddr!.pointee!.pointee.ifa_next);
//        let b: UnsafeMutablePointer<UnsafeMutablePointer<ifaddrs>?>? = UnsafeMutablePointer(a);
//        //tempAddr = a;
//      }
//    }
//  }
//}
