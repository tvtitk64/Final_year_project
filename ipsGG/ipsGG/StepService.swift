import CoreMotion

class StepService: NSObject {
    
    let cmManager = CMMotionManager()
    var delegate: StepServiceDelegate?
    
    var stepCountFlag = true
    var smoothedVerticalAcc = 0.0
    var frame = 0
    let TIMER_INTERVAL = 0.01
    var timer: Timer?
    
    let V_THRESH_DEFAULT = 0.05
    var vThresh = 0.05
    var reductionRate = 0.01
    let RESET_FRAME_NUM = 15.0
    let MIN_COUNT_FRAME = 12
    
    var fixedStepBpm: Double?
    var diffBpm = 0
    var fixedIterater = 0
    
    
    
    func startStepCount(fps: Double) {
        cmManager.deviceMotionUpdateInterval = TimeInterval(1 / fps)
        cmManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: handleMove)
    }
    
    func stopAccMeter() {
        cmManager.stopDeviceMotionUpdates()
    }
    
    func handleMove(data: CMDeviceMotion?, error: Error?) {
        if data != nil {
            let x = data!.userAcceleration.x
            let y = data!.userAcceleration.y
            let z = data!.userAcceleration.z
            let roll_row = data!.attitude.roll
            let pitch_row = data!.attitude.pitch
            let roll_deg = roll_row * 180.0 / Double.pi
            let pitch_deg = pitch_row * 180.0 / Double.pi
            var roll_tmp = roll_deg
            if (roll_deg > 90.0) {
                roll_tmp = 90.0 - (roll_deg - 90.0)
            } else if (roll_deg < -90) {
                roll_tmp = -90.0 - (roll_deg + 90.0)
            }
            let roll_90 = roll_tmp
            let pitch_90 = pitch_deg
            let roll = roll_90 / 90.0
            let pitch = pitch_90 / 90.0
            let x_weight = roll * (1.0 - fabs(pitch))
            let y_weight = pitch * (-1)
            var z_weight_tmp = 1.0 - (fabs(x_weight) + fabs(y_weight))
            if (fabs(roll_deg) > 90) {
                z_weight_tmp = z_weight_tmp * (-1)
            }
            let z_weight = z_weight_tmp * (-1)
            let verticalAcc = x * x_weight + y * y_weight + z * z_weight
            smoothedVerticalAcc = verticalAcc * 0.1 + smoothedVerticalAcc * 0.9
            if (smoothedVerticalAcc > vThresh && stepCountFlag == true && frame > MIN_COUNT_FRAME) {
                stepCountFlag = false
                frame = 0
                delegate?.step()
            } else if (smoothedVerticalAcc < 0.0) {
                stepCountFlag = true
            }
            updateVThresh(smoothedVerticalAcc)
            
//            print("x:\(x), y:\(y), z:\(z), roll:\(roll), pitch:\(pitch), x_weight:\(x_weight), y_weight:\(y_weight), z_weight:\(z_weight), verticalAcc:\(verticalAcc)")
            //print("\(verticalAcc)")
            frame += 1
        }
    }
    
    // 閾値の動的更新処理
    func updateVThresh(_ verticalAcc: Double) {
        if (verticalAcc > vThresh) {
            vThresh = verticalAcc
            reductionRate = (verticalAcc - V_THRESH_DEFAULT) / RESET_FRAME_NUM
        } else if (vThresh > V_THRESH_DEFAULT) {
            vThresh -= reductionRate
        } else {
            vThresh = V_THRESH_DEFAULT
        }
    }
}

/* Delegate用 */
protocol StepServiceDelegate: NSObjectProtocol {
    func step()
}

