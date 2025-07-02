import Foundation
import Vision

protocol PredictorDelegate : AnyObject{
    func predictor(_ predictor : Predictor, didFindRecoganisedPoints : [CGPoint])
    func predictor(_ predictor : Predictor, didLabelAction action : String, with confidence : Double)
}

class Predictor {
    
    weak var delegate : PredictorDelegate?
    
    let predictionWindowSize = 1
    var posesWindow : [VNHumanHandPoseObservation] = []
    
    init(){
        posesWindow.reserveCapacity(predictionWindowSize)
    }
    
    func estimation(sampleBuffer : CMSampleBuffer){
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer,orientation: .up)
        
        let request = VNDetectHumanHandPoseRequest(completionHandler: handPoseHandler)
        
        do {
            try requestHandler.perform([request])
        }catch {
            print("Error in handler performing :\(error)")
        }
    }
    
    func handPoseHandler(request : VNRequest, error : Error?){
        guard let observations = request.results as? [VNHumanHandPoseObservation] else {return}
        
        observations.forEach {
            processObservation($0)
        }
        
        if let result = observations.first {
            storedObservation(result)
            labelActionType()
        }
    }
    
    func labelActionType(){
        guard let handPoseClassifier = try? thisModel(configuration: MLModelConfiguration()),
              let posesMultiArray = prepareInputWithObservations(posesWindow),
        let predictions = try? handPoseClassifier.prediction(poses: posesMultiArray)
        else {return}
        
        let label = predictions.label
        let confidence = predictions.labelProbabilities[label] ?? 0
        
//        print(label)
        
        delegate?.predictor(self, didLabelAction: label, with: confidence)
        
    }
    
    func prepareInputWithObservations(_ observations : [VNHumanHandPoseObservation])-> MLMultiArray? {
        let numAvailableFrames = observations.count
        let observationsNeeded = 1
        var multiArrayBuffer = [MLMultiArray]()
        
        for frameIndex in 0 ..< min(numAvailableFrames, observationsNeeded){
            let pose = observations[frameIndex]
//
            do {
                let oneFrameMultiArray = try pose.keypointsMultiArray()
                multiArrayBuffer.append(oneFrameMultiArray)
            }catch{
                continue
            }
//
            if numAvailableFrames < observationsNeeded {
                for _ in 0..<(observationsNeeded - numAvailableFrames){
                    do {
                        let oneFrameMultiArray = try MLMultiArray(shape:[1,3,21], dataType: .double)
                        try resetMultiArray(oneFrameMultiArray)
                        multiArrayBuffer.append(oneFrameMultiArray)
                    }catch{
                        continue
                    }
                }
            }
        }
        return MLMultiArray(concatenating: [MLMultiArray](multiArrayBuffer), axis: 0, dataType: .float)
        
    }
    
    func resetMultiArray(_ predictionWindow : MLMultiArray, with value : Double = 0.0) throws {
        let pointer = try UnsafeMutableBufferPointer<Double>(predictionWindow)
        pointer.initialize(repeating: value)
    }
    
    func storedObservation(_ observation : VNHumanHandPoseObservation){
        if posesWindow.count >= predictionWindowSize {posesWindow.removeFirst()}
        
        posesWindow.append(observation)
    }
    
    func processObservation(_ observation : VNHumanHandPoseObservation){
        do {
            let recoganisedPoints = try observation.recognizedPoints(forGroupKey: .all)
            
            
            let displayedPoints = recoganisedPoints.map {
                CGPoint(x: $0.value.x, y: 1 - $0.value.y)
            }
            
            
            delegate?.predictor(self, didFindRecoganisedPoints: displayedPoints)
        }catch {
            print("Error in coordinate points : \(error)")
        }
    }
}

