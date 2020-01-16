require 'ostruct'
require 'tempfile'
require 'http/rest_client'

# DPD HTTP API Client
module DPD
  # Base endpoint resources class
  class Resource < OpenStruct
    extend HTTP::RestClient::DSL
    extend HTTP::RestClient::CRUD

    endpoint 'https://api.dpd.ro'
    content_type 'application/json'

    # Returns a payload with service credentials
    #
    # @return [Hash]
    def self.credentials
      {
        userName: ENV['DPD_USER'],
        password: ENV['DPD_PASSWORD']
      }
    end

    # Patched request handler to include the credentials
    #
    # @param verb [String] the HTTP method.
    # @param uri [URI] the HTTP URI.
    # @param options [Hash] the params/json-payload/form to include.
    # @return [DPD::Response]
    def self.request(verb, uri, options = {})
      options[:json] ||= {}
      options[:json].merge!(credentials)
      super(verb, uri, options)
    end

    # Validate error response
    #
    # Looks at the response code by default.
    #
    # @param response [HTTP::Response] the server response
    # @param parsed [Object] the parsed server response
    #
    # @return [TrueClass] if status code is not a successful standard value
    def self.error_response?(response, parsed)
      super || parsed.is_a?(Hash) && parsed.dig('error')
    end

    # Extracts the error message from the response
    #
    # @param response [HTTP::Response] the server response
    # @param parsed [Object] the parsed server response
    #
    # @return [String]
    def self.extract_error(response, parsed)
      parsed&.dig('error', 'message') || super
    end

    # Will try to parse the response or return an IO if it's a PDF
    #
    # Will return nothing on failure.
    #
    # @param response [HTTP::Response] the server response
    #
    # @return [Object] upon success
    def self.parse_response(response)
      if response.mime_type == 'application/pdf'
        io = Tempfile.new([name.underscore, '.pdf'])
        io.write(response.body)
        io.seek(0)

        { data: io }
      else
        super
      end
    end
  end

  # Shipments endpoint resource
  class Shipment < Resource
    path 'v1/shipment'

    # Handles the shipment fetching request
    #
    # @return [DPD::Response]
    def self.find(id)
      params = { shipmentIds: [id] }
      params.merge!(credentials)
      new(request(:post, uri('info'), json: params).values.flatten.first)
    end

    # Handles the shipment cancellation request
    #
    # @return [DPD::Response]
    def cancel(comment)
      params = { shipmentId: id, comment: comment }
      self.class.request(
        :post,
        self.class.uri('cancel'),
        json: params.merge(self.class.credentials)
      )
    end
  end

  # Printouts endpoint resource
  class Printout < Resource
    path 'v1/print'
  end

  # Return vouchers endpoint resource
  class Voucher < Resource
    path 'v1/print/voucher'
  end

  # Pickup request endpoint resource
  class Pickup < Resource
    path 'v1/pickup'
  end

  # Tracking endpoint resource
  class Track < Resource
    path 'v1/track'

    # Handles the shipment fetching request
    #
    # @return [DPD::Response]
    def self.find(id)
      params = { parcels: [{ id: id }] }
      params.merge!(credentials)
      super('', params).values.flatten.first
    end
  end
end
