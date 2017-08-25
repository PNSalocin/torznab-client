module Torznab
  module Client
    # HTTP calls handling
    module Http
      class << self

        API_PATH = '/api'.freeze # API Prefix for torznab

        # Do a GET request
        #
        # @param [String] url Resource to fetch
        # @param [Hash] params GET Parameters in a key/value form
        # @return [String] Contents of the provided url
        # @raise [SchemeError] If the URL don't begin with http or https
        # @raise [HttpError] If the status code is not 2XX
        def get(url, params = nil)
          uri = create_uri url, params
          http = create_http uri
          get_request = Net::HTTP::Get.new uri
          response = http.request get_request
          process_response response
        end

        private

        def create_uri(url, params)
          uri = URI.parse url
          raise SchemeError, 'Scheme must be either http or https' if uri.scheme != 'http' && uri.scheme != 'https'
          uri_set_query_from_params uri, params
          uri_path_remove_last_slash uri
          uri_path_add_api uri
        end

        def uri_set_query_from_params(uri, params)
          uri.query = URI.encode_www_form params if params
          uri
        end

        def uri_path_remove_last_slash(uri)
          uri.path = uri.path[0..-2] if !uri.path.empty? && uri.path[-1, 1] == '/'
          uri
        end

        def uri_path_add_api(uri)
          uri.path += API_PATH if uri.path[-4, 4] != API_PATH
          uri
        end

        def create_http(uri)
          http = Net::HTTP.new uri.host, uri.port
          if uri.scheme == 'https'
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          http
        end

        def process_response(response)
          unless response.is_a? Net::HTTPSuccess
            raise HttpError, "Coudn't process response: #{response.code} #{response.class.to_s.sub! 'Net::HTTP', ''}"
          end
          response.body
        end
      end

      # Raised when a URL don't begin with http or https
      class SchemeError < StandardError
      end

      # Raised when the status code returned by the response is not 2XX
      class HttpError < StandardError
      end
    end
  end
end