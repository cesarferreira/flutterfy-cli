require "httparty"
require "json"
require "colorize"
require "terminal-table"

class Creators
  @bearer_token = "Bearer 76dd9216ea99225mR0PrJSCqDYQ3oI4BqNKjm9c0259db3361b6ef8cf0dea5c4ce473032392004dc10bc0f57"
  @cloneable_url = "git@github.com:cesarferreira/fitfans.git"

  #
  # Get all creators
  #
  def self.get_creators(status)
    url = "https://fitfans.me/api/creators"
    response = HTTParty.get(url, headers: { Authorization: @bearer_token })
    array = JSON.parse(response.body)["data"]

    if status.nil?
      array
    else
      array.select { |item| item["status"] == status }
    end
  end

  #
  # Get config for SUBDOMAIN
  #
  def self.get_config_for(subdomain)
    url = "https://" + subdomain + "." + "fitfans.me" + "/api/config"
    response = HTTParty.get(url, headers: { Authorization: @bearer_token })
    array = JSON.parse(response.body)["data"]
    [array, response]
  end

  #
  # Post updated version
  #
  def self.post_updated_version(subdomain, version_code, version_number)
    url = "https://" + subdomain + ".fitfans.me/api/config"

    result = HTTParty.patch(url,
                            :body => {
                              :mobile_app_version_code => version_number,
                              :mobile_app_version_number => version_code,
                            }.to_json,
                            :headers => {
                              "Content-Type" => "application/json",
                              "Authorization" => @bearer_token,
                            })

    # puts result
  end

  #
  # Print fancy table with creators
  #
  def self.print_fancy_table(data, highest_build_number)
    rows = []

    data.each { |x|
      app_name = x["app_name"]
      bundle_id = x["bundle_id"]
      subdomain = x["subdomain"]
      status = x["status"]

      if status == "active"
        status = status.green
        app_name = app_name.green
        bundle_id = bundle_id.green
        url = "https://" + subdomain.green + (subdomain.empty? ? "" : ".") + "fitfans.me"
      elsif status == "inactive"
        status = status.red
        url = "https://" + subdomain.red + (subdomain.empty? ? "" : ".") + "fitfans.me"
        app_name = app_name.red
        bundle_id = bundle_id.red
      else
        status = status.yellow
        app_name = app_name.yellow
        bundle_id = bundle_id.yellow
        url = "https://" + subdomain.yellow + (subdomain.empty? ? "" : ".") + "fitfans.me"
      end

      version_code = x["mobile_app_version_code"]
      version_number = x["mobile_app_version_number"]

      if !version_number.empty?
        # puts "#{max.to_i} - #{version_number}"
        difference = highest_build_number.to_i - version_number.to_i

        if difference == 0
          difference = "Up-to-date".green
        elsif difference > 0 && difference < 10
          difference = "behind by " + difference.to_s.yellow + " commit" + (difference > 1 ? "s" : "")
        else
          difference = "behind by " + difference.to_s.red + " commit" + (difference > 1 ? "s" : "")
        end
      else
        difference = ""
      end
      rows << [app_name, bundle_id, url, status, version_code, version_number, difference]
    }

    table = Terminal::Table.new :headings => ["app_name", "bundle_id", "url", "status", "code", "build", ""], :rows => rows

    puts table
  end

  def self.update_base_url(baseUrl)
    # lib/data/network/base_url.dart
    File.write('lib/data/network/base_url.dart', "String baseUrl() => '#{baseUrl}';")
  end
  
  def self.divider
    puts "\n-------------------------------------------------------------------------------------------------------\n"
  end

  # switch to another creator
  def self.switch_to(influencer)
    require "cfpropertylist"
    require_relative "utils_lib.rb"

    remote_config, response = get_config_for(influencer)

    Utils.save_local_config(response.body)
    Utils.create_env_file(response.body)

    rows = []

    app_name = remote_config["app_name"]
    subdomain = remote_config["subdomain"]
    logo_url = remote_config["logo_url"]
    watermark_url = remote_config["wordmark_url"]
    color = remote_config["colour_tint"]
    is_powered_by_on = remote_config["is_powered_by_on"]
    firebase_client_id = remote_config["firebase_mobile_client_id"]
    reverse_firebase_client_id = firebase_client_id.split(".").reverse().join(".")
    google_app_id = remote_config["firebase_mobile_google_app_id"]
    colored_url = "https://" + subdomain.green + (subdomain.empty? ? "" : ".") + "fitfans.me"
    url = "https://" + subdomain + (subdomain.empty? ? "" : ".") + "fitfans.me"
    # url = remote_config['base_url']
    bundle_id = remote_config["bundle_id"]

    rows << [app_name.green, bundle_id, colored_url]

    table = Terminal::Table.new :headings => ["app_name", "bundle_id", "url"], :rows => rows

    puts table

    puts ""

    Utils.execute "flutter pub get"

    # exit()

    #  UPDATE app package
    # puts "Changing package name to " + bundle_id.green + " ..."

    if app_name.include? "&"
      app_name.gsub!("&", "&amp;")
      # app_name.gsub!(/\s/, "&#x2007;")
      name = app_name
    else
      name = app_name
    end
   
    #  UPDATE app name
    Utils.title "Changing app name to " + app_name.green + " ..."
    system("dart run rename -t android --appname \"#{name}\"")
    system("dart run rename -t android --bundleId #{bundle_id}")
    
    
    system("dart run rename -t ios --appname \"#{name}\"")
    system("dart run rename -t ios --bundleId #{bundle_id}")

    divider

    # Replace AppFile
    puts ""
    Utils.title "Changing fastlane's AppFile..."

    Utils.update_fastlane_appfile_ios bundle_id
    Utils.update_fastlane_appfile_android bundle_id
    
    # update package names
    Utils.update_android_manifest_packages bundle_id

    puts "Done."

    divider

    # Update Google-services.plist
    Utils.title "Updating Google-services.plist..."
    Utils.update_google_services("ios/Runner/GoogleService-Info.plist", bundle_id, firebase_client_id, google_app_id)
    puts "Done."
    puts ""

    divider

    # Update info.plist
    puts ""
    Utils.title "Updating info.plist..."
    Utils.update_info_plist("ios/Runner/Info.plist", firebase_client_id)
    puts "Done."

    divider

    # Update base url
    puts ""
    Utils.title "Updating base url to #{url}..."
    self.update_base_url(url)
    puts "Done."

    divider


    # GENERATE ICONS
    # https://pub.dev/packages/flutter_launcher_icons
    puts ""
    Utils.title "Generating new icons..."
    Utils.replace_launcher_icon(logo_url)

    puts "Done."

    divider

    puts ""
    Utils.title "Generating new splash screen..."
    config = Utils.read_config
    Utils.generate_splash_screen(config["wordmark_url"], config["colour_tint"], config["powered_by_on"])
    # Utils.generate_splash_screen(watermark_url, color, is_powered_by_on)

    puts "Done."

    divider

    # Update project.pbxproj
    puts ""
    Utils.title "Updating project.pbxproj..."
    # TODO: this is irrelevant i think, we can use RENAME for it
    Utils.replace_bundle(bundle_id, "./ios/Runner.xcodeproj/project.pbxproj")

    puts "Done."

    divider

    puts ""
    Utils.title "Fetching firebase config..."
    Utils.configure_flutter
    puts "Done."
  end

  def self.who_am_i
    config = Utils.read_config

    creators = Creators.get_creators(nil)
    max = Utils.highest_app_version(creators)
    me = creators.select { |item| item["bundle_id"] == config["bundle_id"] }

    Creators.print_fancy_table(me, max)
  end

  def self.deploy_in_temporary_folder(subdomain)
    require "tmpdir"

    Dir.mktmpdir("fitfans_") do |tmpdir|
      Utils.title "Cloning #{subdomain.green.bold} into a temporary directory"
      Utils.execute "git config --global core.compression 0"
      Utils.execute "git clone #{@cloneable_url} #{tmpdir}"
      Dir.chdir tmpdir

      # switch_to X
      Utils.title "Checkout #{subdomain.green.bold}"
      Creators.switch_to subdomain

      who_am_i

      Utils.title "Release #{subdomain.green.bold} to testflight"
      Utils.run_fastlane_beta
    end
  end

  def self.create_new_app(subdomain, bundle_id, app_name)
    # TODO: get config and use the values from there, easy!!
    require "tmpdir"
    Dir.mktmpdir("fitfans_") do |tmpdir|
      Utils.title "Cloning #{subdomain.green.bold} into a temporary directory"
      Utils.execute "git clone #{@cloneable_url} #{tmpdir}"
      Dir.chdir tmpdir

      # switch_to X
      Utils.title "Checkout #{subdomain.green.bold}"
      Creators.switch_to subdomain

      Utils.title "Creating #{app_name.green.bold} (#{bundle_id.green.yellow}) in iTunes Connect"
      Creators.create_app(bundle_id, app_name)

      Utils.title "Release #{subdomain.green.bold} to testflight"
      Utils.run_fastlane_beta
    end
  end

  def self.create_app(bundle_id, app_name)
    Utils.execute "bundle exec fastlane ios create_new_app app_identifier:\"#{bundle_id}\" app_name:\"#{app_name}\""
  end
end
