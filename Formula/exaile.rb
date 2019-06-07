class Exaile < Formula
  include Language::Python::Virtualenv

  desc "Cross platform music player"
  homepage "https://www.exaile.org"
  url "https://github.com/exaile/exaile/releases/download/4.0.0/exaile-4.0.0.tar.gz"
  sha256 "009dc273dc2af3b3e828452f7775eb16d495ce930ea465ae95e928bb3b62695b"

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
    url "https://files.pythonhosted.org/packages/73/36/403769823a696dd8a02b5b3f74ccfa603be8575f2d5b70ba8eba73af7375/pyobjc_core-5.2-cp27-cp27m-macosx_10_9_x86_64.whl"
    sha256 "a6f65fb313e5e1efab5c4b4591142a73af4ca52a2c39d98f540f42fc774e262e"
    @whl = true
  end

  resource "pyobjc-framework-ApplicationServices" do
    url "https://files.pythonhosted.org/packages/90/0d/fa04ab8ad24e3ed22d63f544a86b4ab56fee7f8cc6ceeaa27ea28235f80d/pyobjc_framework_ApplicationServices-5.2-py2.py3-none-any.whl"
    sha256 "e6edf4cb8a988e0772ea04e0abecc41a5d97419fbfa3d5ae65a97f7d21f6610c"
    @whl = true
  end

  resource "pyobjc-framework-Cocoa" do
    url "https://files.pythonhosted.org/packages/22/eb/d4b1c9e519b8f36dac1f8f538b46ecf8e697bf0f96504c12a9def52a812b/pyobjc_framework_Cocoa-5.2-cp27-cp27m-macosx_10_6_intel.whl"
    sha256 "3a2a7771e584858ee43faef08b9ca7c632c8c27a3d9e1bfd5dd1909d7c087ed8"
    @whl = true
  end

  resource "pyobjc-framework-Quartz" do
    url "https://files.pythonhosted.org/packages/af/c5/99c067190235ff45d0daf0b973b5575ad6cfd067c8b1e8939784f8d821cd/pyobjc_framework_Quartz-5.2-cp27-cp27m-macosx_10_6_intel.whl"
    sha256 "4e76f444445e2561c56c43d50a0001f9a62c5d2e9f06bc2c2847768929ded89c"
    @whl = true
  end

  def caveats
    "Run 'exaile-app-install' to install Exaile to the system's applications"
  end

  def whl_install(targets)
    targets = [targets] unless targets.is_a? Array
    system libexec/"bin/pip", "install",
                    "-v", "--no-deps", #"--no-binary", ":all:",
                    "--ignore-installed", *targets
  end

  def install
    ENV["BERKELEYDB_DIR"] = Formula["berkeley-db"].path

    venv = virtualenv_create(libexec)
    resource_srcs = []
    resource_whls = []

    resources.each do |r|
      if r.instance_variable_defined?("@whl")
        resource_whls.push(r)
      else
        resource_srcs.push(r)
      end
    end

    #
    # hack to install wheels so users don't need xcode installed
    #
    
    resource_whls.each do |t|
      t.stage {whl_install "#{Pathname.pwd}/#{File.basename(t.url)}"} 
    end

    venv.pip_install resource_srcs

    
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