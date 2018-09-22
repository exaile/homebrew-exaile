class Exaile < Formula
  include Language::Python::Virtualenv

  desc "Cross platform music player"
  homepage "https://www.exaile.org"
  url "https://github.com/exaile/exaile/releases/download/4.0.0-rc2/exaile-4.0.0rc2.tar.gz"
  sha256 "b57ec210ad28ad2bbbe7097fe5eb20a99d1421b3e63b80d1c823a36057a56c53"

  head "https://github.com/exaile/exaile.git"

  depends_on "berkeley-db"
  depends_on "gtk+3"
  depends_on "adwaita-icon-theme"
  #depends_on "gtk-mac-integration"
  depends_on "py2cairo"
  depends_on "pygobject3" => "with-python@2"
  depends_on "gstreamer"
  depends_on "gst-plugins-base"
  depends_on "gst-plugins-good"
  depends_on "gst-plugins-ugly" => :recommended
  depends_on "gst-plugins-bad" => :recommended

  resource "bsddb3" do
    url "https://files.pythonhosted.org/packages/a9/f3/d8d1f8d998436256b3abcd924570d54f9508fa313c4e27bfa663f1bb72f2/bsddb3-5.3.0.tar.gz"
    sha256 "4619f6189e5f94e337c62ae398ccb9c25568f3c3cab39970a4ea7625d38f8b3e"
  end

  resource "feedparser" do
    url "https://files.pythonhosted.org/packages/91/d8/7d37fec71ff7c9dbcdd80d2b48bcdd86d6af502156fc93846fb0102cb2c4/feedparser-5.2.1.tar.bz2"
    sha256 "ce875495c90ebd74b179855449040003a1beb40cd13d5f037a0654251e260b02"
  end

  resource "musicbrainzngs" do
    url "https://files.pythonhosted.org/packages/63/cc/67ad422295750e2b9ee57c27370dc85d5b85af2454afe7077df6b93d5938/musicbrainzngs-0.6.tar.gz"
    sha256 "28ef261a421dffde0a25281dab1ab214e1b407eec568cd05a53e73256f56adb5"
  end

  resource "mutagen" do
    url "https://files.pythonhosted.org/packages/2c/6a/0b2caf9364db074b616b1b8c26ce7166a883c21b0e40bd50f6db02307afe/mutagen-1.40.0.tar.gz"
    sha256 "b2a2c2ce87863af12ed7896f341419cd051a3c72c3c6733db9e83060dcadee5e"
  end

  resource "pylast" do
    url "https://files.pythonhosted.org/packages/64/ab/973b67a9dfd27d6356c5e275d7d369b35879fe88bda6e1b20453b4d08511/pylast-1.8.0.tar.gz"
    sha256 "85f8dd96aef0ccba5f80379c3d7bc1fabd72f59aebab040daf40a8b72268f9bd"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"
    sha256 "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"
  end


  resource "pyobjc-core" do
    url "https://files.pythonhosted.org/packages/7e/03/303a5c7f7c3d3af811eba44b32ef957e570be4d5c5b656c0b44ece6191e0/pyobjc-core-3.2.1.tar.gz"
    sha256 "848163845921e5a61e069ea42bab06ac73278f5a09b4e9cedd6a3eac6712ff2c"
  end

  resource "pyobjc-framework-ApplicationServices" do
    url "https://files.pythonhosted.org/packages/a1/8d/77c2b2741865a4781ae8f52e5cd802b728e705f3c7fa017e9a7866ad999e/pyobjc-framework-ApplicationServices-3.2.1.tar.gz"
    sha256 "567bf6e2083ad557e0b3845a25c09068824dee1393d1ce07ce31c6f85b436448"
  end

  resource "pyobjc-framework-Cocoa" do
    url "https://files.pythonhosted.org/packages/f2/91/9a1847a442a8cd9f7e7ed183561c57b8644fd582f7ede0c5c3dc81407533/pyobjc-framework-Cocoa-3.2.1.tar.gz"
    sha256 "8215a528b552588f0024df03ef1c5f8edfa245301888c384f5b8c231f4c89431"
  end

  resource "pyobjc-framework-Quartz" do
    url "https://files.pythonhosted.org/packages/dd/07/aff85c2987faa9ad16ce1761a053c8c7815b679cd7482e3fd6af07ae749f/pyobjc-framework-Quartz-3.2.1.tar.gz"
    sha256 "328f6c3f2431be139fa54c166190d3cd4e1bae78243c7d0ace9a7be3fa3088ad"
  end

  def caveats
    "Run 'exaile-app-install' to install Exaile to the system's applications"
  end

  def install
    ENV["BERKELEYDB_DIR"] = Formula["berkeley-db"].path

    venv = virtualenv_create(libexec)
    venv.pip_install resources
    
    ENV["DEFAULTARGS"] = "--no-dbus --no-hal"
    system "make", "PREFIX=#{prefix}", "PYTHON2_CMD=#{libexec}/bin/python", "install"

    #
    # Add hacky script to create an .app for Exaile
    #

    (share/"exaile/data/images").mkpath()
    cp "data/images/exaile.icns", share/"exaile/data/images"

    (bin/"exaile-app-install").write <<~APPINSTALL
      #!/bin/bash -e

      APPDIR=/Applications/Exaile.app
      ROOT=$(dirname "$(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' "$0")")
      
      if [ "$1" == "--local" ]; then
          APPDIR=~/Applications/Exaile.app
      elif [ "$1" == "--help" ] || [ ! "$1" == "" ]; then
          echo "Usage: $0 [--local]"
          exit 1
      fi
      
      rm -rf $APPDIR
      mkdir -p $APPDIR/Contents/MacOS
      mkdir -p $APPDIR/Contents/Resources
      
      echo "#!/usr/bin/env bash" > $APPDIR/Contents/MacOS/Exaile
      echo "exec ${ROOT}/exaile \"\$@\"" >> $APPDIR/Contents/MacOS/Exaile
      chmod +x $APPDIR/Contents/MacOS/Exaile
      
      cat << EOF > $APPDIR/Contents/Info.plist
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>CFBundleExecutable</key>    <string>Exaile</string>
          <key>CFBundleSignature</key>     <string>EXAL</string>
          <key>CFBundlePackageType</key>   <string>APPL</string>
          <key>CFBundleVersion</key>       <string>#{version}</string>
          <key>CFBundleIdentifier</key>    <string>org.exaile.exaile</string>
          <key>CFBundleDisplayName</key>   <string>Exaile</string>
          <key>CFBundleName</key>          <string>Exaile</string>
          <key>CFBundleIconFile</key>      <string>Exaile</string>
      </dict>
      </plist>
      EOF
      
      cp $ROOT/../share/exaile/data/images/exaile.icns $APPDIR/Contents/Resources/Exaile.icns
      
      echo "OK"    
    APPINSTALL
    (bin/"exaile-app-install").chmod(0555)

  end

end