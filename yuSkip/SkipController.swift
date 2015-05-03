
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
    
    @IBOutlet var startButton: UIButton!
    
    @IBOutlet var finishButton: UIButton!
    
    @IBOutlet var pauseResumeLabel: UILabel!
    
    @IBOutlet var durationLabel: UILabel!
    
    var startTime: NSDate!
    
    var endTime: NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
                    self.skipCounter(motion)
                })
            }
        })
        
        statusLabel.text = "Started"
        finishButton.enabled = true
        pauseSwitch.enabled = true
        durationLabel.text = "0.0"
    }
    
    @IBAction func stopMotion(sender: UIButton) {
        if(nil != motionManager) {
            motionManager.stopDeviceMotionUpdates()
        }
        statusLabel.text = "Finished"
        finishButton.enabled = false
        pauseSwitch.enabled = false
        pauseSwitch.on = false
        
        if(appDelegate.counter > 0) {
            var diff = Double(Double(Int(endTime.timeIntervalSinceDate(startTime) * 100)) / 100)
            durationLabel.text = "\(diff)"
        }
    }
    
    func skipCounter(motion: CMDeviceMotion) {
        var userAcceleration = motion.userAcceleration
        var vector = sqrt(pow(userAcceleration.x,2) + pow(userAcceleration.y,2) + pow(userAcceleration.z,2));
        if (vector >= minimumSkippingAcceleration) {
            appDelegate.counter++
            skipCounter.text = "\(appDelegate.counter)"
            
            if(appDelegate.counter == 1) {
                startTime = NSDate()
            }
            endTime = NSDate()
        }
    }
    
    @IBAction func handlePause(sender: UISwitch) {
        changePauseSwitch(sender.on)
    }
    
    func changePauseSwitch(flag: Bool){
        if(flag) {
            statusLabel.text = "Paused"
            pauseResumeLabel.text = "Resume"
        } else {
            statusLabel.text = "Skipping"
            pauseResumeLabel.text = "Pause"
        }
    }
}