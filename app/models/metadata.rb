class Metadata < ActiveRecord::Base
  include IdentityCache

  belongs_to :photograph

  validates :photograph_id, presence: true

  def extract_from_photograph
    exif = photograph.exif

    metadata = new do |m|
      m.title        = exif.title
      m.description  = exif.description
      m.keywords     = exif.keywords
      m.taken_at     = exif.date_time_original

      m.camera = fetch_from_exif(exif, [
        :make, :model, :serial_number, :camera_type, :lens_type, :lens_model,
        :max_focal_length, :min_focal_length, :max_aperture, :min_aperture,
        :num_af_points, :sensor_width, :sensor_height
      ])

      m.settings = fetch_from_exif(exif, [
        :orientation, :fov, :aperture, :focal_length,
        :shutter_speed, :exposure_time, :exposure_program, :exposure_mode,
        :metering_mode, :flash, :drive_mode, :digital_zoom, :macro_mode,
        :self_timer, :quality, :record_mode, :easy_mode, :contrast,
        :saturation, :sharpness, :focus_range, :auto_iso, :base_iso,
        :measured_ev, :target_aperture, :target_exposure_time, :white_balance,
        :camera_temperature, :flash_guide_number, :flash_exposure_comp,
        :aeb_bracket_value, :focus_distance_upper, :focus_distance_lower,
        :nd_filter, :flash_sync_speed_av, :shutter_curtain_sync, :mirror_lockup,
        :bracket_mode, :bracket_value, :bracket_shot_number, :hyperfocal_distance,
        :circle_of_confusion
      ])

      m.creator = fetch_from_exif(exif, [
        :copyright_notice, :rights, :creator, :creator_country, :creator_city,
        :date_created
      ])

      m.image = fetch_from_exif(exif, [
        :color_space, :image_width, :image_height, :gps_position,
        :flash_output, :gamma, :image_size
      ])
    end

    return metadata
  end

  private
  def fetch_from_exif(exif, keys = [])
    return_hash = {}

    exif.to_hash.each do |key, value|
      key = key.underscore.to_sym
      if keys.include?(key)
        return_hash[key] = value
      end
    end

    return_hash
  end
end
