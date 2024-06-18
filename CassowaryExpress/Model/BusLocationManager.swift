import Combine
import Alamofire

class BusLocationManager: NSObject, ObservableObject {
    @Published var busEntities : [BusEntity]

    private let configUtility: ConfigUtility
    private let apiKey : String
    private let urlGtfsFeedOrigin : String
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ configUtility: ConfigUtility) {
        self.busEntities = []
        self.configUtility = configUtility
        self.apiKey = configUtility.getConfig(configUtility.TFNSW_API_KEY) ?? ""
        self.urlGtfsFeedOrigin = configUtility.getConfig(configUtility.TFNSW_URL_VEHICLEPOS_BUS) ?? "https://api.transport.nsw.gov.au/v1/gtfs/vehiclepos/buses"
    }
    
    private func fetchGtfsFeedBusLocations() -> AnyPublisher<Data, Error> {
        let headers: HTTPHeaders = [
            "Authorization": "apikey \(apiKey)"
        ]

        return Future<Data, Error> { promise in
            AF.request(self.urlGtfsFeedOrigin, method: .get, headers: headers).responseData { response in
                switch response.result {
                case .success(let data):
                    promise(.success(data))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    private func parseGtfsFeedBusLocations(_ gtfsFeed : Data) {
        do {
            // Parse the Protobuf data
            let feedMessage = try TransitRealtime_FeedMessage(serializedData: gtfsFeed)

            // Process the GTFS header
            let header = feedMessage.header
            print("GTFS Realtime Version: \(header.gtfsRealtimeVersion)")
            print("Incrementality: \(header.incrementality)")
            print("Timestamp: \(Date(timeIntervalSince1970: TimeInterval(header.timestamp)))")

            // Process the GTFS entities

            var localBusEntities : [BusEntity] = []
            for entity in feedMessage.entity {
                var busEntity : BusEntity = BusEntity(angleDirection: 0, latitude: 0, longitude: 0, busUniqueIdentifier: "", busRoute: "")
                
                print("Entity ID: \(entity.id)")

                busEntity.busUniqueIdentifier = entity.id

                if entity.hasVehicle {
                    let vehicle = entity.vehicle

                    // Process trip
                    if vehicle.hasTrip {
                        let trip = vehicle.trip
                        print("    Trip ID: \(trip.tripID)")
                        print("    Start Time: \(trip.startTime)")
                        print("    Start Date: \(trip.startDate)")
                        print("    Route ID: \(trip.routeID)")
                        print("    Schedule Relationship: \(trip.scheduleRelationship)")
                        
                        busEntity.busRoute = trip.routeID
                    }

                    // Process position
                    if vehicle.hasPosition {
                        let position = vehicle.position
                        print("    Position: (\(position.latitude), \(position.longitude))")
                        print("    Bearing: \(position.bearing)")
                        print("    Speed: \(position.speed)")
                        
                        busEntity.latitude = Double(position.latitude)
                        busEntity.longitude = Double(position.longitude)
                        busEntity.angleDirection = Double(position.bearing)
                    }

                    print("    Timestamp: \(Date(timeIntervalSince1970: TimeInterval(vehicle.timestamp)))")
                    print("    Congestion Level: \(vehicle.congestionLevel)")

                    // Process vehicle descriptor
                    if vehicle.hasVehicle {
                        let vehicleDescriptor = vehicle.vehicle
                        print("    Vehicle ID: \(vehicleDescriptor.id)")
                        print("    Label: \(vehicleDescriptor.label)")
                        print("    License Plate: \(vehicleDescriptor.licensePlate)")

                        // Custom extension fields
                        if vehicleDescriptor.hasTransitRealtime_tfnswVehicleDescriptor {
                            let tfnswDescriptor = vehicleDescriptor.TransitRealtime_tfnswVehicleDescriptor
                            print("    Air Conditioned: \(tfnswDescriptor.airConditioned)")
                            print("    Wheelchair Accessible: \(tfnswDescriptor.wheelchairAccessible)")
                            print("    Vehicle Model: \(tfnswDescriptor.vehicleModel)")
                            print("    Performing Prior Trip: \(tfnswDescriptor.performingPriorTrip)")
                            print("    Special Vehicle Attributes: \(tfnswDescriptor.specialVehicleAttributes)")
                        }
                    }

                    print("  Occupancy Status: \(vehicle.occupancyStatus)")
                }
                localBusEntities.append(busEntity)
            }
            DispatchQueue.main.async {
                self.busEntities.append(contentsOf: localBusEntities)
            }
        } catch {
            print("Failed to read or parse Protobuf file: \(error)")
        }
    }
    
    // Function to download and save the file
    func refreshGtfsFeed() {
        self.fetchGtfsFeedBusLocations()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Finished successfully")
                    case .failure(let error):
                        print("Failed with error: \(error)")
                    }
                },
                receiveValue: { data in
                    // Handle the received data
                    print("Received data: \(data)")
                    
                    // Optionally, parse the data here
                    self.parseGtfsFeedBusLocations(data)
                }).store(in: &cancellables)
        }
}
