//
//  ViewController.swift
//  StackViews
//
//  Created by new on 6/17/16.
//  Copyright © 2016 Avi Pogrow. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class NameEditorViewController: UIViewController {
	
	fileprivate  var audioController: AudioController
	
	var person:Person!
	
	lazy var sharedContext: NSManagedObjectContext = {
	 return CoreDataStackManager.sharedInstance().managedObjectContext
	 }()
	
	@IBOutlet weak var gameView: UIView!
	@IBOutlet weak var backButtonStackView: UIImageView!
    @IBOutlet weak var spaceButtonStackView: UIImageView!
	
	var imageStringArray = [String]()
	
	
    required init?(coder aDecoder: NSCoder) {
		audioController = AudioController()
		audioController.preloadAudioEffects(AudioEffectFiles)
		
        super.init(coder: aDecoder)
		//tell UIKit that this view controller uses a custom presentation object
		modalPresentationStyle = .custom
		transitioningDelegate = self
  	}
	
   
    fileprivate func animateView(_ view: UIView,  toHidden hidden: Bool) {
		UIView.animate(withDuration: 0.8,
		 delay: 0.2,
		usingSpringWithDamping: 0.8,
		initialSpringVelocity: 10.0, options: [], animations: { ()
			-> Void in
			view.isHidden = hidden
		}, completion: nil)
	}
	
	func handleBackSpaceButtonAnimation() {
		
		if  imageStringArray.isEmpty {
		 
        animateView(backButtonStackView, toHidden: true)
		animateView(spaceButtonStackView, toHidden: true)
		} else {
		animateView(spaceButtonStackView, toHidden: false)
		animateView(backButtonStackView, toHidden:false)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
  
	}
	
    override func viewWillAppear(_ animated: Bool) {
   	 super.viewWillAppear(animated)
	
        gameView.layer.borderWidth = 1.35
		gameView.layer.borderColor = UIColor.red.cgColor
		gameView.layer.cornerRadius = 10
	
		audioController.playEffect(SoundPop)
	
	 if imageStringArray.isEmpty {
		 
        animateView(backButtonStackView, toHidden: true)
		animateView(spaceButtonStackView, toHidden: true)
		} else {
		animateView(spaceButtonStackView, toHidden: false)
		animateView(backButtonStackView, toHidden: false)
		}
	}
	
	@IBAction func donePressed(_ sender: AnyObject) {
	
        person = Person(context: sharedContext)
		person.dateCreated = Date()
		
        CoreDataStackManager.sharedInstance().saveContext()
		
        updateCoreDataModelWithNewArrayOfStrings(imageStringArray)
	
        dismissAnimationsStyle = .slide
	
        let hudView = HudView.hudInView(self.view, animated: true)
		
		hudView.text = "Saved"
		audioController.playEffect(SoundWin)
	
		afterDelay(1.3) {
		
		self.animateView(self.gameView, toHidden: true)
		self.dismiss(animated: true, completion: nil)
        }
    }

    func updateCoreDataModelWithNewArrayOfStrings(_ imageStringArray:[String]) {
		
	 var letter:LetterInName!
	
	  for i in imageStringArray {
 		let newString = i
		let newKapitelString = i + "kapitel"
	
		print("\(newString) and \(newKapitelString)")
	
        letter = LetterInName(context: sharedContext)
		letter.hebrewLetterString = "\(newString)"
        letter.kapitelImageString = "\(newString)" + "kapitel"
        
        letter.person = self.person

		CoreDataStackManager.sharedInstance().saveContext()
        }
     }

	
     func stringForTag(_ kind:Int) -> String {
      switch kind {
	  case 100: return "SpaceNew1"
	  case 101: return "AlephNew11"
	  case 102: return "BeisNew11"
      case 103: return "GimmelNew11"
      case 104: return "DaledNew11"
      case 105: return "HeyNew11"
      case 106: return "VovNew11"
	  case 107: return "ZayinNew11"
      case 108: return "ChesNew11"
      case 109: return "TesNew11"
      case 110: return "YudNew11"
	  case 111: return "ChofNew11"
	  case 112: return "ChofSofitNew11"
	  case 113: return "LamedNew11"
	  case 114: return "MemNew11"
	  case 115: return "MemSofitNew11"
	  case 116: return "NunNew11"
	  case 117: return "NunSofitNew11"
	  case 118: return "SamechNew11"
	  case 119: return "AyinNew11"
	  case 120: return "PeyNew11"
	  case 121: return "PeySofitNew11"
	  case 122: return "TzaddikNew11"
	  case 123: return "TzaddikSofitNew11"
	  case 124: return "KufNew11"
	  case 125: return "SpaceNew11"
	  case 126: return "RayshNew11"
	  case 127: return "ShinNew11"
	  case 128: return "TofNew11"
	
      default: return "TV"
      }
    }
	
	@IBAction func letterTapped(_ sender: UIGestureRecognizer ) {
	
		var kind: Int!	
		kind = sender.view!.tag
        
        let viewTapped = sender.view!
		
   		let tempTransform = viewTapped.transform
		
        UIView.animate(withDuration: 0.15,
		delay: 0.00,
		options: UIViewAnimationOptions.curveEaseOut,
		animations: {
			
				
        viewTapped.transform = viewTapped.transform.scaledBy(x: 2.1, y: 2.1) },
		 completion: {
		  (value:Bool) in
		  
		  
		  viewTapped.transform = tempTransform
		 })
		
		let newLetterImageString = stringForTag(kind)
	
		imageStringArray.append(newLetterImageString)
	
		updateTheHudWithStringArray(imageStringArray)
	
		audioController.playEffect(SoundDing)
	}
	
	func updateTheHudWithStringArray(_ imageStringArray: [String]) {
		
		handleBackSpaceButtonAnimation()
	
		drawLettersInGameView(imageStringArray)
	}
    
    //1. pass in array of strings
	func drawLettersInGameView(_ imageStringArray: [String]) {
	 
        //2. total number of rows and columns
		_ = 0
		let columnsPerPage = 15
			
		//3. current row and column number
		var rowNumber = 0
		var column = 1
	
		//4. calculate the width and height of each square tile
		let tileSide = ceil(ScreenWidth / CGFloat(14.5))
		
        let marginX = view.bounds.width - 3
		let x = marginX
		
        let marginY = (CGFloat(rowNumber) * tileSide)
		var y = marginY + 10
	
//********************** start the for loop ***************************
	
		for s in imageStringArray {
		
		let tile = TileView(letter: s, sideLength: tileSide)
		
		tile.frame = CGRect(
		x: x + (CGFloat(column) * -tileSide),  //22 is the same as tileSide
										 // the first letter is drawn
										// margin x (-3 points from right edge)
										// + (0 * -22) so it gets drawn -25 from right edge
		y: y,
		
		width: tileSide, height: tileSide)
		print("******************the value of tileside is \(tileSide)")
		print("the value of the frame is \(tile.frame)")
		
		gameView.addSubview(tile)
	
		column = column + 1
	
		let viewToExplode = gameView.subviews.last
		let explode = ExplodeView(frame:CGRect(x: viewToExplode!.center.x, y: viewToExplode!.center.y, width: 2,height: 2))
   		 tile.superview?.addSubview(explode)
		tile.superview?.sendSubview(toBack: explode)

		//16. check if we are at the end of the row
		if column == columnsPerPage {
		
        column = 1;rowNumber = rowNumber + 1; y = y + 30
            }
         }
     }

    @IBAction func backSpaceButtonTapped(_ sender: UITapGestureRecognizer) {

		let viewTapped = sender.view!
		print("the view tapped was \(viewTapped)")
		
		UIView.animate(withDuration: 0.20,
		delay: 0.00,
		options: UIViewAnimationOptions.curveEaseOut,
		animations: {
				viewTapped.backgroundColor = UIColor.gray
				},
		 completion: {
		  (value:Bool) in
		  viewTapped.backgroundColor = UIColor.white
		 })
	
		imageStringArray.removeLast()
	
        for view in gameView.subviews {
			view.removeFromSuperview()
		}
	
		updateTheHudWithStringArray(imageStringArray)
	
		audioController.playEffect(SoundPop)
	
		}
	
    @IBAction func cancelPressed(_ sender: AnyObject) {
		dismissAnimationsStyle = .fade
		dismiss(animated: true, completion: nil)
		audioController.playEffect(SoundWin)
		}
	
    enum AnimationStyle {
	  case slide
	  case fade
	}
	
    var dismissAnimationsStyle = AnimationStyle.fade
  }

//tell UIKit what objects the detail view controller should use when transitioning to the detail view
extension NameEditorViewController: UIViewControllerTransitioningDelegate {
	
  func presentationController(
  		forPresented presented: UIViewController,
		presenting: UIViewController?,
  		source: UIViewController)
		 -> UIPresentationController? {
   
	
	 return DimmingPresentationController(
	   					presentedViewController: presented,
						presenting: presenting)
		}
	
	
	
		func animationController(forPresented presented: UIViewController,
	 	 presenting: UIViewController,
	 	 source: UIViewController)
	 		 -> UIViewControllerAnimatedTransitioning? {
		
	
			return BounceAnimationController()
  		}	
	
	//this method gets called when the view is being dismissed
	// it returns the SlideOutAnimationController that handles the animation details
	func animationController(
		 					forDismissed dismissed: UIViewController)
   							-> UIViewControllerAnimatedTransitioning? {
		
		switch dismissAnimationsStyle {
    case .fade:
	   return FadeOutAnimationController()
    default:
        return SlideOutAnimationController()
			}
		}
	}
	



	








