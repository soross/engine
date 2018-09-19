module Locomotive
  module Concerns
    module TimezoneController

      protected

      def set_timezone(&block)
        Time.use_zone(current_site.try(:timezone) || 'Beijing', &block)
      end

    end
  end
end
