import UIKit

final class ViewController: UIViewController {
    
    private var tableView: UITableView!
    private var userInputTextField: UITextField!
    private var copyButton: CircularButton!
    
    private let phoneticAlphabetConverter = PhoneticAlphabetConverter()
    
    /// This is the text that user enters into the text field, and also a data source for the table view
    private var userInput = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension ViewController {
    private func setupUI() {
        initializeUserInputTextField()
        initializeTableView()
        initializeCopyButton()

        view.addSubview(tableView)
        view.addSubview(userInputTextField)
        view.addSubview(copyButton)
        
        setupConstraints()
        
        view.backgroundColor = .inputBackground
    }
    
    private func initializeUserInputTextField() {
        userInputTextField = UITextField()
        userInputTextField.placeholder = "Enter text"
        userInputTextField.backgroundColor = .inputBackground
        userInputTextField.textColor = .inputForeground
        userInputTextField.borderStyle = .roundedRect
        userInputTextField.autocorrectionType = .no
        userInputTextField.autocapitalizationType = .none
        userInputTextField.spellCheckingType = .no
        userInputTextField.inlinePredictionType = .no
        userInputTextField.returnKeyType = .done
        userInputTextField.clearButtonMode = .always
        userInputTextField.borderStyle = .none
        userInputTextField.addTarget(self, action: #selector(onTextChanged(_:)), for: .editingChanged)
        userInputTextField.addTarget(self, action: #selector(onTextFieldDoneTapped(_:)), for: .primaryActionTriggered)
    }
    
    private func initializeTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.reuseIdentifier)
        tableView.keyboardDismissMode = .interactive
        tableView.allowsSelection = false
    }
    
    private func initializeCopyButton() {
        copyButton = CircularButton(configuration: CircularButton.CircularButtonConfiguration(
            image: UIImage(systemName: "doc.on.doc")!,
            defaultBackgroundColor: .systemBlue,
            defaultForegroundColor: .white,
            highlightedBackgroundColor: .white,
            highlightedForegroundColor: .systemBlue
        ))
        copyButton.addTarget(self, action: #selector(onCopyButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        // For any view that uses AutoLayout the translatesAutoresizingMaskIntoConstraints should be set to false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        userInputTextField.translatesAutoresizingMaskIntoConstraints = false
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: userInputTextField.topAnchor, constant: 0),
            
            userInputTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            userInputTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            userInputTextField.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: 0),
            userInputTextField.heightAnchor.constraint(equalToConstant: 50),
            
            copyButton.trailingAnchor.constraint(equalTo: userInputTextField.trailingAnchor, constant: 0),
            copyButton.bottomAnchor.constraint(equalTo: userInputTextField.topAnchor, constant: -8),
            copyButton.widthAnchor.constraint(equalToConstant: 50),
            copyButton.heightAnchor.constraint(equalTo: copyButton.widthAnchor)
        ])
    }
    
    @objc private func onTextFieldDoneTapped(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    @objc private func onTextChanged(_ textField: UITextField) {
        userInput = textField.text ?? ""
        tableView.reloadData()
        tableView.scrollToBottom()
    }
    
    @objc private func onCopyButtonTapped(_ button: CircularButton) {
        UIPasteboard.general.string = phoneticAlphabetConverter.getClipboardCopyableRepresentationOf(word: userInput)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(userInput).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseIdentifier, for: indexPath) as! TableViewCell
        
        let character = Array(userInput)[indexPath.row]
        let phoneticRepresentation = phoneticAlphabetConverter.convert(character)
        cell.setup(
            character: phoneticRepresentation.character,
            codeWord: phoneticRepresentation.codeWord,
            defaultCodeWord: phoneticRepresentation.defaultCodeWord,
            onCodeWordChangedHandler: { [weak self] character, newCodeWord in
                // First we want to save the user edited code word into our converter (and cache it)
                self?.phoneticAlphabetConverter.updateCodeWord(for: character, newCodeWord: newCodeWord)
                
                // Then we want to update any other table view cells that display the same
                // character, to make sure they are displaying the updated version of this code word.
                self?.updateTableViewCharacterWithNewCodeWord(character: character, newCodeWord: newCodeWord)
            }
        )
        
        return cell
    }
    
    private func updateTableViewCharacterWithNewCodeWord(character: Character, newCodeWord: String) {
        let characters = Array(userInput)
        
        for i in 0..<characters.count where characters[i] == character {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as? TableViewCell
            cell?.updateCodeWord(newCodeWord: newCodeWord)
        }
    }
}


