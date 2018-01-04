//
//  Central.swift
//  Dink
//
//  Created by Zachary Stegall on 12/23/17.
//  Copyright © 2017 Dink. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol CentralProtocol {
    func start()
}

class Central: NSObject, CentralProtocol, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager?
    var discoveredPeripheral: CBPeripheral?
    
    func start() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    func scanForPeripherals() {
        let uuids = [CBUUID(string: "F42D98DB-BD4B-4355-A6AF-371909D42F2F")]
        centralManager?.scanForPeripherals(withServices: uuids, options: nil)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState \(central.state.rawValue)")
        if central.state == .poweredOn {
            scanForPeripherals()
        } else {
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        discoveredPeripheral = peripheral
        centralManager?.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        central.stopScan()
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.discoverCharacteristics(nil, for: peripheral.services![5])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        peripheral.readValue(for: service.characteristics![0])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.properties.contains(.notify) {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
}
