import Foundation
import HealthKit

class HeartRate {
    
    private static let healthStore = HKHealthStore()
    
    private static let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    private static let sortByTime = HeartRate.createSortByTime()
    private static let timeFormatter = HeartRate.createTimeFormatter()
    private static let dateFormatter = HeartRate.createDateFormatter()
    
    static func getHeartRate() -> [String: Any] {
        var heartRate = [String: Any]()
        if (HKHealthStore.isHealthDataAvailable()){
            healthStore.requestAuthorization(toShare: nil, read:[heartRateType], completion:{(success, error) in
                
                let query = HKSampleQuery(sampleType:self.heartRateType,
                                          predicate:nil,
                                          limit:1,
                                          sortDescriptors:[self.sortByTime],
                                          resultsHandler:{(query, results, error) in
                                            guard let results = results else { return }
                                            for quantitySample in results {
                                                heartRate = self.parseHeartRate(result: quantitySample)
                                            }
                })
                healthStore.execute(query)
            })
        }
        return heartRate
    }
    
    private static func parseHeartRate(result: HKSample) -> [String: Any] {
        let quantity = (result as! HKQuantitySample).quantity
        let time = timeFormatter.string(from: result.startDate)
        let date = dateFormatter.string(from: result.startDate)
        let heartRateUnit = HKUnit(from: "count/min")
        let heartRate = quantity.doubleValue(for: heartRateUnit)
        return ["time": time, "date": date, "heart_rate": heartRate]
    }
    
    private static func createSortByTime() -> NSSortDescriptor {
        return NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending:false)
    }
    
    private static func createTimeFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        return dateFormatter
    }
    
    private static func createDateFormatter() -> DateFormatter {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "MM/dd/YYYY"
        return timeFormatter
    }

}
