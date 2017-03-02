//
//  BandPagesViewController.swift
//  Resistor
//
//  Created by Justin Oroz on 5/30/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class BandPagesViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var bandViewControllers: [UIViewController] = []
    
    @IBOutlet var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        bandViewControllers = [(self.storyboard?.instantiateViewController(withIdentifier: "4band"))! as! _4BandViewController,
                               self.storyboard?.instantiateViewController(withIdentifier: "5band") as! _5BandViewController,
                               self.storyboard?.instantiateViewController(withIdentifier: "6band") as! _6BandViewController]
        
        // Do any additional setup after loading the view.
        self.setViewControllers([bandViewControllers[0]], direction: .forward, animated: true, completion: {
            (success) in
            })
        
        
        setAppearance()
        
    }
    
    func setAppearance() {
        self.view.backgroundColor = UIColor.white
        let appearance = UIPageControl.appearance()
        appearance.currentPageIndicatorTintColor = UIColor.black
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.backgroundColor = UIColor.white
    
        let firstView = (bandViewControllers[0] as! _4BandViewController).view
        
        backgroundView.frame = (firstView?.frame)!
        backgroundView.frame = CGRect(origin: (firstView?.frame.origin)!, size: CGSize(width: (firstView?.frame.width)!, height: (firstView?.frame.height)!-37))
        backgroundView.bounds = (firstView?.bounds)!

        //self.view.addSubview(backgroundView)
        //self.view.sendSubviewToBack(backgroundView)
    }
    
    
    // MARK: - UIPageViewController Delegate methods
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return bandViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = bandViewControllers.index(of: viewController)
        if index > 0 {
            return bandViewControllers[index!-1]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = bandViewControllers.index(of: viewController)
        
        if index < bandViewControllers.count-1 {
            return bandViewControllers[index!+1]
        } else {
            return nil
        }
    }
    
    
    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        return .portrait
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
