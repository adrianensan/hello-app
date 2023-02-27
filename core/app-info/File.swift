#if os(macOS)
import Foundation

func getSerialNumber() -> String {
  let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
  guard let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0) else { fatalError("Can not get serialNumberAsCFString") }
  IOObjectRelease(platformExpert);
  return (serialNumberAsCFString.takeUnretainedValue() as? String) ?? ""
}
#endif
