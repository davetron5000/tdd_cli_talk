require 'fileutils'
module Fullstop
  module CLI
    #include FileUtils
    def main(repo,checkout_dir)
      checkout_dir = ENV['HOME'] if checkout_dir.nil?

      mkdir_p checkout_dir or raise "Problem creating directory #{checkout_dir}"
      chdir checkout_dir or raise "Problem changing to directory #{checkout_dir}"

      system("git clone #{repo} dotfiles") or
        raise "Problem checking out #{repo} into #{checkout_dir}/dotfiles"

      dotfiles_in(checkout_dir) do |file| 
        ln file,'.' or raise "Problem symlinking #{file} into #{checkout_dir}"
      end
    end

    def method_missing(sym,*args)
      if FileUtils.respond_to? sym
        begin
          FileUtils.send(sym,*args)
          true
        rescue
          false
        end
      else
        super(sym,*args)
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
