module Packet
  class Client
    module Devices
      def list_devices(project_id, *args)
        get("projects/#{project_id}/devices", *args).body['devices'].map { |p| Packet::Device.new(p, self) }
      end

      def get_device(id, *args)
        Packet::Device.new(get("devices/#{id}", *args).body, self)
      end

      def create_device(device)
        post("projects/#{device.project_id}/devices", device.to_hash).tap do |response|
          device.update_attributes(response.body)
        end
      end

      def update_device(device)
        patch("devices/#{device.id}", device.to_hash).tap do |response|
          device.update_attributes(response.body)
        end
      end

      def reboot_device(device)
        action(device, 'reboot')
      end

      def rescue_device(device)
        action(device, 'rescue')
      end

      def power_on_device(device)
        action(device, 'power_on')
      end

      def power_off_device(device)
        action(device, 'power_off')
      end

      def delete_device(device_or_id)
        id = extract_id(device_or_id)

        delete("devices/#{id}")
      end

      def get_bandwidth(device_or_id, from:, to:)
        id = extract_id(device_or_id)

        get("devices/#{id}/bandwidth", from: from, to: to)
      end

      def traffic(device_or_id, bucket: 'external', direction: 'outbound', started_at:, ended_at:, interval:)
        id = extract_id(device_or_id)

        get("devices/#{id}/traffic",
            bucket: bucket,
            direction: direction,
            interval: interval,
            started_at: started_at,
            ended_at: ended_at
           )
            
      end

      private

      def extract_id(device_or_id)
        if device_or_id.is_a?(Packet::Device)
          device_or_id.id
        else
          device_or_id
        end
      end

      def action(device, action_type)
        post("devices/#{device.id}/actions", type: action_type).success?
      end
    end
  end
end
