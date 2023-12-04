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
        when "generate swagger" then generate_network_layer(arguments)
        when "generate icons" then generate_icons(arguments)
        when "generate assets" then generate_assets(arguments)
        # when "generate-splash-screen" then generate_splash_screen(arguments)
        when "release beta" then release(arguments)
        when "clean" then clean_rebuild(arguments)
        when "help" then help(arguments)
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
          Utils.run_fastlane_beta
        else
          puts "Not ready for #{arguments[1].red} yet"
        end
      end
      
      def help(arguments)
        # Define the rows of the table
        rows = []
        rows << ['clean'.green, 'Completely wipes all existing data from the system.']
        rows << :separator
        rows << ['release beta'.green, 'Initiates the process to release the current build to the beta track for testing.']
        rows << :separator
        rows << ['generate swagger'.green, 'Executes a function to generate a Swagger (OpenAPI) specification based on provided arguments.']
        rows << :separator
        rows << ['generate icons'.green, 'Runs the process to create and organize icon assets as per the specified arguments.']
        rows << :separator
        rows << ['generate assets'.green, 'Initiates asset generation and management based on the given arguments.']


        # Create a table
        table = Terminal::Table.new :headings => ['Command', 'Description'], :rows => rows

        # Print the table
        puts table
      end

      
      def generate_network_layer(arguments)
        Utils.interrupt_if_non_fitfans_project
        system("dart run build_runner build --delete-conflicting-outputs")
      end

      def generate_icons(arguments)
        # Utils.replace_launcher_icon(config['logo_url'])
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
        # flutter clean; rm -rf ios/Podfile.lock; flutter pub get; cd ios; pod install; cd ..
        Utils.execute "flutter clean"
        Utils.execute "flutter pub get"
        Dir.chdir("./ios/") do
          # Utils.execute "bundle install"
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
