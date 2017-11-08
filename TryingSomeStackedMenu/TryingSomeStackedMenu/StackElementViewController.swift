//
//  StackElementViewController.swift
//  TryingSomeStackedMenu
//
//  Created by Guilherme Antunes Ferreira on 08/11/17.
//  Copyright © 2017 Guihsoft. All rights reserved.
//

import UIKit

class StackElementViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    
    var headerString:String? {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        self.headerLabel.text = headerString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    

}
