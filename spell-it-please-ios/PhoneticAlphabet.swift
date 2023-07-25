import Foundation

final class AlphabetCache {
    private static let userDefaultsKey = "AlphabetCache"
    
    func load() -> [Character: String]? {
        // UserDefaults doesn't support types such as `Character`, so we had to save it as [String: String] and when loading convert back to [Character: String]
        guard let cached = UserDefaults.standard.dictionary(forKey: AlphabetCache.userDefaultsKey) as? [String: String] else {
            return nil
        }
        var result = [Character: String]()
        for (key, value) in cached {
            result[Character(key)] = value
        }
        return result
    }
    
    func save(_ alphabet: [Character: String]) {
        // UserDefaults doesn't support types such as `Character`, so we have to save it as [String: String]
        Task {
            var converted = [String: String]()
            for (key, value) in alphabet {
                converted[String(key)] = value
            }
            UserDefaults.standard.set(converted, forKey: AlphabetCache.userDefaultsKey)
        }
    }
}

struct PhoneticRepresentation {
    var character: Character
    var codeWord: String?
    var defaultCodeWord: String?
}

final class PhoneticAlphabetConverter {
    
    private let cache = AlphabetCache()
    private var currentAlphabet: [Character: String]
    
    init() {
        if let savedAlphabet = cache.load() {
            currentAlphabet = savedAlphabet
        } else {
            currentAlphabet = PhoneticAlphabetConverter.defaultAlphabet
        }
    }
    
    func convert(_ character: Character) -> PhoneticRepresentation {
        let normalized = Character(character.lowercased())
        return PhoneticRepresentation(
            character: character,
            codeWord: currentAlphabet[normalized],
            defaultCodeWord: PhoneticAlphabetConverter.defaultAlphabet[normalized]
        )
    }
    
    func updateCodeWord(for character: Character, newCodeWord: String) {
        currentAlphabet[character] = newCodeWord
        cache.save(currentAlphabet)
    }
    
    func getClipboardCopyableRepresentationOf(word: String) -> String {
        Array(word).reduce(into: "") { partialResult, character in
            let phoneticRepresentation = self.convert(character)
            partialResult.append("\(character.uppercased()): \(phoneticRepresentation.codeWord ?? "")\n")
        }
    }
    
    static let defaultAlphabet: [Character: String] = [
        " ": "",
        "!": "Exclamation mark",
        "\"": "Quotation mark",
        "#": "Hash / Number sign",
        "$": "Dollar sign",
        "%": "Percent sign",
        "&": "Ampersand",
        "'": "Apostrophe",
        "(": "Left/Opening parenthesis",
        ")": "Right/Closing parenthesis",
        "*": "Asterisk",
        "+": "Plus sign",
        ",": "Comma",
        "-": "Hyphen",
        ".": "Period",
        "/": "Slash",
        "0": "Zero",
        "1": "One",
        "2": "Two",
        "3": "Three",
        "4": "Four",
        "5": "Five",
        "6": "Six",
        "7": "Seven",
        "8": "Eight",
        "9": "Nine",
        ":": "Colon",
        ";": "Semicolon",
        "<": "Less-than sign",
        "=": "Equal sign",
        ">": "Greater-than sign",
        "?": "Question mark",
        "@": "At sign",
        // Skipping all the capital A-Z letters, because we use lowercase and they are the same code word anyway.
        // ...
        "[": "Left/Opening square bracket",
        "\\": "Backslash",
        "]": "Right/Closing square bracket",
        "^": "Caret / Circumflex accent",
        "_": "Low line",
        "`": "Backtick / Grave accent",
        "a": "Alfa",
        "b": "Bravo",
        "c": "Charlie",
        "d": "Delta",
        "e": "Echo",
        "f": "Foxtrot",
        "g": "Golf",
        "h": "Hotel",
        "i": "India",
        "j": "Juliett",
        "k": "Kilo",
        "l": "Lima",
        "m": "Mike",
        "n": "November",
        "o": "Oscar",
        "p": "Papa",
        "q": "Quebec",
        "r": "Romeo",
        "s": "Sierra",
        "t": "Tango",
        "u": "Uniform",
        "v": "Victor",
        "w": "Whiskey",
        "x": "Xray",
        "y": "Yankee",
        "z": "Zulu",
        "{": "Left/Opening curly bracket",
        "|": "Vertical bar",
        "}": "Right/Closing curly bracket",
        "~": "Tilde",
        // Skipping some less common characters from now on without warning
        "£": "Pound sign",
        "¥": "Yen sign",
        "§": "Section sign / Silcrow",
        "©": "Copyright symbol",
        "®": "Registered trademark symbol",
        "°": "Degree sign",
        "²": "Superscript two",
        "³": "Superscript three",
        "´": "Acute accent",
        "µ": "Micro sign",
        "·": "Middle dot",
        "¹": "Superscript one",
        "–": "En dash",
        "—": "Em dash",
        "―": "Horizontal bar",
        "•": "Bullet",
        "“": "Left double quotation mark",
        "”": "Right double quotation mark",
        "’": "Single quotation mark",
        "€": "Euro sign"
    ]
}
