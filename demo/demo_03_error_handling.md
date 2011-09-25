!SLIDE subsection
# Unhappy Path

!SLIDE smaller

    @@@Ruby
    def main(repo,link_dir)
      chdir link_dir
      %x[git clone #{repo} #{DOTFILES}]

      dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
        ln_s file,'.'
      end
    end

!SLIDE smaller

    @@@Ruby
    def main(repo,link_dir)
      chdir link_dir                    # <= !
      %x[git clone #{repo} #{DOTFILES}] # <= !

      dotfiles_in(File.join(link_dir,DOTFILES)) do |file|
        ln_s file,'.'                   # <= !
      end
    end

