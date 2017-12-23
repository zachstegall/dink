//
//  ViewController.swift
//  Dink
//
//  Created by Zachary Stegall on 12/23/17.
//  Copyright © 2017 Dink. All rights reserved.
//

import UIKit
import RxBluetoothKit
import RxSwift
import CoreBluetooth

class ViewController: UIViewController {
    private var isScanInProgress = false
    private var scheduler: ConcurrentDispatchQueueScheduler!
    private let manager = BluetoothManager(queue: .main)
    private var scanningDisposable: Disposable?
    fileprivate var peripheralsArray: [ScannedPeripheral] = []
    fileprivate let scannedPeripheralCellIdentifier = "peripheralCellId"

    override func viewDidLoad() {
        super.viewDidLoad()

        let timerQueue = DispatchQueue(label: "com.polidea.rxbluetoothkit.timer")
        scheduler = ConcurrentDispatchQueueScheduler(queue: timerQueue)

         startScanning()
    }

    private func stopScanning() {
        scanningDisposable?.dispose()
        isScanInProgress = false
        title = ""
        print("stopped scanning")
    }

    private func startScanning() {
        isScanInProgress = true
        print("scanning")
        title = "Scanning..."
        scanningDisposable = manager.rx_state
            .timeout(4.0, scheduler: scheduler)
            .take(1)
            .flatMap { _ in self.manager.scanForPeripherals(withServices: nil, options: nil) }
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: {
                self.addNewScannedPeripheral($0)
            }, onError: { _ in
            })
    }

    private func addNewScannedPeripheral(_ peripheral: ScannedPeripheral) {
        print("aaaaaa")
        let mapped = peripheralsArray.map { $0.peripheral }
        if let indx = mapped.index(of: peripheral.peripheral) {
            peripheralsArray[indx] = peripheral
        } else {
            peripheralsArray.append(peripheral)
        }
//        DispatchQueue.main.async {
//            self.scansTableView.reloadData()
//        }
    }
}
