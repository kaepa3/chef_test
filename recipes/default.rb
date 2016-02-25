#
# Cookbook Name:: yamazaki
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

install_root = "/home/vagrant"

%w(git ruby apt).each do |pack_name|
  package "#{pack_name}" do
    action :install
  end
end

package 'apt-get' do
  action :update
end

%w(curl g++ zlib1g-dev libreadline-dev libyaml-dev libssl-dev).each do |pkg|
  package pkg do
    action :install
  end
end
bash "download rbenv" do
  not_if 'which rbenv'
  code <<-"EOS"
    git clone https://github.com/sstephenson/rbenv.git "#{install_root}"/.rbenv
    sudo echo "export PATH=\"#{install_root}\"/.rbenv/bin:$PATH" >> /etc/profile
    sudo echo ' eval "$(rbenv init -)"' >> /etc/profile
    chmod -R a+wr "#{install_root}"/.rbenv
    source /etc/profile
  EOS
end

bash "download ruby-build" do
  not_if { File.exist? "#{install_root}/.rbenv/plugins/ruby-build" }
  code <<-"EOS"
    git clone https://github.com/sstephenson/ruby-build.git "#{install_root}"/.rbenv/plugins/ruby-build
    chmod -R a+wr "#{install_root}"/.rbenv/plugins/
    source /etc/profile
  EOS
end

bash "install ruby & grobal" do
  not_if { File.exist? "#{install_root}/.rbenv/versions/2.3.0" }
  code <<-"EOS"
    source /etc/profile
    CONFIGURE_OPTS="--disable-install-rdoc" rbenv install 2.3.0
    rbenv rehash
    rbenv global 2.3.0
  EOS
end
