//
//  HTTestViewController.swift
//  HTSkinBundle_Example
//
//  Created by Jason on 2022/11/11.
//  Copyright © 2022 nscribble. All rights reserved.
//

import Foundation
import HTSkinBundle

class TTTestViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        let button = GradientButton()
        button.layer.cornerRadius = 60/2
        button.layer.masksToBounds = true
        button.style
            .module("login")
            .backgroundColorKey("next_button_bg_color")
            .textColorKey("next_button_title_color")
            .fontKey("next_button_title_font")
        button.textLabel.text = "测试测试测试"
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -160),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200)
        ])
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.style
            .module("login")
            .imageKey("some_bg_image_in_assets")
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 230 * UIScreen.main.bounds.width / 375),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        ])
    }
    
}
