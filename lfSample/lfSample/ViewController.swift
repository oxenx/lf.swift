import lf
import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let url:String = "rtmp://localhost/live"
    let streamName:String = "test"
    
    var startButton, stopButton : UIButton!
    var rtmpConnection:RTMPConnection = RTMPConnection()
    var rtmpStream:RTMPStream?

    override func viewDidLoad() {
        super.viewDidLoad()

        rtmpStream = RTMPStream(rtmpConnection: rtmpConnection)
        rtmpStream!.attachAudio(AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio))
        rtmpStream!.attachCamera(AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo))

        startButton = UIButton(frame: CGRectMake(0, 0, 120, 50))
        startButton.backgroundColor = UIColor.blueColor()
        startButton.setTitle("start", forState: .Normal)
        startButton.layer.masksToBounds = true
        startButton.layer.position = CGPoint(x: self.view.bounds.width / 2 - 70, y:self.view.bounds.height - 50)
        startButton.addTarget(self, action: "startButton_onClick:", forControlEvents: .TouchUpInside)

        stopButton = UIButton(frame: CGRectMake(0, 0, 120, 50))
        stopButton.backgroundColor = UIColor.grayColor();
        stopButton.layer.masksToBounds = true
        stopButton.setTitle("stop", forState: .Normal)
        stopButton.layer.position = CGPoint(x: self.view.bounds.width / 2 + 70, y:self.view.bounds.height - 50)
        stopButton.addTarget(self, action: "stopButton_onClick:", forControlEvents: .TouchUpInside)

        var previewLayer:AVCaptureVideoPreviewLayer = rtmpStream!.toPreviewLayer()
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)

        self.view.addSubview(self.startButton)
        self.view.addSubview(self.stopButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func startButton_onClick(sender:UIButton) {
        rtmpConnection.addEventListener("rtmpStatus", selector:"rtmpConnection_rtmpStatusHandler:", observer: self)
        rtmpConnection.connect(url)
    }

    func stopButton_onClick(sender:UIButton) {
        rtmpConnection.close()
        rtmpConnection.removeEventListener("rtmpStatus", selector:"rtmpConnection_rtmpStatusHandler", observer: self)
    }

    func rtmpConnection_rtmpStatusHandler(notification:NSNotification) {
        let e:Event = Event.from(notification)
        if let data:ECMAObject = e.data as? ECMAObject {
            if let code:String = data["code"] as? String {
                switch code {
                case "NetConnection.Connect.Success":
                    rtmpStream!.publish(streamName)
                    break
                default:
                    break
                }
            }
        }
    }
}
