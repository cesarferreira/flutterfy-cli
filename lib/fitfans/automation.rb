# frozen_string_literal: true

require_relative "automation/version"
require_relative "automation/libs/creators_lib"
require_relative "automation/libs/utils_lib"
require 'launchy'

module Fitfans
  module Automation
    class Main
      def initialize(arguments)
        # TODO: join arguments and match them one by one
        # when "generate icons"
        # when "generate assets"
        # when "generate network layer"
        # when "generate networklayer"
        # when "release beta"
        # when "release production"
        case arguments[0]
        when "generate-network-layer" then generate_network_layer(arguments)
        when "generate-icons" then generate_icons(arguments)
        when "generate-assets" then generate_assets(arguments)
        when "generate-splash-screen" then generate_splash_screen(arguments)
        when "update-local-config" then update_local_config(arguments)
        when "creators" then list_creators(arguments)
        when "release" then release(arguments)
        when "mass-release" then mass_release(arguments)
        when "clean" then clean_rebuild(arguments)
        when "co", "checkout", "change_to", "switch" then switch_to(arguments)
        when "who" then who_am_i(arguments)
        when "deploy" then deploy(arguments)
        when "max" then Utils.highest_app_version
        when "firebase" then Utils.configure_flutter
        when "create" then create(arguments)
        when "money" then money(arguments) # TODO: doesnt work yet
        else

          trainer, pattern_found = detect_pattern(arguments.join(' '), "swagger")

          if pattern_found
            Launchy.open("https://#{trainer}.fitfans.me/admin/api-docs/index.html")
            return
          end

          trainer, pattern_found = detect_pattern(arguments.join(' '), "admin")

          if pattern_found
            Launchy.open("https://#{trainer}.fitfans.me/admin/app_configuration/general")
            return
          end

          puts "Dont recognise the command"
        end
      end

      def list_creators(arguments)
        creators = Creators.get_creators(arguments[1])
        max = Utils.highest_app_version(creators)
        Creators.print_fancy_table(creators, max)
      end

      def create(arguments)
        # Utils.interrupt_if_non_fitfans_project

        if arguments.length != 3
          puts "Required 2 parameters".red
          exit
        end

        bundle_id = arguments[1]
        app_name = arguments[2]

        puts "gonna create #{bundle_id} #{app_name}"
        # Creators.create_new_app(bundle)
      end

      def update_local_config(arguments)
        Utils.title 'Updating config...'
        Utils.update_local_config
        config = Utils.read_config
        puts JSON.pretty_generate(config)
        puts "done."
      end

      def detect_pattern(input, target)
        pattern = /(\w+) --open #{Regexp.escape(target)}/
        match = pattern.match(input)
      
        if match
          trainer = match[1]
          return trainer, true
        else
          return nil, false
        end
      end

      #
      # release beta
      #
      def release(arguments)
        if arguments.length == 1
          puts "Required 2 parameters".red
          exit
        end

        if arguments[1] == "beta"
          Utils.interrupt_if_non_fitfans_project
          Utils.run_fastlane_beta
        else
          puts "Not ready for #{arguments[1].red} yet"
        end
      end

      # TODO: just fake data at the moment
      def money(arguments)
        bundle = arguments[1]
        puts "=> #{"$843".green}/MRR | #{"$12,978".green} total revenue"
      end

      def who_am_i(arguments)
        Utils.interrupt_if_non_fitfans_project
        Creators.who_am_i
      end

      def mass_release(arguments)
        # TODO: ONLY RELEASE if they're BEHIND the MAX?
        active_creators = Creators.get_creators "active"
        max = Utils.highest_app_version(active_creators)
        Creators.print_fancy_table(active_creators, max)

        active_creators.each { |x|
          Creators.deploy_in_temporary_folder x["subdomain"]
          Dir.chdir "/tmp/"
          # sleep(5)
        }
      end

      def generate_network_layer(arguments)
        Utils.interrupt_if_non_fitfans_project
        system("dart run build_runner build --delete-conflicting-outputs")
      end

      def generate_icons(arguments)
        Utils.interrupt_if_non_fitfans_project
        config = Utils.read_config
        # puts config.logo_url
        Utils.replace_launcher_icon(config['logo_url'])
      end

      def generate_assets(arguments)
        Utils.interrupt_if_non_fitfans_project
        Utils.execute "fluttergen -c pubspec.yaml"
      end

      def generate_splash_screen(arguments)
        Utils.interrupt_if_non_fitfans_project
        config = Utils.read_config
        require 'json'
        puts JSON.pretty_generate(config)
        Utils.title 'Generating splash screen'
        Utils.generate_splash_screen(config["wordmark_url"], config["colour_tint"], config["powered_by_on"])
        
        Utils.title 'splash.yaml'
        puts File.read('./splash.yaml')

      end

      #
      # CLEAN EVERYTHING
      #
      def clean_rebuild(arguments)
        # Utils.interrupt_if_non_fitfans_project

        Utils.execute "bundle install"
        Utils.execute "flutter clean"
        Utils.execute "flutter pub get"
        Dir.chdir("./ios/") do
          Utils.execute "bundle install"
          Utils.execute "rm -rf Podfile.lock"
          Utils.execute "bundle exec pod install"
        end
      end

      def switch_to(arguments)
        if arguments.length != 2
          puts "please provide the creators subdomain".red
          exit
        end

        Creators.switch_to arguments[1]
      end

      def deploy(arguments)
        if arguments.length != 2
          puts "please provide the creators subdomain".red
          exit
        end

        # TODO: check if current git directory is dirty?

        subdomain = arguments[1]

        Utils.title "Going do deploy " + subdomain.green.bold

        Creators.deploy_in_temporary_folder subdomain
      end
    end

    # class Error < StandardError; end
    # Your code goes here...
  end
end
