//
//  BandPagesViewController.swift
//  Resistor
//
//  Created by Justin Oroz on 5/30/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit

class BandPagesViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var bandViewControllers: [UIViewController] = []
    
    @IBOutlet var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        bandViewControllers = [(self.storyboard?.instantiateViewControllerWithIdentifier("4band"))! as! _4BandViewController,
                               self.storyboard?.instantiateViewControllerWithIdentifier("5band") as! _5BandViewController,
                               self.storyboard?.instantiateViewControllerWithIdentifier("6band") as! _6BandViewController]
        
        // Do any additional setup after loading the view.
        self.setViewControllers([bandViewControllers[0]], direction: .Forward, animated: true, completion: {
            (success) in
            })
        
        
        setAppearance()
        
    }
    
    func setAppearance() {
        self.view.backgroundColor = UIColor.whiteColor()
        let appearance = UIPageControl.appearance()
        appearance.currentPageIndicatorTintColor = UIColor.blackColor()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.backgroundColor = UIColor.whiteColor()
    
        let firstView = (bandViewControllers[0] as! _4BandViewController).view
        backgroundView.frame = firstView.frame
        backgroundView.frame = CGRect(origin: firstView.frame.origin, size: CGSize(width: firstView.frame.width, height: firstView.frame.height-37))
        backgroundView.bounds = firstView.bounds

        self.view.addSubview(backgroundView)
        self.view.sendSubviewToBack(backgroundView)
    }
    
    
    // MARK: - UIPageViewController Delegate methods
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return bandViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let index = bandViewControllers.indexOf(viewController)
        if index > 0 {
            return bandViewControllers[index!-1]
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let index = bandViewControllers.indexOf(viewController)
        
        if index < bandViewControllers.count-1 {
            return bandViewControllers[index!+1]
        } else {
            return nil
        }
    }
    
    
    func pageViewControllerSupportedInterfaceOrientations(pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        return .Portrait
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
