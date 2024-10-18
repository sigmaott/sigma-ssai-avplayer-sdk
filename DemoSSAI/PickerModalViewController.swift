//
//  PickerModalViewController.swift
//  DemoSSAI
//
//  Created by Pham Hai on 18/10/2024.
//

import Foundation
import UIKit

class PickerModalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    weak var delegate: PickerModalDelegate?

    var selectedItem: [String: Any]?
    var selectedIndex: Int = 0
    var selectedIndexPure: Int = 0
    
    var pickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)

        view.addSubview(pickerView)

        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pickerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 200)
        ])

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Change", for: .normal)
        closeButton.addTarget(self, action: #selector(changeSource), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func changeSource() {
        delegate?.didSelectItem(selectedIndex)
//        updateHighlightedIndex(selectedIndex)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UIPickerView DataSource & Delegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.urls.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let item = Constants.urls[row] as [String: Any]
        return (item["name"] as? String)!
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = Constants.urls[row]
        selectedIndex = row
    }
}
