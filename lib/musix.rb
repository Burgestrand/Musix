require 'bundler'
Bundler.setup

require 'httparty'
require 'nokogiri'
require 'Plist'
require 'metaid'
require 'cgi'

# = What is Musix?
# 
# Musix was written to provide a simple interface for searching popular
# music services such as Spotify, Grooveshark, ITunes and possibly more
# in the future.
module Musix
  # = A Spotify metadata API wrapper
  # 
  #
  # == Examples
  #   Service::Spotify::Search.track('Fix You')
  #   Service::Spotify::lookup(Service::Spotify::Search.track('Fix You')["track"].first["href"])
  module Spotify
    include HTTParty
    format :xml
    base_uri 'http://ws.spotify.com/'
    
    # = Spotify metadata search API
    # Spotify::Search provides three methods for searching the {Spotify metadata API}[http://developer.spotify.com/en/metadata-api/search/].
    class Search
      
      # Searches Spotify for a track.
      def self.track(query, page = 1)
        search("track", query, page)
      end
      
      # Searches Spotify for an album.
      def self.album(query, page = 1)
        search("album", query, page)
      end
      
      # Searches Spotify for an artist.
      def self.artist(query, page = 1)
        search("artist", query, page)
      end
      
      private
      def self.search(type, query, page)
        Spotify::get("/search/1/#{type}", :query => { :q => query, :page => page }).fetch("#{type}s")
      end
    end
    
    # Looks up information about a Spotify URI with the +detail+ level of detail (max 2).
    # 
    # Spotify URIs looks like the following:
    # -  spotify:track:id
    # -  spotify:artist:id
    # -  spotify:album:id
    def self.lookup(uri, detail = 0)
      type = uri.match('spotify:([^:]+)')[1]
      get '/lookup/1/', :query => { :uri => uri, :extras => [type, "detail"].slice(0, detail).join }
    end
  end
  
  # = Grooveshark API
  # Searches Grooveshark using the {Tinysong API}[http://tinysong.com/api]
  class Grooveshark
    include HTTParty
    format :json
    default_params :format => 'json'
    
    # Searches Grooveshark (tinysong), returns a maximum of +limit+ results
    def self.search(uri, limit = 3)
      get "http://tinysong.com/s/#{CGI::escape uri}", :query => { :limit => limit }
    end
  end
  
  # = iTunes API
  # This code would not have been possible if I hadn’t found {itms-lib}[http://itms-lib.rubyforge.org/].
  # It made my quest for an iTunes search API much shorter.
  class ITunes
    include HTTParty
    headers 'User-Agent' => 'iTunes/9.1'
    format :plain
    
    # Searches iTunes for +term+.
    def self.search(term)
      result = get 'http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZSearch.woa/wa/search?submit=edit&term=%s' % CGI::escape(term)
      itms   = Nokogiri::XML result
      Plist::parse_xml(itms.css('TrackList plist').to_s)["items"]
    end
  end
end