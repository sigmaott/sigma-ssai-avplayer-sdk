//
//  ViewController.swift
//  DemoSigmaInteractive
//
//  Created by PhamHai on 30/03/2022.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var inputVideoUrl: UITextField!
    @IBOutlet var clearPlayerSwitch: [UISwitch]!
    //    let urls = [Constants.masterUrl, Constants.playlist480Url, Constants.playlist360Url, Constants.sourceTestStreamMux]
    var selectedIndex: IndexPath?
    var selectedIndexInt = 0
    let selectButton = UIButton(type: .system)
    
    var topSafeArea = 0.0
    var bottomSafeArea = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        #if !targetEnvironment(simulator)
            SigmaDRM.getInstance()
        #endif
        for (index, switchControl) in clearPlayerSwitch.enumerated() {
            switchControl.isOn = false // Initialize all switches to OFF
            switchControl.tag = index // Assign a tag for identification
            switchControl.addTarget(self, action: #selector(switchValueResetSourceChanged(_:)), for: .valueChanged)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        setupTapGesture()
        inputVideoUrl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputVideoUrl.heightAnchor.constraint(equalToConstant: 50) // Thiết lập chiều cao
        ])
        tableView.contentInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        btnPlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btnPlay.widthAnchor.constraint(equalToConstant: 200) // Set desired width
        ])
        btnPlay.frame.size.width = 200 // Set desired width
    }
    @objc func switchValueChanged(_ sender: UISwitch) {
            if sender.isOn {
                print("Switch is ON")
            } else {
                print("Switch is OFF")
            }
        }
    @objc func switchValueResetSourceChanged(_ sender: UISwitch) {
            if sender.isOn {
            } else {
            }
        }
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGesture.cancelsTouchesInView = false // Cho phép các sự kiện chạm tiếp tục
        view.addGestureRecognizer(tapGesture)
    }
        
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    @objc func dismissKeyboard() {
        inputVideoUrl.resignFirstResponder() // Ẩn bàn phím
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            topSafeArea = view.safeAreaInsets.top
            bottomSafeArea = view.safeAreaInsets.bottom
        } else {
            topSafeArea = topLayoutGuide.length
            bottomSafeArea = bottomLayoutGuide.length
        }
        // safe area values are now available to use
    }
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       AppUtility.lockOrientation(.portrait)
   }

   override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       AppUtility.lockOrientation(.all)
   }
   func openInteractive(_ sender: UIButton) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedIndex = indexPath
            selectedIndexInt = indexPath.row
            tableView.reloadData() // Tải lại bảng để cập nhật giao diện
            tableView.deselectRow(at: indexPath, animated: true) // Bỏ chọn hàng
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.urls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false // Ensure margins do not persist from superview
        cell.textLabel?.text = Constants.urls[indexPath.row]["name"] as? String
    
        // Thay đổi màu nền nếu hàng được chọn
        if indexPath == selectedIndex || indexPath.row == selectedIndexInt {
            cell.backgroundColor = UIColor.red // Màu nền cho hàng được chọn
        } else {
            cell.backgroundColor = UIColor.white // Màu nền cho hàng không được chọn
        }
        
        return cell
    }
    @IBAction func handlerPlay(_ sender: Any) {
        let videoUrl = inputVideoUrl.text!;
        var isEnablePilot = true
        var isEnableClearPlayerWhenChangeSource = false
        for (index, switchControl) in clearPlayerSwitch.enumerated() {
            if switchControl.isOn {
                isEnableClearPlayerWhenChangeSource = true
            } else {
                print("Switch \(index) is OFF")
            }
        }
        if(!videoUrl.isEmpty && !Helper.isValidURL(videoUrl)) {
            showToast(message: "Video url invalid!", font: .systemFont(ofSize: 18.0))
            return
        } else {
            if !videoUrl.isEmpty {
                selectedIndexInt = Constants.urls.count
                URLManager.shared.urls = Array(Constants.urls)
                URLManager.shared.urls.append(["url": videoUrl, "isLive": true, "name": "Custom", "isDrm": false])
            } else {
                URLManager.shared.urls = Array(Constants.urls)
            }
        }
        var autoRotateValue = false
        var isEnableResetSession = false
        self.view.endEditing(true);
        let story = UIStoryboard(name: "Main", bundle: nil);
        let controller = story.instantiateViewController(withIdentifier: "demoPlayer") as! PlayerViewController;
        controller.title = "Manipolution"
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]  // Change UIColor.red to your desired color
        }
        controller.isDrm = URLManager.shared.urls[selectedIndexInt]["isDrm"] as! Bool;
        controller.videoUrl = URLManager.shared.urls[selectedIndexInt]["url"] as! String;
        controller.sessionUrl = URLManager.shared.urls[selectedIndexInt]["url"] as! String;
        controller.isLive = URLManager.shared.urls[selectedIndexInt]["isLive"] as! Bool;
        controller.bottomSafeArea = bottomSafeArea;
        controller.topSafeArea = topSafeArea
        controller.itemIndex = selectedIndexInt
        controller.itemIndex = selectedIndexInt
        controller.pilotEnable = isEnablePilot
        controller.autoRotate = autoRotateValue
        controller.resetSessionWhenChangeProfile = isEnableResetSession
        controller.changeSourceNeedReset = isEnableClearPlayerWhenChangeSource
        self.navigationController?.pushViewController(controller, animated: true);
    }
}
