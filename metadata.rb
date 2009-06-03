maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Configures chef"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "0.7"
recipe            "chef::client"
recipe            "chef::server"

attribute         "chef",
  :display_name => "",
  :description => "",
  :recipes => [ "chef" ],
  :default => ""

attribute         "client",
  :display_name => "",
  :description => "",
  :recipes => [ "chef" ],
  :default => ""

attribute         "indexer",
  :display_name => "",
  :description => "",
  :recipes => [ "chef" ],
  :default => ""

attribute         "server",
  :display_name => "",
  :description => "",
  :recipes => [ "chef" ],
  :default => ""
