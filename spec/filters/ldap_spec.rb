# encoding: utf-8

require_relative '../spec_helper'
require "logstash/filters/ldap"

# We disable warning for warning of others dependencies
$VERBOSE = nil

describe LogStash::Filters::Ldap do

  # You need to set-up all those environement variables to
  # test this plugin using "bundle exec rspect"
  before(:each) do
    @ldap_host=ENV["ldap_host"]
    @ldap_port=ENV["ldap_port"]
    @ldaps_port=ENV["ldaps_port"]
    @ldap_username=ENV["ldap_username"]
    @ldap_password=ENV["ldap_password"]
    @ldap_search_dn=ENV["ldap_search_dn"]
  end


  describe "check simple search" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          search_dn => "#{@ldap_search_dn}"
          attributes => ['givenName', 'sn']
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include('givenname')
      expect(subject.get('ldap')).to include('sn')

      expect(subject.get('ldap')).not_to include("dn")
      expect(subject.get('ldap')).not_to include("error")
      expect(subject).not_to include('tags')

      expect(subject.get("ldap")["givenname"]).to eq("VALENTIN")
      expect(subject.get("ldap")["sn"]).to eq("BOURDIER")
    end

    sample("test" => "test2" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include('givenname')
      expect(subject.get('ldap')).to include('sn')

      expect(subject.get('ldap')).not_to include("error")
      expect(subject).not_to include('tags')

      expect(subject.get("ldap")["givenname"]).to eq("VALENTIN")
      expect(subject.get("ldap")["sn"]).to eq("BOURDIER")
    end
  end

  describe "check simple search with persistant cache" do

    cache_path = "/tmp/test_cache"
    File.delete(cache_path) if File.exist?(cache_path)

    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          search_dn => "#{@ldap_search_dn}"
          attributes => ['givenName', 'sn']
          use_cache => true
          disk_cache_filepath => "#{@cache_path}"
          disk_cache_schedule => "1"
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
    end

    sample("test" => "test" ) do
      sleep(10)
      expect(Pathname(cache_path).exist?).to eq(true)
    end

  end

  describe "check simple search without attributes" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          search_dn => "#{@ldap_search_dn}"
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include('givenname')
      expect(subject.get('ldap')).to include('homedirectory')
      expect(subject.get('ldap')).to include('gecos')
      expect(subject.get('ldap')).to include('sn')

      expect(subject.get('ldap')).not_to include("error")
      expect(subject).not_to include('tags')

      expect(subject.get("ldap")["givenname"]).to eq("VALENTIN")
      expect(subject.get("ldap")["gecos"]).to eq("VALENTIN BOURDIER")
      expect(subject.get("ldap")["homedirectory"]).to eq("/users/login/u501565")
      expect(subject.get("ldap")["sn"]).to eq("BOURDIER")
    end
  end


  describe "check simple search with ssl" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          use_ssl => true
          ldaps_port => "#{@ldaps_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          search_dn => "#{@ldap_search_dn}"
          attributes => ['givenName', 'sn']
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include('givenname')
      expect(subject.get('ldap')).to include('sn')

      expect(subject.get('ldap')).not_to include("error")
      expect(subject).not_to include('tags')

      expect(subject.get("ldap")["givenname"]).to eq("VALENTIN")
      expect(subject.get("ldap")["sn"]).to eq("BOURDIER")
    end

    sample("test" => "test2" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include('givenname')
      expect(subject.get('ldap')).to include('sn')

      expect(subject.get('ldap')).not_to include("error")
      expect(subject).not_to include('tags')

      expect(subject.get("ldap")["givenname"]).to eq("VALENTIN")
      expect(subject.get("ldap")["sn"]).to eq("BOURDIER")
    end
  end

  describe "check simple search with cache" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          search_dn => "#{@ldap_search_dn}"
          attributes => ['givenName', 'sn']
          use_cache => "true"
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include('givenname')
      expect(subject.get('ldap')).to include('sn')

      expect(subject.get('ldap')).not_to include("error")
      expect(subject).not_to include('tags')

      expect(subject.get("ldap")["givenname"]).to eq("VALENTIN")
      expect(subject.get("ldap")["sn"]).to eq("BOURDIER")
    end

    sample("test" => "test2" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include('givenname')
      expect(subject.get('ldap')).to include('sn')

      expect(subject.get('ldap')).not_to include("error")
      expect(subject).not_to include('tags')

      expect(subject.get("ldap")["givenname"]).to eq("VALENTIN")
      expect(subject.get("ldap")["sn"]).to eq("BOURDIER")
    end
  end


  describe "check simple search with custom object type" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          identifier_type => "person"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          search_dn => "#{@ldap_search_dn}"
          attributes => ['givenName', 'sn']
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include('givenname')
      expect(subject.get('ldap')).to include('sn')

      expect(subject.get('ldap')).not_to include("error")
      expect(subject).not_to include('tags')

      expect(subject.get("ldap")["givenname"]).to eq("VALENTIN")
      expect(subject.get("ldap")["sn"]).to eq("BOURDIER")
    end
  end

  describe "check with false ssl settings" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          use_ssl => true
          host => "#{@ldap_host}"
          ldaps_port => "1234"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          search_dn => "#{@ldap_search_dn}"
          enable_error_logging => true
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include("error")
      expect(subject).to include('tags')

      expect(subject.get('ldap')).not_to include('givenname')
      expect(subject.get('ldap')).not_to include('sn')

      expect(subject.get("tags")).to eq(["LDAP_ERROR"])
      expect(subject.get("ldap")["error"]).to match("Bad file descriptor - No message available")
    end
  end


  describe "check simple search with custom identifier" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_key => "homeDirectory"
          identifier_value => "/users/login/u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          search_dn => "#{@ldap_search_dn}"
          attributes => ['givenName', 'sn']
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include('givenname')
      expect(subject.get('ldap')).to include('sn')

      expect(subject.get('ldap')).not_to include("error")
      expect(subject).not_to include('tags')

      expect(subject.get("ldap")["givenname"]).to eq("VALENTIN")
      expect(subject.get("ldap")["sn"]).to eq("BOURDIER")
    end
  end


  describe "check simple search with customs attributs" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          search_dn => "#{@ldap_search_dn}"
          attributes => ["cn", "uidnumber", "gidnumber"]
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include('cn')
      expect(subject.get('ldap')).to include('uidnumber')
      expect(subject.get('ldap')).to include('gidnumber')

      expect(subject.get('ldap')).not_to include('givenname')
      expect(subject.get('ldap')).not_to include('sn')
      expect(subject.get('ldap')).not_to include("error")
      expect(subject.get('ldap')).not_to include('tags')

      expect(subject.get('ldap')).not_to include("error")
      expect(subject).not_to include('tags')

      expect(subject.get("ldap")["cn"]).to eq("VALENTIN BOURDIER - U501565")
      expect(subject.get("ldap")["uidnumber"]).to eq("479615")
      expect(subject.get("ldap")["gidnumber"]).to eq("9043")
    end
  end


  describe "check bad ldap host" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "babdsfafds.org"
          ldap_port => "#{@ldap_port}"
          username => "test"
          password => "test"
          search_dn => "#{@ldap_search_dn}"
          attributes => ['givenName', 'sn']
          enable_error_logging => true
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include("error")
      expect(subject).to include('tags')

      expect(subject.get('ldap')).not_to include('givenname')
      expect(subject.get('ldap')).not_to include('sn')

      expect(subject.get("tags")).to eq(["LDAP_ERROR"])
      expect(subject.get("ldap")["error"]).to eq("getaddrinfo: name or service not known")
    end
  end


  describe "check bad ldap host without error logging" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "babdsfafds.org"
          ldap_port => "#{@ldap_port}"
          username => "test"
          password => "test"
          search_dn => "#{@ldap_search_dn}"
          attributes => ['givenName', 'sn']
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('tags')

      expect(subject).not_to include('ldap')

      expect(subject.get("tags")).to eq(["LDAP_ERROR"])
    end
  end


  describe "test bad search_dn" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          attributes => ['givenName', 'sn']
          search_dn => "test"
          enable_error_logging => true
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include("error")
      expect(subject).to include('tags')

      expect(subject.get('ldap')).not_to include('givenname')
      expect(subject.get('ldap')).not_to include('sn')

      expect(subject.get("tags")).to eq(["LDAP_ERROR"])
      expect(subject.get("ldap")["error"]).to eq("invalid DN")
    end
  end


  describe "test bad user/password couple" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "test"
          password => "test"
          search_dn => "#{@ldap_search_dn}"
          attributes => ['givenName', 'sn']
          enable_error_logging => true
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('ldap')

      expect(subject.get('ldap')).to include("error")
      expect(subject).to include('tags')

      expect(subject.get('ldap')).not_to include('givenname')
      expect(subject.get('ldap')).not_to include('sn')

      expect(subject.get("tags")).to eq(["LDAP_ERROR"])
      expect(subject.get("ldap")["error"]).to eq("invalid DN")
    end
  end

  describe "test bad user/password couple & no_tag" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "test"
          password => "test"
          search_dn => "#{@ldap_search_dn}"
          attributes => ['givenName', 'sn']
          no_tag_on_failure => true
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).not_to include('ldap')
      expect(subject).not_to include('tags')
    end
  end

  describe "check bad identifier user" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "abcdefg"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          search_dn => "#{@ldap_search_dn}"
          attributes => ['givenName', 'sn']
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('tags')

      expect(subject).not_to include('ldap')

      expect(subject.get("tags")).to eq(["LDAP_NOT_FOUND"])
    end
  end


  describe "check simple search with custom target" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          target => "myTarget"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          search_dn => "#{@ldap_search_dn}"
          attributes => ['givenName', 'sn']
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('myTarget')

      expect(subject.get('myTarget')).to include('givenname')
      expect(subject.get('myTarget')).to include('sn')

      expect(subject.get('myTarget')).not_to include("error")
      expect(subject).not_to include('tags')

      expect(subject.get("myTarget")["givenname"]).to eq("VALENTIN")
      expect(subject.get("myTarget")["sn"]).to eq("BOURDIER")
    end
  end


end
