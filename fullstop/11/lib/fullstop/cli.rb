require 'fileutils'

module Fullstop
  include FileUtils
  class CLI
    DOTFILES = 'dotfiles'

    def self.main(repo,link_dir)
      chdir link_dir
      system("git clone #{repo} #{DOTFILES}")

      dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

    def self.dotfiles_in(cloned_repo)
      Dir["#{cloned_repo}/{*,.*}"].reject { |file|
        %w(. ..).include? File.basename(file) 
      }.each do |file| 
        yield file
      end
    end
  end
end
