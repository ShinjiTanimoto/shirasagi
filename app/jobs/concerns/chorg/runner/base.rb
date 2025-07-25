module Chorg::Runner::Base
  extend ActiveSupport::Concern

  included do
    before_perform do
      @config = self.class.config_p.call
      @models = @config.models.map(&:constantize).freeze
      build_exclude_fields(@config.exclude_fields)
      @embedded_array_fields = @config.embedded_array_fields.presence || []
    end
  end

  def perform(name, opts)
    @cur_site = self.site
    @cur_user = self.user
    @adds_group_to_site = opts['newly_created_group_to_site'].presence == 'add'
    @gws_staff_record = opts['gws_staff_record']
    @item = self.class.revision_class.site(@cur_site).find_by(name: name)
    @item = self.class.revision_class.acquire_lock(@item, 1.hour)
    unless @item
      put_log("already running")
      return
    end

    task.performance.header(name: "chorg performance log at #{Time.zone.now.iso8601}")
    task.performance.collect_site(@cur_site) do
      logger_tags = []
      if @cur_site
        logger_tags << "#{@cur_site.name}(#{@cur_site.id})"
      end
      if @cur_user
        logger_tags << @cur_user.uid.presence || @cur_user.email.presence || @cur_user.name
      end
      logger_tags << @item.name
      Rails.logger.tagged(*logger_tags) do
        self.class.revision_class.ensure_release_lock(@item) do
          SS::Model.without_record_timestamps do
            task.performance.collect_init_context do
              init_context(opts)
            end

            run_primitive_chorg

            put_log("==update_all==")
            with_inc_depth { update_all }

            put_log("==validate_all==")
            with_inc_depth { validate_all }

            # put_log("==delete_groups==")
            task.log("==削除==")
            with_inc_depth { delete_groups(delete_group_ids) }

            # put_log("==results==")
            task.performance.collect_result do
              task.log("==結果==")
              with_inc_depth do
                results.keys.each do |key|
                  # put_log("#{key}: success=#{results[key]["success"]}, failed=#{results[key]["failed"]}")
                  msg = [
                    "[#{I18n.t("chorg.views.revisions/edit.#{key}")}]",
                    "成功: #{results[key]["success"]},",
                    "失敗: #{results[key]["failed"]}"
                  ].join(' ')
                  task.log("  #{msg}")
                end
              end
            end

            task.performance.collect_finalize_context do
              finalize_context
            end

            task.performance.collect_import_user_csv do
              import_user_csv
            end
          end
        end
      end
    end
  end

  private

  def models_scope
    {}
  end

  def target_site(entity)
    nil
  end

  def update_all
    return if substitutor.empty?

    task.performance.collect_update_all do
      with_entity_updates(@models, substitutor, models_scope) do |entity, updates|
        # グループウェアの場合、更新がなければスキップ。
        # 以下のコードはコメントアウトされていたので、CMS の場合は更新がなくても保存した方が良いんだと思う。
        next if self.class.ss_mode == :gws && updates.blank?

        put_log("#{entity_title(entity)} has some updates. module=#{entity.class}") if updates.present?
        with_inc_depth do
          updates = updates.select { |k, v| v.present? }
          updates.each do |k, new_value|
            put_log("property #{k} has these changes:")
            with_inc_depth do
              if new_value.is_a?(Chorg::EmbeddedArray)
                put_embedded_array_log(entity, new_value)
              else
                old_value = entity[k]
                put_field_log(old_value, new_value)
              end
            end
          end
        end
        update(entity, updates)
        save_or_collect_errors(entity)
      end
    end
  end

  def put_embedded_array_log(entity, embedded_array)
    embedded_values = entity.send(embedded_array.field_name)
    embedded_array.update_array.each_with_index do |updates, i|
      updates.each do |k, new_value|
        put_log("embedded[#{i}]")
        with_inc_depth do
          put_log("#{k}:")
          old_value = embedded_values[i][k]
          put_field_log(old_value, new_value)
        end
      end
    end
  end

  def put_string_field_log(old_value, new_value)
    Diffy::Diff.new(old_value, new_value, diff: "-U 3").to_s.each_line do |line|
      next if /No newline at end of file/i.match?(line)
      put_log(line.chomp.to_s)
    end
  end

  def put_array_field_log(old_value, new_value)
    if new_value.select { |value| value && value.is_a?(String) }.first
      with_inc_depth do
        new_value.each_with_index do |value, i|
          put_log("[#{i}]")
          put_string_field_log(old_value[i], value)
        end
      end
    else
      convert_to_group_names(old_value - new_value).each do |name|
        put_log("-#{name}")
      end
      convert_to_group_names(new_value - old_value).each do |name|
        put_log("+#{name}")
      end
    end
  end

  def put_field_log(old_value, new_value)
    case new_value
    when String
      put_string_field_log(old_value, new_value)
    when Array
      put_array_field_log(old_value, new_value)
    else
      convert_to_group_names([old_value]).each do |name|
        put_log("-#{name}")
      end
      convert_to_group_names([new_value]).each do |name|
        put_log("+#{name}")
      end
    end
  end

  def entity_title(entity)
    title = ''
    if entity.respond_to?(:name)
      title << entity.name.to_s
    end
    if entity.respond_to?(:url)
      title << '('
      title << entity.url.to_s
      title << ')'
    end
    title
  end

  def validate_all
    return if validation_substitutor.empty?

    task.performance.collect_validate_all do
      with_entity_updates(@models, validation_substitutor, models_scope) do |entity, deletes|
        put_log("#{entity.name}(#{entity.url}) has deleted attributes: #{deletes}") if deletes.present?
      end
    end
  end
end
