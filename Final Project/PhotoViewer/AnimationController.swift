
import UIKit

class AnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var image: UIImage?
    private var fromDelegate: ImageTransitionProtocol?
    private var toDelegate: ImageTransitionProtocol?
    
    // MARK: Setup Methods
    
    func setupImageTransition(image image: UIImage, fromDelegate: ImageTransitionProtocol, toDelegate: ImageTransitionProtocol){
        self.image = image
        self.fromDelegate = fromDelegate
        self.toDelegate = toDelegate
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    // 1: Set animation speed
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 2: Get view controllers involved
        guard let containerView = transitionContext.containerView(),
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            else {
                return
        }
        
        // 3: Set the destination view controllers frame
        toVC.view.frame = fromVC.view.frame
        
        // 4: Create transition image view
        let imageView = UIImageView(image: image)
        imageView.contentMode = .ScaleAspectFill
        imageView.frame = (fromDelegate == nil) ? CGRectMake(0, 0, 0, 0) : fromDelegate!.imageWindowFrame()
        imageView.clipsToBounds = true
        containerView.addSubview(imageView)
        
        fromDelegate!.tranisitionSetup()
        toDelegate!.tranisitionSetup()
        
        // 5: Create from screen snapshot
        let fromSnapshot = fromVC.view.snapshotViewAfterScreenUpdates(true)
        fromSnapshot.frame = fromVC.view.frame
        containerView.addSubview(fromSnapshot)
        
        // 6: Create to screen snapshot
        let toSnapshot = toVC.view.snapshotViewAfterScreenUpdates(true)
        toSnapshot.frame = fromVC.view.frame
        containerView.addSubview(toSnapshot)
        toSnapshot.alpha = 0
        
        // 7: Bring the image view to the front and get the final frame
        containerView.bringSubviewToFront(imageView)
        let toFrame = (self.toDelegate == nil) ? CGRectMake(0, 0, 0, 0) : self.toDelegate!.imageWindowFrame()
        
        // 8: Animate change
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.8, options: .CurveEaseOut, animations: {
            toSnapshot.alpha = 1
            imageView.frame = toFrame
            
        }, completion:{ [weak self] (finished) in

            self?.toDelegate!.tranisitionCleanup()
            self?.fromDelegate!.tranisitionCleanup()
            
            // 9: Remove transition views
            imageView.removeFromSuperview()
            fromSnapshot.removeFromSuperview()
            toSnapshot.removeFromSuperview()
                
            // 10: Complete transition
            if !transitionContext.transitionWasCancelled() {
                containerView.addSubview(toVC.view)
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}

protocol ImageTransitionProtocol {
    func tranisitionSetup()
    func tranisitionCleanup()
    func imageWindowFrame() -> CGRect
}
