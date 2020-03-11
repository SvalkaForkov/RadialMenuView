# RadialMenuView

A simple iOS physics-based radial menu that uses UIKit Dynamics.

![Alt Text](https://media.giphy.com/media/H6cfLGBJS7RyttDcf0/giphy.gif)

**Basic Usage:**
1. Copy the three files in the `RadialMenuView` group into your project.
2. Create a primary UIButton which will serve as the center button.
3. Create X number of secondary UIButtons to "pop out" of the primary button.
4. Call `RadialMenuView(withPrimaryButton: UIButton, secondaryButtons: [UIButton])` and add the returned `RadialMenuView` to the view hierarchy.

**Options:**
* Use `.radius` to set the desired distance between the primary button and the secondary buttons.
* Use `.delay` to set the interval time between each secondary button's animation.
* Use `.progressClosure` to set the animation of each secondary button using the supplied `button` and `progress` values.
