//
//  LocationPickerViewController.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 14.07.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

final class LocationPickerViewController: UIViewController {

    public var completion: ((CLLocationCoordinate2D) -> Void)?
    private var cordinates: CLLocationCoordinate2D?
    private var isPickable = true
    private let map: MKMapView = {
       let map = MKMapView()
        return map
    }()
    
    init(cordinates: CLLocationCoordinate2D?) {
        self.cordinates = cordinates
        self.isPickable = cordinates == nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        if isPickable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Gönder", style: .done, target: self, action: #selector(sendButtonTapped))
            
            map.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap(_:)))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)
        } else {
            guard let cordinates = self.cordinates else {
                return
            }
            let pin = MKPointAnnotation()
            pin.coordinate = cordinates
            map.addAnnotation(pin)
        }
        view.addSubview(map)
    }
    
    @objc func sendButtonTapped() {
        guard let cordinates = cordinates else {
            return
        }
        navigationController?.popViewController(animated: true)
        completion?(cordinates)
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: map)
        let cordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.cordinates = cordinates
        
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        
        let pin = MKPointAnnotation()
        pin.coordinate = cordinates
        map.addAnnotation(pin)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
}
