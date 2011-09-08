require 'fileutils'
module Fullstop
  module CLI
    include FileUtils
    def main(repo,checkout_dir)
      checkout_dir = ENV['HOME'] if checkout_dir.nil?

      mkdir_p checkout_dir
      chdir checkout_dir

      %x[git clone #{repo} dotfiles]

      dotfiles_in(checkout_dir) do |file| 
        ln file,'.'
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
