module RollbarHelper
  class << self
    # def resolve_error_from_fingerprint(fingerprint)
    #   result = HTTParty.get("#{SsmConfig.rollbar[:endpoint]}/api/1/items", :query => {
    #     :access_token => SsmConfig.rollbar[:read_token],
    #     :status => 'active',
    #     :environment => Rails.env,
    #     :level => 'error',
    #     :framework => 'rails'
    #   })

    #   resolve_item = result['result']['items'].detect { |item| item['hash'] == fingerprint }
    #   if resolve_item.present?
    #     query = {:access_token => SsmConfig.rollbar[:write_token]}
    #     headers = {'Content-Type' => 'application/json'}
    #     body = {:status => 'resolved'}.to_json

    #     HTTParty.patch("#{SsmConfig.rollbar[:endpoint]}/api/1/item/#{resolve_item['id']}", :query => query, :headers => headers, :body => body)
    #   end
    # end
    # handle_asynchronously :resolve_error_from_fingerprint, :queue => 'rollbar'
    # handle_asynchronously requires the delayed_job gem (https://github.com/collectiveidea/delayed_job)

    def error(msg = nil, e: nil, fingerprint: nil)
      exception = get_exception(e, msg)

      if fingerprint.present?
        Rollbar.scope(:fingerprint => fingerprint).error(exception)
      else
        Rollbar.error(exception)
      end
      Rails.logger.error(exception)
    end

    def warning(msg = nil, e: nil, fingerprint: nil)
      exception = get_exception(e, msg)

      if fingerprint.present?
        Rollbar.scope(:fingerprint => fingerprint).warn(exception)
      else
        Rollbar.warning(exception)
      end
      Rails.logger.warn(exception)
    end

    protected

    def get_exception(e = nil, msg = nil)
      if e.nil?
        exception = Exception.new(msg || "An error occurred")
        exception.set_backtrace(caller)
      elsif msg.present?
        exception = create_exception_safe(e, msg)
        exception.set_backtrace(e.backtrace)
      else
        exception = e
      end
      exception
    end

    def create_exception_safe(e, msg)
      e.class.new("#{msg}: #{e}")
    rescue StandardError
      Exception.new("#{msg} (#{e.class.name}): #{e}")
    end

  end
end
