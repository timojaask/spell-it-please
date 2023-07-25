import UIKit

final class CircularButton: UIButton {
    
    struct CircularButtonConfiguration {
        var image: UIImage
        var defaultBackgroundColor: UIColor
        var defaultForegroundColor: UIColor
        var highlightedBackgroundColor: UIColor
        var highlightedForegroundColor: UIColor
    }
    
    private let circularButtonConfiguration: CircularButtonConfiguration
    
    init(configuration: CircularButtonConfiguration) {
        self.circularButtonConfiguration = configuration
        super.init(frame: .zero)
        clipsToBounds = true
        
        self.configuration = UIButton.Configuration.gray()
        self.configuration?.image = circularButtonConfiguration.image
        isHighlighted = false // Setting inital value for isHighlighted will trigger isHighlighted.didSet that will set colors
    }
    
    override var isHighlighted: Bool {
        didSet {
            configuration?.baseBackgroundColor = isHighlighted ?
                circularButtonConfiguration.highlightedBackgroundColor :
                circularButtonConfiguration.defaultBackgroundColor
            
            configuration?.baseForegroundColor = isHighlighted ?
                circularButtonConfiguration.highlightedForegroundColor :
                circularButtonConfiguration.defaultForegroundColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // This is where we actually make the button circular.
        // The reason we have to do it in `layoutSubviews` is because this is the earliest
        // point in view's lifecycle where we know its width and height. And we need it
        // in order to set the cornerRadius.
        layer.cornerRadius = bounds.size.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Too lazy to support Storyboards
        fatalError("🤷‍♂️ Storyboard support not yet implemented 🤷‍♂️")
    }
}
