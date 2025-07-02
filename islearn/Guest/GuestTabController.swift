//
//  GuestTabController.swift
//  islearn
//
//  Created by Vanshika Choudhary on 4/6/25.
//

import UIKit

class GuestTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("👤 GuestTabBarController loaded")

        // Optional: customize tabs, disable certain features, etc.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Optional: present onboarding for guest users if needed
    }
}
