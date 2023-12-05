require 'httparty'
require 'json'
require 'colorize'
require 'terminal-table'
require 'cfpropertylist'

class Utils


  def self.run_fastlane(lane)
    Dir.chdir("./ios/") do
      Utils.execute "bundle exec pod install"
      Utils.execute "bundle exec fastlane #{lane}"
    end
  end

  # TODO: bump a build number


  def self.replace_launcher_icon()
    # system("wget '#{logo_url}' -O ./assets/logo.png")  
    system("dart run flutter_launcher_icons")
  end

  def self.generate_splash_screen(watermark_url, color, is_powered_by_on)
    system("dart run flutter_native_splash:create --path=splash.yaml")
  end

  # TODO: replace with 
  def self.is_flutter_project
    File.file?('./pubspec.yaml')
  end

  def self.interrupt_if_non_flutter_project
    abort("This is not a flutter project...".red)  if !is_flutter_project
  end
    
  def self.title(text)
    puts ""
    puts "==> ".bold.blue + text.bold
    puts ""
  end

  def self.configure_fastlane
    system('flutterfire configure -y')
  end

  def self.execute(command)
    is_success = system command
    # is_success = Bundler::system command
    unless is_success
      puts "\n\n======================================================\n\n"
      puts ' Something went wrong while executing this:'.red
      puts "  $ #{command}\n".yellow
      puts "======================================================\n\n"
      exit 1
    end
  end
end