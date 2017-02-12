import Foundation

class HeartRateInterpreter {
    
    static let OVERDOSE_HEART_RATE = 180
    
    static func isSimpleOverdose(heartRate: Int) -> Bool {
        return heartRate > OVERDOSE_HEART_RATE ? true : false
    }
    
//    static func isDynamicOverdose(heartRate: Int) -> Bool {
//        vari = 0
//        diff = 0
//        x = 200
//        if (len(heart_rates) > 19):
//        for index in range(0, len(heart_rates) - 1):
//        if (-1 * (len(heart_rates) - index - 18) > 0):
//        diff = heart_rates[index] - (
//        .3333 * (heart_rates[index - 1] + heart_rates[index - 2] + heart_rates[index - 3]))
//        vari += (-.1 * (len(heart_rates) - index - 18)) * (diff * diff)
//        if (vari > x):
//        return True
//    }
    
}
