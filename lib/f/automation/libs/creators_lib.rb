# frozen_string_literal: true

# require "httparty"
require "json"
require "colorize"
require "terminal-table"

class Creators
  # def self.create_new_app(subdomain, bundle_id, app_name)
  #   # TODO: get config and use the values from there, easy!!
  #   require "tmpdir"
  #   Dir.mktmpdir("fitfans_") do |tmpdir|
  #     Utils.title "Cloning #{subdomain.green.bold} into a temporary directory"
  #     Utils.execute "git clone #{@cloneable_url} #{tmpdir}"
  #     Dir.chdir tmpdir

  #     # switch_to X
  #     Utils.title "Checkout #{subdomain.green.bold}"
  #     Creators.switch_to subdomain

  #     Utils.title "Creating #{app_name.green.bold} (#{bundle_id.green.yellow}) in iTunes Connect"
  #     Creators.create_app(bundle_id, app_name)

  #     Utils.title "Release #{subdomain.green.bold} to testflight"
  #     Utils.run_fastlane_beta
  #   end
  # end

  def self.create_app(bundle_id, app_name)
    Utils.execute "bundle exec fastlane ios create_new_app app_identifier:\"#{bundle_id}\" app_name:\"#{app_name}\""
  end
end
