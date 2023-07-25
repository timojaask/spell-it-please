import UIKit

final class TableViewCell: UITableViewCell {
    static let reuseIdentifier = "TableViewCell"
    
    typealias OnCodeWordChangedHandler = (_ character: Character, _ newCodeWord: String) -> ()
    
    private var characterLabel: UILabel!
    private var codeWordTextField: UITextField!
    private var revertButton: CircularButton!
    
    private var character: Character!
    private var defaultCodeWord: String? = nil
    private var onCodeWordChangedHandler: OnCodeWordChangedHandler?
    
    private var revertButtonShouldBeVisible: Bool {
        codeWordTextField.isEditing && (codeWordTextField.text != defaultCodeWord)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setup(
        character: Character,
        codeWord: String?,
        defaultCodeWord: String?,
        onCodeWordChangedHandler: @escaping OnCodeWordChangedHandler
    ) {
        self.character = character
        self.defaultCodeWord = defaultCodeWord
        self.onCodeWordChangedHandler = onCodeWordChangedHandler
        characterLabel.text = "\(character.uppercased()) "
        codeWordTextField.text = codeWord ?? ""
        revertButton.isHidden = !revertButtonShouldBeVisible
    }
    
    func updateCodeWord(newCodeWord: String?) {
        codeWordTextField.text = newCodeWord
    }
    
    private func setupViews() {
        initCharacterLabel()
        initCodeWordTextField()
        initRevertButton()
        
        contentView.addSubview(characterLabel)
        contentView.addSubview(codeWordTextField)
        contentView.addSubview(revertButton)
        
        setupConstraints()
    }
    
    private func initCharacterLabel() {
        characterLabel = UILabel()
        characterLabel.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        characterLabel.textColor = .systemGray2
    }
    
    private func initCodeWordTextField() {
        codeWordTextField = UITextField()
        codeWordTextField.font = .systemFont(ofSize: 16, weight: .regular)
        codeWordTextField.returnKeyType = .done
        codeWordTextField.autocorrectionType = .no
        codeWordTextField.autocapitalizationType = .none
        codeWordTextField.spellCheckingType = .no
        codeWordTextField.inlinePredictionType = .no
        codeWordTextField.addTarget(self, action: #selector(onCodeWordTextFieldTextChanged(_:)), for: .editingChanged)
        codeWordTextField.addTarget(self, action: #selector(onCodeWordTextFieldDoneTapped(_ :)), for: .primaryActionTriggered)
        codeWordTextField.addTarget(self, action: #selector(onCodeWordTextFieldBeginEditing(_ :)), for: .editingDidBegin)
        codeWordTextField.addTarget(self, action: #selector(onCodeWordTextFieldEndEditing(_ :)), for: .editingDidEnd)
    }
    
    private func initRevertButton() {
        revertButton = CircularButton(configuration: CircularButton.CircularButtonConfiguration(
            image: UIImage(systemName: "arrow.uturn.backward.circle")!,
            defaultBackgroundColor: .revertButtonBackgroundDefault,
            defaultForegroundColor: .revertButtonForegroundDefault,
            highlightedBackgroundColor: .revertButtonBackgroundHighlighted,
            highlightedForegroundColor: .revertButtonForegroundHighlighted
        ))
        revertButton.isHidden = true
        revertButton.addTarget(self, action: #selector(onRevertButtonTapped(_ :)), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        // For any view that uses AutoLayout the translatesAutoresizingMaskIntoConstraints should be set to false
        characterLabel.translatesAutoresizingMaskIntoConstraints = false
        revertButton.translatesAutoresizingMaskIntoConstraints = false
        codeWordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // We need to tell AutoLayout which element takes the available space. In this case,
        // we want the code word text to take up as much space as there is, so setting its
        // "content hugging priority" to lower than the other two.
        characterLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        codeWordTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        revertButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            characterLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            characterLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            characterLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            revertButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            revertButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            revertButton.widthAnchor.constraint(equalToConstant: 40),
            revertButton.heightAnchor.constraint(equalTo: revertButton.widthAnchor),
            
            codeWordTextField.leadingAnchor.constraint(equalTo: characterLabel.trailingAnchor),
            codeWordTextField.trailingAnchor.constraint(equalTo: revertButton.leadingAnchor),
            codeWordTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    private func onCodeWordChanged(newCodeWord: String?) {
        // Notify the view controller that user has changed the code word for this character
        onCodeWordChangedHandler?(self.character, newCodeWord ?? "")
        // Check if we need to show or hide the revertButton
        revertButton.isHidden = !revertButtonShouldBeVisible
    }
}

extension TableViewCell {
    @objc private func onCodeWordTextFieldTextChanged(_ textField: UITextField) {
        onCodeWordChanged(newCodeWord: textField.text)
    }
    
    @objc private func onCodeWordTextFieldDoneTapped(_ textField: UITextField) {
        codeWordTextField.resignFirstResponder()
    }
    
    @objc private func onCodeWordTextFieldBeginEditing(_ textField: UITextField) {
        revertButton.isHidden = !revertButtonShouldBeVisible
    }
    
    @objc private func onCodeWordTextFieldEndEditing(_ textField: UITextField) {
        revertButton.isHidden = !revertButtonShouldBeVisible
    }
    
    @objc private func onRevertButtonTapped(_ button: UIButton) {
        codeWordTextField.text = self.defaultCodeWord
        onCodeWordChanged(newCodeWord: codeWordTextField.text)
    }
}
