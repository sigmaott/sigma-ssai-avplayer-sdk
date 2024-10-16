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
    @IBOutlet weak var inputAdsProxy: UITextField!
    @IBOutlet weak var btnPlay: UIButton!
    let urls = [Constants.masterUrl, Constants.playlist480Url, Constants.playlist360Url, Constants.masterUrl, Constants.playlist480Url, Constants.playlist360Url, Constants.masterUrl, Constants.playlist480Url, Constants.playlist360Url, Constants.masterUrl, Constants.playlist480Url, Constants.playlist360Url, Constants.masterUrl, Constants.playlist480Url, Constants.playlist360Url, Constants.masterUrl, Constants.playlist480Url, Constants.playlist360Url, Constants.masterUrl, Constants.playlist480Url, Constants.playlist360Url, Constants.masterUrl, Constants.playlist480Url, Constants.playlist360Url, Constants.masterUrl, Constants.playlist480Url, Constants.playlist360Url]
    var selectedIndex: IndexPath?
    var selectedIndexInt = 0
    let selectButton = UIButton(type: .system)
    
    var topSafeArea = 0.0
    var bottomSafeArea = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        setupTapGesture()
        inputAdsProxy.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    inputAdsProxy.heightAnchor.constraint(equalToConstant: 50) // Thiết lập chiều cao
                ])
        tableView.contentInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        btnPlay.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btnPlay.widthAnchor.constraint(equalToConstant: 200) // Set desired width
            ])
        btnPlay.frame.size.width = 200 // Set desired width
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
        inputAdsProxy.resignFirstResponder() // Ẩn bàn phím
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
        return urls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false // Ensure margins do not persist from superview
        cell.textLabel?.text = urls[indexPath.row]
        
        // Thay đổi màu nền nếu hàng được chọn
        if indexPath == selectedIndex || indexPath.row == selectedIndexInt {
            cell.backgroundColor = UIColor.red // Màu nền cho hàng được chọn
        } else {
            cell.backgroundColor = UIColor.white // Màu nền cho hàng không được chọn
        }
        
        return cell
    }
    @IBAction func handlerPlay(_ sender: Any) {
        let adsProxy = inputAdsProxy.text!;
        if URL(string: adsProxy) != nil {
            self.view.endEditing(true);
            let story = UIStoryboard(name: "Main", bundle: nil);
            let controller = story.instantiateViewController(withIdentifier: "demoPlayer") as! PlayerViewController;
            controller.videoUrl = urls[selectedIndexInt];
            controller.sessionUrl = urls[selectedIndexInt];
            controller.adsProxy = adsProxy;
            controller.bottomSafeArea = bottomSafeArea;
            controller.topSafeArea = topSafeArea
            self.navigationController?.pushViewController(controller, animated: true);
        } else {
            showToast(message: "Please enter ads proxy", font: .systemFont(ofSize: 13))
        }
    }
}
