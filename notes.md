Note for Kevin.

So the issue right now is that even if we listen for the UIPageViewController event, the comic may not have been loaded at that point in time, so since the comic is nil, we can't update the data.

The new plan is to make a delegate for ComicViewController -- whenever a comic is fully loaded, we notify the delegate, which will be the ComicsPageViewController.

If it detects a comic has been loaded, we will check to see if it is the current comic, and if so, notify the HomePageViewController.

The only issue with this idea is that it's not the greatest design. Comics on the side that are loaded will not notify the controller, and it will update the HomePageViewController comic info through a different mechanism, the UIPageViewControllerDelegate. I would like to somehow synchronize all of these.

Perhaps the better method could be to maybe make the ComicViewController the delegate and go from there? Food for thought.
