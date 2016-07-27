# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'


##
# Message Classes
#
class Configuration < ::Protobuf::Message
  class Shortcut < ::Protobuf::Message; end
  class Link < ::Protobuf::Message; end

end



##
# Message Fields
#
class Configuration
  class Shortcut
    required :string, :shortcut, 1
    required :string, :command, 2
    repeated :string, :tag, 3
    optional :string, :description, 4
    optional :bool, :function, 5
  end

  class Link
    repeated :string, :tag, 1
    required :string, :output, 2
  end

  required :string, :version, 1
  repeated ::Configuration::Shortcut, :shortcuts, 2
  repeated ::Configuration::Link, :links, 3
end

