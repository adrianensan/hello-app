import Foundation

public extension URL {
  var isDirectory: Bool {
    (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
  }
  
  var dateCreated: Date? {
    (try? resourceValues(forKeys: [.creationDateKey]))?.creationDate
  }
  
  var dateModified: Date? {
    (try? resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
  }
  
  var dateAccessed: Date? {
    (try? resourceValues(forKeys: [.contentAccessDateKey]))?.contentAccessDate
  }
  
  func regularFileAllocatedSize() -> Int {
    guard let resourceValues = try? self.resourceValues(forKeys: [
      .isRegularFileKey,
      .totalFileSizeKey,
      .fileAllocatedSizeKey,
      .totalFileAllocatedSizeKey,
    ]),
          resourceValues.isRegularFile == true else { return 0 }
    
    return resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0
  }
  
  func fileSize() -> Int {
    guard let resourceValues = try? self.resourceValues(forKeys: [
      .isRegularFileKey,
      .totalFileSizeKey,
      .fileSizeKey,
    ]),
          resourceValues.isRegularFile == true else { return 0 }
    
    return resourceValues.totalFileSize ?? resourceValues.fileSize ?? 0
  }
}
