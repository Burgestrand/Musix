require 'rubygems'
require 'httparty'
require 'nokogiri'
require 'Plist'
require 'cgi'
require 'metaid'
    
module Musix
  # A Spotify metadata API wrapper
  #
  # Examples:
  #   Service::Spotify::Search.track('Fix You')
  #   Service::Spotify::lookup(Service::Spotify::Search.track('Fix You')["track"].first["href"])
  module Spotify
    include HTTParty
    format :xml
    base_uri 'http://ws.spotify.com/'
    
    class Search      
      [:track, :album, :artist].each do |method|
        meta_def method do |query, *args|
          Spotify::get("/search/1/#{method}", :query => { :q => query, :page => [args.first.to_i, 1].max }).fetch("#{method}s")
        end
      end
    end
    
    def self.lookup(uri, detail = 0)
      type = uri.match('spotify:([^:]+)')[1]
      get '/lookup/1/', :query => { :uri => uri, :extras => [type, "detail"].slice(0, detail).join }
    end
  end
  
  # Grooveshark API
  #
  # Example
  #   - Service::Grooveshark.search 'FIX YOU'
  class Grooveshark
    include HTTParty
    format :json
    default_params :format => 'json'
    
    def self.search(uri, limit = 3)
      get "http://tinysong.com/s/#{CGI::escape uri}", :query => { :limit => limit }
    end
  end
  
  # iTunes API
  class ITunes
    include HTTParty
    headers 'User-Agent' => 'iTunes/9.1'
    format :plain
    
    def self.search(term)
      result = get 'http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZSearch.woa/wa/search?submit=edit&term=%s' % CGI::escape(term)
      itms   = Nokogiri::XML result
      Plist::parse_xml(itms.css('TrackList plist').to_s)["items"]
    end
  end
end