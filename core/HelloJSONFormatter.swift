import Foundation

public enum HelloJSONFormatter {
  public static func format(_ jsonString: String) -> String {
    let indentMode = "  "
    var currentIndent = ""
    var formattedJSON = ""
    var cancelNext = false
    var isQuoted = false
    var last: Character?
    for character in jsonString {
      if isQuoted {
        formattedJSON.append(character)
        switch character {
        case "\"":
          if !cancelNext {
            isQuoted = false
          }
          cancelNext = false
        case "\\":
          cancelNext = true
        default:
          cancelNext = false
        }
      } else {
        switch character {
        case "{", "[":
          formattedJSON.append(character)
          currentIndent += indentMode
          formattedJSON += "\n" + currentIndent
        case "\"":
          formattedJSON.append(character)
          isQuoted = true
        case ",":
          formattedJSON.append(character)
          formattedJSON += "\n" + currentIndent
        case ":":
          formattedJSON += ": "
        case "}", "]":
          currentIndent.deleteSuffix(indentMode)
          if last == "[" || last == "{" {
            formattedJSON = formattedJSON.trimmingCharacters(in: .whitespacesAndNewlines)
          } else {
            formattedJSON += "\n" + currentIndent
          }
          formattedJSON.append(character)
        case " ", "\n":
          break
        default:
          formattedJSON.append(character)
        }
      }
      last = character
    }
    return formattedJSON
  }
}
