Exaile Homebrew Tap
===================

This allows you to install Exaile via homebrew. Quick and dirty:

    brew install exaile/exaile/exaile

Once you install Exaile, currently the only way to launch it is via
the terminal. Just run `exaile` and it should launch.

Unfortunately, installation on OSX is experimental and GTK has known serious
issues on OSX. In particular, drag and drop operations can cause Exaile to
completely crash. We welcome assistance with fixing these issues!

Install troubleshooting
-----------------------

If you run into an error installing pyobjc, then you might need to redirect
your XCode install.

* See [this stack overflow post](https://stackoverflow.com/questions/17980759/xcode-select-active-developer-directory-error/17980786#17980786) for details
* TL;DR: Run `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
