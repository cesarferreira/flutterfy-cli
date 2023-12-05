# frozen_string_literal: true

require_relative "automation/version"
require_relative "automation/libs/creators_lib"
require_relative "automation/libs/utils_lib"
require 'launchy'

module F
  module Automation
    class Main
      def initialize(arguments)
    
        case arguments[0]
         
          when "generate" then handle_generate_command(arguments)
          when "release" then release(arguments)
          when "clean" then clean_rebuild(arguments)
          when "open" then handle_open_command(arguments)
          when "generate" then handle_open_command(arguments)
          when "bump" then clean_rebuild(arguments) # TODO: bump a build number
          when "help" then help(arguments)
          else
            puts "Dont recognise the command"
        end
      end

      def handle_open_command(arguments)
        case arguments[1]
          when "apple" then Launchy.open("https://appstoreconnect.apple.com/apps")
          when "android" then Launchy.open("https://play.google.com/console/u/0/developers/5802616250731787476/app-list")
          else
            puts "Dont recognise the command"
        end
      end  
      
      def handle_generate_command(arguments)
        case arguments[1]
          when "swagger" then generate_network_layer(arguments)
          when "icon" then generate_icons(arguments)
          when "assets" then generate_assets(arguments)
          else
            puts "Dont recognise the command"
        end
      end

      #
      # release
      #
      def release(arguments)
        Utils.interrupt_if_non_flutter_project

        if arguments.length == 1
          puts "Required 2 parameters".red
          exit
        end

        case arguments[1]
        when "beta" then Utils.run_fastlane_beta
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
        rows << ['generate icon'.green, 'Runs the process to create and organize icon assets as per the specified arguments.']
        rows << :separator
        rows << ['generate assets'.green, 'Initiates asset generation and management based on the given arguments.']

        # Create a table
        table = Terminal::Table.new :headings => ['Command', 'Description'], :rows => rows

        # Print the table
        puts table
      end

      
      def generate_network_layer(arguments)
        Utils.interrupt_if_non_flutter_project
        system("dart run build_runner build --delete-conflicting-outputs")
      end
      
      def generate_icons(arguments)
        Utils.interrupt_if_non_flutter_project
        system("dart run flutter_launcher_icons")
      end

      def generate_assets(arguments)
        Utils.interrupt_if_non_flutter_project
        Utils.execute "fluttergen -c pubspec.yaml"
      end

      
      #
      # CLEAN EVERYTHING
      #
      def clean_rebuild(arguments)
        Utils.interrupt_if_non_flutter_project
        # flutter clean; rm -rf ios/Podfile.lock; flutter pub get; cd ios; pod install; cd ..
        Utils.execute "flutter clean"
        Utils.execute "flutter pub get"
        Dir.chdir("./ios/") do
          # Utils.execute "bundle install"
          Utils.execute "rm -rf Podfile.lock"
          Utils.execute "bundle exec pod install"
        end
      end

      
    end

    # class Error < StandardError; end
    # Your code goes here...
  end
end
