
import UIKit
import CoreMotion

class SkipController: UIViewController {
    
    var minimumSkippingAcceleration = 2.0
    
    var defaultUpdateFrequency = Double(1.0 / 6.0)
    
    var appDelegate: AppDelegate!
    
    var motionManager: CMMotionManager!

    @IBOutlet var skipCounter: UILabel!
    
    @IBOutlet var statusLabel: UILabel!
    
    @IBOutlet var pauseSwitch: UISwitch!
    
    @IBOutlet var slider: UISlider!
    
    @IBOutlet var accuracyLabel: UILabel!
    
    @IBOutlet var startButton: UIButton!
    
    @IBOutlet var finishButton: UIButton!
    
    @IBOutlet var pauseResumeLabel: UILabel!
    
    @IBAction func accuracySlider(sender: UISlider) {
        accuracyLabel.text = "\(Int(sender.value))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        accuracyLabel.text = "\(Int(slider.value))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func startMotion(sender: UIButton) {
        appDelegate.counter = 0
        skipCounter.text = "\(appDelegate.counter)"
        
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = defaultUpdateFrequency
        
        var queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        motionManager.startDeviceMotionUpdatesToQueue(queue, withHandler: { (motion, error) -> Void in
            if(self.pauseSwitch.on == false) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.motionMethod(motion)
                })
            }
        })
        
        statusLabel.text = "Started"
        self.finishButton.enabled = true
    }
    
    @IBAction func stopMotion(sender: UIButton) {
        if(nil != motionManager) {
            motionManager.stopDeviceMotionUpdates()
        }
        statusLabel.text = "Finished"
        self.finishButton.enabled = false
    }
    
    func motionMethod(motion: CMDeviceMotion) {
        var userAcceleration = motion.userAcceleration
        var vector = sqrt(pow(userAcceleration.x,2) + pow(userAcceleration.y,2) + pow(userAcceleration.z,2));
        if (vector >= minimumSkippingAcceleration) {
            appDelegate.counter++
            skipCounter.text = "\(appDelegate.counter)"
        }
    }
    
    @IBAction func handlePause(sender: UISwitch) {
        if(pauseSwitch.on) {
            statusLabel.text = "Paused"
            self.pauseResumeLabel.text = "Resume"
        } else {
            statusLabel.text = "Skipping"
            self.pauseResumeLabel.text = "Pause"
        }
    }
}