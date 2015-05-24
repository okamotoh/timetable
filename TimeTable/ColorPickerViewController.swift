import UIKit

class ColorPickerViewController: UIViewController {
    
    let buttonSize = CGSizeMake(44.2, 33)
    let buttonGap  = CGSizeMake(5.0, 5.0)
    var pallet = true
    var buttons: [ColorPickerButton] = []
    var selectedButton: ColorPickerButton?
    let colors: [[UIColor]] = [
        [
            UIColor(red: 178/255, green: 223/255, blue: 234/255, alpha: 255/255),
            UIColor(red: 117/255, green: 191/255, blue: 213/255, alpha:255/255),
            UIColor(red: 67/255, green: 163/255, blue: 194/255, alpha: 255/255),
            UIColor(red: 54/255, green: 137/255, blue: 174/255, alpha: 255/255),
            UIColor(red: 44/255, green: 116/255, blue: 155/255, alpha: 255/255)
        ],
        [
            UIColor(red: 231/255, green: 241/255, blue: 191/255, alpha: 255/255),
            UIColor(red: 208/255, green: 230/255, blue: 138/255, alpha:255/255),
            UIColor(red: 187/255, green: 215/255, blue: 91/255, alpha: 255/255),
            UIColor(red: 167/255, green: 202/255, blue: 54/255, alpha: 255/255),
            UIColor(red: 148/255, green: 189/255, blue: 25/255, alpha: 255/255)
        ],
        [
            UIColor(red: 250/255, green: 235/255, blue: 193/255, alpha: 255/255),
            UIColor(red: 245/255, green: 214/255, blue: 136/255, alpha:255/255),
            UIColor(red: 240/255, green: 196/255, blue: 86/255, alpha: 255/255),
            UIColor(red: 236/255, green: 176/255, blue: 44/255, alpha: 255/255),
            UIColor(red: 231/255, green: 158/255, blue: 38/255, alpha: 255/255)
        ],
        [
            UIColor(red: 235/255, green: 186/255, blue: 214/255, alpha: 255/255),
            UIColor(red: 217/255, green: 125/255, blue: 179/255, alpha:255/255),
            UIColor(red: 199/255, green: 77/255, blue: 147/255, alpha: 255/255),
            UIColor(red: 182/255, green: 38/255, blue: 118/255, alpha: 255/255),
            UIColor(red: 166/255, green: 33/255, blue: 95/255, alpha: 255/255)
        ],
        [
            UIColor(red: 207/255, green: 209/255, blue: 232/255, alpha: 255/255),
            UIColor(red: 166/255, green: 169/255, blue: 207/255, alpha:255/255),
            UIColor(red: 130/255, green: 133/255, blue: 184/255, alpha: 255/255),
            UIColor(red: 100/255, green: 104/255, blue: 162/255, alpha: 255/255),
            UIColor(red: 75/255, green: 78/255, blue: 141/255, alpha: 255/255)
        ],
        [
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 255/255),
            UIColor(red: 186/255, green: 186/255, blue: 186/255, alpha:255/255),
            UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha: 255/255),
            UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 255/255),
            UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 255/255)
        ]

    ]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if pallet {
            var x: CGFloat = 0.0
            for row in self.colors {
                var y: CGFloat = 0.0
                for color in row {
                    let button = ColorPickerButton(color: color, frame: CGRectMake(x, y, buttonSize.width, buttonSize.height))
                    button.addTarget(self, action: "colorButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
                    self.view.addSubview(button)
                    
                    self.buttons.append(button)
                    y += buttonSize.height + buttonGap.height
                }
                x += buttonSize.width + buttonGap.width
            }
        }
    }
    
    func setSelectedColor(color: UIColor) -> Void {
        for var i = 0; i < self.buttons.count; i++ {
            if CGColorEqualToColor(color.CGColor, self.buttons[i].backgroundColor?.CGColor) {
                selectedButton = self.buttons[i]
                if let button = selectedButton {
                    button.selected = true
                }
            } else {
                self.buttons[i].selected = false
            }
        }
    }

    func colorButtonTapped(sender: ColorPickerButton) {
        if let selected = selectedButton {
            selected.selected = false
        }
        sender.selected = true
        selectedButton = sender
    }

}
