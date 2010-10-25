module Asset

  class Manager

    def self.register_type(klass, name_symbol)
      @asset_types              ||= {}
      @asset_types[name_symbol] = klass
    end

    def self.register_namespace(*namespace_str)
      @search_namespaces ||= []
      namespace_str.each { |namespace| @search_namespaces << namespace }
    end

    def self.[](name_symbol)
      @asset_types       ||= {}
      result             = @asset_types[name_symbol]
      return result if result
      @search_namespaces ||= []
      @search_namespaces.each do |namespace|
        begin
          class_name = namespace + "::" + name_symbol.to_s.classify
          return class_name.constantize
        rescue NameError
          # if the loaded class contains errors, the script will obviously not load. Check that first!
        end
      end
      raise Asset::AssetMissingError, "Could not find asset \"#{name_symbol.to_s.classify}\" in the namespaces #{@search_namespaces.to_sentence}"
    end
  end

  class AssetMissingError < RuntimeError
  end

end