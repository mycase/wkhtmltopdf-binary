###
# wkhtmltopdf_binary_gem Copyright 2013 The University of Iowa
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at http://www.apache.org/licenses/LICENSE-2.0

require 'rbconfig'
require 'zlib'

suffix = case RbConfig::CONFIG['host_os']
         when /linux/
           os = `. /etc/os-release 2> /dev/null && echo ${ID}_${VERSION_ID}`.strip

           os_based_on_ubuntu_16_04 = os.start_with?('ubuntu_16.') || os.start_with?('ubuntu_17.')
           os = 'ubuntu_16.04' if os_based_on_ubuntu_16_04

           os_based_on_ubuntu_18_04 = os.start_with?('ubuntu_18.') || os.start_with?('ubuntu_19.') || os.start_with?('elementary') || os.start_with?('linuxmint') || os.start_with?('pop') || os.start_with?('zorin')
           os = 'ubuntu_18.04' if os_based_on_ubuntu_18_04

           os_based_on_ubuntu_20_04 = os.start_with?('ubuntu_20.')
           os = 'ubuntu_20.04' if os_based_on_ubuntu_20_04

           os_based_on_centos_6 = (os.empty? && File.read('/etc/centos-release').start_with?('CentOS release 6')) || (os.start_with?('amzn_') && !os.start_with?('amzn_2'))
           os = 'centos_6' if os_based_on_centos_6

           os_based_on_centos_7 = os.start_with?('amzn_2')
           os = 'centos_7' if os_based_on_centos_7

           os_based_on_debian_9 = (/(debian_9|deepin)/ =~ os)
           os = 'debian_9' if os_based_on_debian_9

           os_based_on_debian = !os_based_on_debian_9 && os.start_with?('debian')
           os = 'debian_10' if os_based_on_debian

           os_based_on_archlinux = os.start_with?('arch_') || os.start_with?('manjaro_')
           os = 'archlinux' if os_based_on_archlinux

           architecture = RbConfig::CONFIG['host_cpu'] == 'x86_64' ? 'amd64' : 'i386'

           "#{os}_#{architecture}"
         when /darwin/
           'macos_cocoa'
         else
           'unknown'
         end

suffix = ENV['WKHTMLTOPDF_HOST_SUFFIX'] unless ENV['WKHTMLTOPDF_HOST_SUFFIX'].to_s.empty?

binary = "./bin/wkhtmltopdf_#{suffix}"

if File.exist?("#{binary}.gz") && !File.exist?(binary)
  File.open binary, 'wb', 0o755 do |file|
    Zlib::GzipReader.open("#{binary}.gz") { |gzip| file << gzip.read }
  end
end

