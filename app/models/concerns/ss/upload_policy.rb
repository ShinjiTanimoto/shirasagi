module SS::UploadPolicy
  extend ActiveSupport::Concern

  included do
    field :sanitizer_state, type: String
    before_destroy :sanitizer_remove_file
  end

  def sanitizer_input_path
    filename = "#{SS.config.ss.sanitizer_file_prefix}_file_#{id}_#{created.to_i}#{::File.extname(basename)}"
    "#{SS::UploadPolicy.sanitizer_input_path}/#{filename}"
  end

  def sanitizer_skip
    @sanitizer_skip = true
  end

  def sanitizer_copy_file
    return false unless SS::UploadPolicy.upload_policy == 'sanitizer'
    return false if @sanitizer_skip
    return false if try(:original_id)
    return false if errors.present?

    input_path = sanitizer_input_path
    ::FileUtils.rm_f(input_path) if FileTest.exist?(input_path)
    ::FileUtils.cp(path, input_path)

    set(sanitizer_state: 'wait') unless sanitizer_state == 'wait'
  end

  def sanitizer_restore_file(output_path)
    if output_path.end_with?('Report.txt')
      SS::UploadPolicy.sanitizer_overwrite_error_file(output_path)
      self.sanitizer_state = 'error'
    else
      self.sanitizer_state = 'complete'
    end

    self.in_file = Fs::UploadedFile.create_from_file(output_path)
    sanitizer_skip
    return false unless save(validate: false)

    try(:generate_public_file) if try(:public?)
    Fs.rm_rf(output_path)
    true
  end

  private

  def validate_upload_policy
    return unless SS::UploadPolicy.upload_policy == 'restricted'
    errors.add :base, :upload_restricted
  end

  def sanitizer_save_file
    return false unless in_file
    return false if @sanitizer_skip
    return false if try(:original_id)

    if SS::UploadPolicy.upload_policy != 'sanitizer'
      self.sanitizer_state = nil if sanitizer_state.present?
      return false
    end

    input_path = sanitizer_input_path
    ::FileUtils.rm_f(input_path) if FileTest.exist?(input_path)
    ::FileUtils.cp(path, input_path)

    self.sanitizer_state = 'wait'
  end

  def sanitizer_remove_file
    ::FileUtils.rm_f(sanitizer_input_path) if SS::UploadPolicy.upload_policy == 'sanitizer'
  end

  class << self
    def sanitizer_state_label(value)
      I18n.t("ss.options.sanitizer_state.#{value}", default: '')
    end

    def upload_policy
      default = SS.config.ss.upload_policy
      return nil unless default
      return SS.current_site.upload_policy || default if SS.current_site
      return SS.current_organization.upload_policy || default if SS.current_organization
      return SS.current_user.organization.try(:upload_policy) || default if SS.current_user
      return default
    end

    def upload_policy_options
      default = SS.config.ss.upload_policy
      values = [[I18n.t("ss.options.upload_policy.default_#{default}"), nil]]
      values += %w(sanitizer restricted).map { |v| [I18n.t("ss.options.upload_policy.#{v}"), v] }
      values
    end

    def sanitizer_input_path
      @sanitizer_input_path ||= begin
        path = SS.config.ss.sanitizer_input
        if path.present?
          path = path[0..-2] while path.end_with?("/")
          path = File.expand_path(path, Rails.root)
          raise "invalid sanitizer input" unless path.start_with?(Rails.root.to_s)

          ::FileUtils.mkdir_p(path)
        end
        path.freeze
      end
    end

    def sanitizer_output_path
      @sanitizer_output_path ||= begin
        path = SS.config.ss.sanitizer_output
        if path.present?
          path = path[0..-2] while path.end_with?("/")
          path = File.expand_path(path, Rails.root)
          raise "invalid sanitizer input" unless path.start_with?(Rails.root.to_s)

          ::FileUtils.mkdir_p(path)
        end
        path.freeze
      end
    end

    def sanitizer_restore(output_path)
      filename = ::File.basename(output_path)
      return unless /\A#{SS.config.ss.sanitizer_file_prefix}_file_\d+_/.match?(filename)

      id = filename.sub(/\A#{SS.config.ss.sanitizer_file_prefix}_file_(\d+).*/, '\\1').to_i
      file = SS::File.find(id).becomes_with_model rescue nil
      return unless file

      if !file.sanitizer_restore_file(output_path)
        Rails.logger.error("sanitier_restore: #{file.class}##{id}: #{file.errors.full_messages.join(' ')}")
      end

      if SS::SanitizerJobFile.restore_wait_job(file)
        return file
      end

      file
    end

    def sanitizer_overwrite_error_file(output_path)
      data = nil
      ::File.open(output_path) { |f| data = f.readlines[0].strip }
      Fs.write(output_path, data)
    end

    def sanitizer_rename_zip(zip_path)
      Zip::File.open(zip_path) do |zip_file|
        zip_file.entries.sort_by(&:name).each do |entry|
          next if entry.ftype == :directory

          entry_name = SS::Zip.safe_zip_entry_name(entry)
          if /_[a-zA-Z]+Report\.txt\z/.match?(entry_name)
            zip_file.remove(entry)
            next
          end

          dir = ::File.dirname(entry_name)
          ext = ::File.extname(entry_name)
          basename = ::File.basename(entry_name, '.*')
          basename = basename.sub('_marked.MSOfficeWithPassword', '_marked')
          basename = basename.sub(/_\d+_\w+\z/, '')
          basename += ext unless /\.\w+\z/.match?(basename)

          new_name = [dir.presence, basename].compact.join('/')
          zip_file.rename(entry, new_name)
        end
      end rescue false
    end
  end
end
