import Foundation

public enum EmailAddressValidator {
  
  public static func isValid(_ email: String) -> Bool {
    let atSplit = email.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "@")
    
    // Verify @ sign
    guard atSplit.count == 2 && !atSplit[0].isEmpty && !atSplit[1].isEmpty else {
      return false
    }
    
    // Verify valid username characters
    guard CharacterSet(charactersIn: atSplit[0]).isSubset(of: .urlUserAllowed) else {
      return false
    }
    
    // Verify valid domain characters
    guard CharacterSet(charactersIn: atSplit[1]).isSubset(of: .urlHostAllowed) else {
      return false
    }
    
    // Verify valid domain lengths
    let domainSplits = atSplit[1].split(separator: ".")
    guard domainSplits.count > 1 && domainSplits.allSatisfy({ !$0.isEmpty }) else {
      return false
    }
    
    return true
  }
}
