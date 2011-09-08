require 'fileutils'
module Fullstop
  module CLI
    include FileUtils
    def main(repo,checkout_dir)
      checkout_dir = ENV['HOME'] if checkout_dir.nil?

      sh { mkdir_p checkout_dir } or
        raise "Problem creating directory #{checkout_dir}"
      sh { chdir checkout_dir } or
        raise "Problem changing to directory #{checkout_dir}"

      sh("git clone #{repo} dotfiles") or
        raise "Problem checking out #{repo} into #{checkout_dir}/dotfiles"

      dotfiles_in(checkout_dir) do |file| 
        sh { ln file,'.' } or
          raise "Problem symlinking #{file} into #{checkout_dir}"
      end
    end

    def sh(command=nil)
      if command.nil?
        begin
          yield
          return true
        rescue
          return false
        end
      else
        return system(command)
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
