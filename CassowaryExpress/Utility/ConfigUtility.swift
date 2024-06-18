import Foundation

class ConfigUtility {
    
    let TFNSW_API_KEY = "tfnswApiKey"
    let TFNSW_URL_VEHICLEPOS_BUS = "tfnswUrlVehiclePosBus"
    
    func getConfig(_ key: String) -> String? {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path) as? [String: Any],
           let value = config[key] as? String {
            return value
        }
        return nil
    }
    
}
