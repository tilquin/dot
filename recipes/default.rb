%w(git zsh vim tmux autojump).each do |pkg|
  package pkg
end

me    = node['dot']['user']
group = node['dot']['group']
home  = "/home/#{me}"

directory "#{home}/Library" do
    owner me
    group group
    mode 0700
    action :create
end

directory "#{home}/.Trash" do
    owner me
    group group
    mode 0700
    action :create
end

git "#{home}/Library/dot" do
    repository "git://github.com/gyllstromk/dot.git"
    reference "master"
    enable_submodules true
    user me
    group group
    action :checkout
end

git "#{home}/.vim" do
    repository "git://github.com/gyllstromk/vim.git"
    reference "master"
    enable_submodules true
    user me
    group group
    action :checkout
end

link "#{home}/.vimrc" do
    to "#{home}/.vim/vimrc"
end

bash "chsh" do
  code "chsh #{me} -s /bin/zsh"
end

git "#{home}/.oh-my-zsh" do
    repository "git://github.com/robbyrussell/oh-my-zsh.git"
    user me
    group group
    action :checkout
end

etc = "#{home}/Library/dot/etc"

%w(gitconfig gitignore_global tmux-macosx.conf tmux.conf zprofile zshrc).each do |file|
    link "#{home}/.#{file}" do
        to "#{etc}/#{file}"
    end
end

#ruby_block "link_files" do
#    block do
#        Dir.foreach(etc).each do |file|
#            link "#{home}/.#{file}" do
#                to "#{etc}/#{file}"
#            end
#        end
#    end
#
#    action :create
#end
