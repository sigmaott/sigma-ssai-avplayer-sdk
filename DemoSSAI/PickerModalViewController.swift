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
        

        let choiceButton = UIButton(type: .system)
        choiceButton.setTitle("  Choose  ", for: .normal)
        choiceButton.addTarget(self, action: #selector(changeSource), for: .touchUpInside)
        choiceButton.translatesAutoresizingMaskIntoConstraints = false
        choiceButton.layer.borderWidth = 1.0
        choiceButton.layer.borderColor = UIColor.blue.cgColor
        choiceButton.layer.cornerRadius = 5.0
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("  Cancel  ", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.layer.cornerRadius = 5.0
        
        view.addSubview(choiceButton)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            choiceButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 0),
            choiceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 40),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func changeSource() {
        delegate?.didSelectItem(selectedIndex, false)
        dismiss(animated: true, completion: nil)
    }
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    public func changeItem(_ index: Int) {
        pickerView.selectRow(index, inComponent: 0, animated: false)
        pickerView.reloadAllComponents()
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
        let name = (item["name"] as? String)!
        return "\(name) \(row == selectedIndex ? " (Đang phát)" : "")"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = Constants.urls[row]
        selectedIndex = row
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35 // Chiều cao hàng bạn mong muốn
    }
}
