#
# Cookbook Name:: passwordless
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
case node['platform']
when 'centos'
  package 'expect' do
#    version ''
    action :install
  end



  cookbook_file '/usr/local/bin/auto_pwdless.sh' do
    source 'auto_pwdless.sh'
    owner 'root'
    group 0
    mode '0755'
  end.run_action(:create)

  cookbook_file '/usr/local/bin/pwdless.exp' do
    source 'pwdless.exp'
    owner 'root'
    group 0
    mode '0755'
  end.run_action(:create)

  execute 'tty' do
	command "cp /etc/sudoers /etc/sudoers.`date +%Y%m%d%H%M`;chmod 755 /etc/sudoers;sed -i 's#^Defaults    requiretty#\\#Defaults    requiretty#' /etc/sudoers;chmod 440 /etc/sudoers;chown root.root /etc/sudoers;"
	action :run
    	only_if 'grep "^Defaults    requiretty" /etc/sudoers'
  end

  execute 'auto_pwdless.sh' do
    command "/usr/local/bin/auto_pwdless.sh #{node['passwordless']['user']} #{node['passwordless']['target_login_user']} #{node['passwordless']['target_login_pwd']} #{node['passwordless']['target_host']} "
    #command "/usr/local/bin/auto_pwdless.sh"
    action :run
  end

end
