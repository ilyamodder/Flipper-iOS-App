import CoreBluetooth
import struct Foundation.UUID

public protocol BluetoothPeripheral {
    var id: UUID { get }
    var name: String { get }
    // TODO: Incapsulate CB objects
    var state: CBPeripheralState { get }
    var services: [CBService] { get }

    var info: SafePublisher<Void> { get }

    func send(_ request: Request, continuation: @escaping (Response) -> Void)
}