#
# Cookbook Name:: yamazaki
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

install_root = "/home/vagrant"

group "rbenv" do
  action :create
  members "vagrant"
  append true
end

bash "apt-get-update-periodic" do
  code "apt-get update"
  ignore_failure true
end

%w(curl g++ zlib1g-dev libreadline-dev libyaml-dev libssl-dev).each do |pkg|
  package pkg do
    action :install
  end
end

%w(git ruby).each do |pack_name|
  package "#{pack_name}" do
    action :install
  end
end

git "#{install_root}/.rbenv" do
  repository "git://github.com/sstephenson/rbenv.git"
  reference "master"
  action :checkout
  user "#{node.user}"
  group "rbenv"
end

directory "#{install_root}/.rbenv/plugins" do
  owner "#{node.user}"
  group "rbenv"
  mode "0755"
  action :create
end

template "/etc/profile.d/rbenv.sh" do
  owner "#{node.user}"
  group "#{node.user}"
  mode 0644
  variables(
    :install_root => "#{install_root}/.rbenv"
  )
end

git "#{install_root}/.rbenv/plugins/ruby-build" do
  repository "git://github.com/sstephenson/ruby-build.git"
  reference "master"
  action :checkout
  user "#{node.user}"
  group "rbenv"
end

bash "ruby install" do
  not_if "source /etc/profile.d/rbenv.sh; rbenv versions | grep #{node.build}}"
  code "source /etc/profile.d/rbenv.sh; CONFIGURE_OPTS=\"--disable-install-rdoc\" rbenv install #{node.build}"
  user "#{node.user}"
  action :run
end

execute "ruby change" do
  command "source /etc/profile.d/rbenv.sh; rbenv global #{node.build};rbenv rehash"
  action :run
end
