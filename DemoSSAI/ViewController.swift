//
//  ViewController.swift
//  DemoSigmaInteractive
//
//  Created by PhamHai on 30/03/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txtVideoUrl: UITextView!
    @IBOutlet weak var btnOpenInteractive: UIButton!
    @IBOutlet weak var txtError: UILabel!
    var topSafeArea = 0.0
    var bottomSafeArea = 0.0
    override func viewDidLoad() {
        let txtBorderColor: CGColor = UIColor.gray.cgColor;
        let txtBorderRadius: CGFloat = 5.0, txtBorderWidth:CGFloat = 1.0;
        txtVideoUrl.layer.borderWidth = txtBorderWidth;
        txtVideoUrl.layer.borderColor = txtBorderColor;
        txtVideoUrl.layer.cornerRadius = txtBorderRadius;
        super.viewDidLoad()
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
    @IBAction func openInteractive(_ sender: UIButton) {
        print("open interactive=>", txtVideoUrl.text!);
        let videoUrl = txtVideoUrl.text!;
        if URL(string: videoUrl) != nil {
            txtError.text = "";
            self.view.endEditing(true);
            let story = UIStoryboard(name: "Main", bundle: nil);
            let controller = story.instantiateViewController(withIdentifier: "demoPlayer") as! PlayerViewController;
//            let ViewController = ViewController(nibName: "PlayerViewController", bundle: nil);
            controller.videoUrl = "";
            controller.sessionUrl = videoUrl;
            controller.bottomSafeArea = bottomSafeArea;
            controller.topSafeArea = topSafeArea
            self.navigationController?.pushViewController(controller, animated: true);
//            self.present(controller, animated: true, completion: nil);
        } else {
            txtError.text = "Value incorrect";
        }
    }
}
