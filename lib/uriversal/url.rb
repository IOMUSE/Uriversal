module Uriversal
  
  class Url
    
    attr_reader :raw, :protocol, :domain, :port, :path, :file_type, :query, :uri
    
    def initialize(url,options={})
      unless (url =~ URI::regexp).nil?
        @uri        = Addressable::URI.parse(url)
        @raw        = @uri.to_s
        @protocol   = @uri.scheme
        @domain     = @uri.host
        @port       = @uri.port
        @path       = @uri.path.chomp(File.extname(@uri.path))
        @file_type  = File.extname(@uri.path).sub(/\./i,"")
        @query      = @uri.query
      else
        raise ArgumentError, "invalid url"
      end
    end
    
    # Determains if linked url is a file
    def is_file?
      !file_type.empty?
    end
    
    def load_data!
      match = Uriversal::Registry.match(self)
      match.match_object.strategies.each do |strategy_name|
        strategy = Uriversal::Strategy.new(strategy_name,self)
        return strategy.perform
      end
      return Uriversal::Response.new({status:'',data:{}},self)
    end
    
  end

end