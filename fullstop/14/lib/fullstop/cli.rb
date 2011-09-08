require 'fileutils'
module Fullstop
  module CLI
    include FileUtils
    def main(repo,checkout_dir)
      checkout_dir = ENV['HOME'] if checkout_dir.nil?

      begin
        mkdir_p checkout_dir
      rescue
        raise "Problem creating directory #{checkout_dir}"
      end
      begin
        chdir checkout_dir
      rescue
        raise "Problem changing to directory #{checkout_dir}"
      end

      unless system("git clone #{repo} dotfiles")
        raise "Problem checking out #{repo} into #{checkout_dir}/dotfiles"
      end

      dotfiles_in(checkout_dir) do |file| 
        begin
          ln file,'.'
        rescue
          raise "Problem symlinking #{file} into #{checkout_dir}"
        end
      end
    end

    def dotfiles_in(dir)
      Dir["#{dir}/dotfiles/{*,.*}"].each do |file|
        basename = File.basename(file)
        if basename != '.' && basename != '..'
          yield file
        end
      end
    end
  end
end
