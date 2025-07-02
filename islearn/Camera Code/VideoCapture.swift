import Foundation
import AVFoundation

class VideoCapture : NSObject  {
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    let predictor = Predictor()
    
    override init(){
        super.init( )
//        guard let captureDevice = AVCaptureDevice.default(for: .video),
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video,position: .front),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        captureSession.addInput(input)
        
        captureSession.addOutput(videoOutput)
    }
    
    func startCaptureSession(){
//        DispatchQueue.global().async{
            captureSession.startRunning()
//        }
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Video Dispatch Queue"))
    }
    
    func endCaptureSession(){
        captureSession.stopRunning()
    }
}

extension VideoCapture : AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        predictor.estimation(sampleBuffer: sampleBuffer)
 
    }
}

