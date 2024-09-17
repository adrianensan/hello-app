import Foundation

private let htmlEntities = [
  "&amp;": "&",
  "%20": " ",
  "&#x20;": " ",
  "&AMP;": "&",
  "&#38;": "&",
  "&#038;": "&",
  // Equals =
  "&equals;": "=",
  "&#61;": "=",
  "&#061;": "=",
  // Plus +
  "&plus;": "+",
  "&#43;": "+",
  "&#043;": "+",
  "&num;": "#",
  "&#35;": "#",
  "&#035;": "#",
  "&#47;": "/",
  "&sol;": "/",
  "&bsol;": "\\",
  "&percnt;": "%",
  // Question Mark ?
  "&quest;": "?",
  "&#63;": "?",
  "&#063;": "?",
  "&dollar;": "$",
  // Quote "
  "&quot;": "\"",
  "&QUOT;": "\"",
  "&#34;": "\"",
  "&#034;": "\"",
  // Pipe
  "%7C": "|",
  // LT <
  "&lt;": "<",
  "&LT;": "<",
  "&#60;": "<",
  "&#060;": "<",
  // GT >
  "&gt;": ">",
  "&GT;": ">",
  "&#62;": ">",
  "&#062;": ">",
  // Dash -
  "&ndash;": "–",
  "&#8211;": "–",
  "&commat;": "@",
  "&period;": ".",
  "&NewLine;": "\n",
  "&Tab;": "  ",
  "&lpar;": "(",
  "&rpar;": ")",
  "&colon;": ":",
  "&#58;": ":",
  "&#058;": ":",
  "&semi;": ";",
  "&#59;": ";",
  "&#059;": ";",
  "<br>": "\n",
  "<br/>": "\n",
  "&ast;": "*",
  "&deg;": "°",
  "&Hat;": "^",
  "&hat;": "^",
  "&copy;": "©",
  "&comma;": ",",
  // Quote'
  "&apos;": "'",
  "&#39;": "'",
  "&#039;": "'",
  "&#8217;": "'",
]

private let charactersToHTMLEntities: [Character: String] = [
  "&": "&amp;",
  "#": "&num;",
  "\\": "&bsol;",
  "%": "&percnt;",
  "$": "&dollar;",
  "\"": "&quot;",
  "<": "&lt;",
  ">": "&gt;",
  "–": "&ndash;",
  "@": "&commat;",
  ";": "&semi;",
  "*": "&ast;",
  "°": "&deg;",
  "^": "&hat;",
  "©": "&copy;",
  "'": "&apos;",
]

private let htmlEntitiesTrie = Trie(valuesMap: htmlEntities)

public extension String {
  var addingHTMLEntities: String {
    var encodedString = ""
    for character in self {
      if let htmlEntity = charactersToHTMLEntities[character] {
        encodedString += htmlEntity
      } else {
        encodedString += String(character)
      }
    }
    return encodedString
  }
}

public extension StringProtocol {
  
  var removingHTMLEntities: String {
    var updatedString: [UInt8] = []
    var trieNode: Trie<String> = htmlEntitiesTrie
    var tempCharacters: [UInt8] = []
    let andVal = "&".utf8.first!
    for character in self.utf8 {
      if let updatedNode = trieNode.map[character] {
        if let replaceValue = updatedNode.value.first {
          if replaceValue == "&", let startNode = htmlEntitiesTrie.map[andVal] {
            tempCharacters = [andVal]
            trieNode = startNode
          } else {
            updatedString.append(contentsOf: replaceValue.utf8)
            tempCharacters = []
            trieNode = htmlEntitiesTrie
          }
        } else {
          trieNode = updatedNode
          tempCharacters.append(character)
        }
      } else {
        if !tempCharacters.isEmpty {
          trieNode = htmlEntitiesTrie
          updatedString.append(contentsOf: tempCharacters)
          tempCharacters = []
        }
        updatedString.append(character)
        tempCharacters = []
      }
    }
    
    return String(bytes: updatedString, encoding: .utf8) ?? ""
  }
}
