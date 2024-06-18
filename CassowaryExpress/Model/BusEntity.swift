/// Plain Old Swift Object representing a moving bus
struct BusEntity : Hashable {
    /// The direction the bus is travelling in degrees clockwise from true north.
    var angleDirection: Double;
    /// The current geographical location of the bus (latitude).
    var latitude : Double;
    /// The current geographical location of the bus (longitude).
    var longitude : Double;
    /// A unique identifier for the bus.
    var busUniqueIdentifier : String;
    /// The id of the route that this bus is taking.
    var busRoute : String;
    
    static func == (lhs: BusEntity, rhs: BusEntity) -> Bool {
        return lhs.busUniqueIdentifier == rhs.busUniqueIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(busUniqueIdentifier)
    }
}
