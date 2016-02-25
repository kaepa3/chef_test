#
# Cookbook Name:: yamazaki
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

install_root = "/home/vagrant"

%w(git ruby).each do |pack_name|
  package "#{pack_name}" do
    not_if 'which #{pack_name}'
    action :install
  end
end
%w(zlib1g-dev libreadline-dev libyaml-dev).each do |pack_name|
  package pack_name.to_s do
    not_if "which #{pack_name}"
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
    rbenv install 2.3.0
    rbenv rehash
    rbenv grobal 2.3.0
  EOS
end
