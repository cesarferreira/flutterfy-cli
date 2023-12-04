require 'httparty'
require 'json'
require 'colorize'
require 'terminal-table'
require 'cfpropertylist'

class Utils

  def self.highest_app_version(data)
    data.map{ |o| o['mobile_app_version_number'] }.max
  end
  
  def self.highest_commit_number
    max_version = execute 'echo `git rev-list --full-history --all | wc -l`'
  end

  def self.replace_bundle(bundle_id, file_path)
    text = File.read(file_path)
    new_contents = text.gsub(/PRODUCT_BUNDLE_IDENTIFIER = (.*);/, "PRODUCT_BUNDLE_IDENTIFIER = #{bundle_id};")
    File.open(file_path, "w") {|file| file.puts new_contents }
  end

  def self.run_fastlane_beta
    Dir.chdir("./ios/") do
      Utils.execute "bundle exec pod install"
      Utils.execute "bundle exec fastlane ios beta"
    end
  end

  def self.update_fastlane_appfile_ios(bundle_id)
    file_path = 'ios/fastlane/AppFile'
    text = File.read(file_path)
    new_contents = text.gsub(/app_identifier((.*))/, "app_identifier(\"#{bundle_id}\")")
    File.open(file_path, "w") {|file| file.puts new_contents }
  end

  def self.update_fastlane_appfile_android(bundle_id)
    file_path = 'android/fastlane/AppFile'
    text = File.read(file_path)
    new_contents = text.gsub(/package_name((.*))/, "package_name(\"#{bundle_id}\")")
    File.open(file_path, "w") {|file| file.puts new_contents }
  end

  def self.update_android_manifest_packages(bundle_id)

    file_paths = [
      'android/app/src/main/AndroidManifest.xml',
      'android/app/src/debug/AndroidManifest.xml',
      'android/app/src/profile/AndroidManifest.xml',
    ]

    file_paths.each do |file_path|
      text = File.read(file_path)
      new_contents = text.gsub(/package=(.*)/, "package=\"#{bundle_id}\">")
      File.open(file_path, "w") {|file| file.puts new_contents }
    end
    

    activity_path = 'android/app/src/main/kotlin/fitfans/fitfans/MainActivity.kt'
    # package fitfans.francescajade

    text = File.read(activity_path)
    new_contents = text.gsub(/package (.*)/, "package #{bundle_id}")
    File.open(activity_path, "w") {|file| file.puts new_contents }
  end

  # UPDATE FASTLANE CONFIG
  def self.update_appfile(bundle_id)
    text = File.read('ios/fastlane/AppFile')
    new_contents = text.gsub(/app_identifier = (.*);/, "app_identifier(\"#{bundle_id}\")")
    File.open(file_path, "w") {|file| file.puts new_contents }
  end

  def self.replace_launcher_icon(logo_url)
    system("wget '#{logo_url}' -O ./assets/logo.png")  
    system("dart run flutter_launcher_icons")
  end

  def self.generate_splash_screen(watermark_url, color, is_powered_by_on)
    system("wget '#{watermark_url}' -O ./assets/logo-watermark.png")
    file_path = './splash.yaml'
    text = File.read(file_path)
    
    # color
    text = text.gsub(/(.*)color:(.*)/, "  color: \"#{color}\"")

    powered_by_path = 'assets/powered-by.png'
    puts "is_powered_by_on: " + is_powered_by_on.to_s
    # powered_by_on
    if is_powered_by_on
      text = text.gsub(/(.*)branding:(.*)/, "  branding: #{powered_by_path}")
    else
      text = text.gsub(/(.*)branding:(.*)/, "  #branding: #{powered_by_path}")
    end

    File.open(file_path, "w") {|file| file.puts text }

    system("dart run flutter_native_splash:create --path=splash.yaml")
  end

  def self.create_env_file(data)
    content = JSON.parse(data)['data'];
    array = []
    content.each do |key, value|
      array.push "#{key.upcase}=#{value}"
    end

    File.open(".env", "wb") { |f| f.write(array.join("\n")) }
  end

def self.update_local_config
    config = Utils.read_config
    remote_config, response = Creators.get_config_for(config["subdomain"])

    Utils.save_local_config(response.body)
    Utils.create_env_file(response.body)
end
  
  def self.save_local_config(data)
    File.open("config.json", "w") do |f|
      f.write(JSON.pretty_generate(JSON.parse(data)))
    end
  end

  def self.update_info_plist(file_path, client_id) 
    plist = CFPropertyList::List.new(:file => file_path)
    data = CFPropertyList.native_types(plist.value)

    reverse_id = client_id.split(".").reverse().join(".")
    data["CFBundleURLTypes"][0]["CFBundleURLSchemes"][0] = reverse_id

    newplist = CFPropertyList::List.new
    newplist.value = CFPropertyList.guess(data)

    newplist.save(file_path, CFPropertyList::List::FORMAT_XML, { :formatted => true } )

  end

  
  def self.update_google_services(file_path, bundle_id, client_id, google_app_id) 
    plist = CFPropertyList::List.new(:file => file_path)
    data = CFPropertyList.native_types(plist.value)
    
    data["BUNDLE_ID"] = bundle_id
    data["CLIENT_ID"] = client_id
    data["REVERSED_CLIENT_ID"] = client_id.split(".").reverse().join(".")
    data["GOOGLE_APP_ID"] = google_app_id
    
    newplist = CFPropertyList::List.new
    newplist.value = CFPropertyList.guess(data)
    
    newplist.save(file_path, CFPropertyList::List::FORMAT_XML, { :formatted => true } )
    
  end

  def self.read_config
    require 'json'
    file = File.read('./config.json')
    JSON.parse(file)["data"]
  end

  def self.is_fitfans_project
    File.file?('./config.json')
  end

  def self.interrupt_if_non_fitfans_project
    abort("This is not a Fitfans project...".red)  if !is_fitfans_project
  end

  def self.title(text)
    puts ""
    puts "==> ".bold.blue + text.bold
    puts ""
  end

  def self.configure_flutter
    system('flutterfire configure -p "fit-fans" -y')
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