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
          when "bump" then bump(arguments) # TODO: bump a build number
          when "help" then help(arguments)
          else
            arguments[0].nil? ? help(arguments) : puts("Dont recognise the command".red)
          
          end
      end

      # when "bump" then clean_rebuild(arguments) # TODO: bump a build number
        
      def help(arguments)
        binary_name = "f"
        # Define the rows of the table
        rows = []
        rows << ["#{binary_name} clean".green, 'Deep cleans the project and rebuilds it.']
        rows << :separator
        rows << ["#{binary_name} generate swagger".green, 'Executes a function to generate a Swagger (OpenAPI) client.']
        rows << ["#{binary_name} generate icon".green, 'Generates the icons for the app.']
        rows << ["#{binary_name} generate assets".green, 'Initiates asset generation and management. (using "flutter_launcher_icons")']
        rows << :separator
        rows << ["#{binary_name} open apple".green, 'Opens appstoreconnect website.']
        rows << ["#{binary_name} open android".green, 'Opens play console website.']
        rows << :separator
        rows << ["#{binary_name} release beta".green, 'Initiates the process to release the current build to the beta track.']
        rows << ["#{binary_name} release release".green, 'Initiates the process to release the current build to the production track.']
        rows << :separator
        rows << ["#{binary_name} help".green, 'Shows a table with all the available commands.']
        # Create a table
        table = Terminal::Table.new :headings => ['Command', 'Description'], :rows => rows

        puts table
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
        Utils.interrupt_if_non_flutter_project

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
        when "beta" then Utils.run_fastlane('ios beta')
        when "release" then Utils.run_fastlane('ios release')
        else
          puts "Not ready for #{arguments[1].red} yet"
        end
      end

      def generate_network_layer(arguments)
        Utils.interrupt_if_non_flutter_project
        system("dart run build_runner build --delete-conflicting-outputs")
      end
      
      def generate_icons(arguments)
        Utils.interrupt_if_non_flutter_project
        system("dart run flutter_launcher_icons")
      end 

      def bump(arguments)
        Utils.interrupt_if_non_flutter_project
        system(File.join(__dir__, "scripts/bump_version.sh pubspec.yaml"))
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
