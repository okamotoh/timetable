import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var parentButton: UIButton!
    let tabbedSplitViewController = TabbedSplitViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func parentButtonTapped(sender: AnyObject) {
        self.navigationController?.pushViewController(tabbedSplitViewController, animated: true)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.LandscapeLeft.rawValue) | Int(UIInterfaceOrientationMask.LandscapeRight.rawValue)
    }
}


