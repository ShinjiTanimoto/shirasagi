require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with cache-control for performance.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Don't include all helpers
  # include_all_helpers が true の場合、"Cms::ListHelper#render_page_list" ではなく
  # "Opendata::ListHelper#render_page_list" が実行され、view のレンダリングに失敗する。
  config.action_controller.include_all_helpers = false

  # CSRF
  config.action_controller.per_form_csrf_tokens = false
  config.action_controller.forgery_protection_origin_check = false

  # action view
  config.action_view.automatically_disable_submit_tag = true
  config.action_view.form_with_generates_remote_forms = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{1.hour.to_i}" }

  # Show full error reports.
  config.consider_all_requests_local = true

  config.action_controller.perform_caching = false
  # config.cache_store = :null_store
  config.cache_store = :file_store, "#{Rails.root}/tmp/rspec_#{$PID}/cache_store"

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "example.com" }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  # config.action_controller.raise_on_missing_callback_actions = true
  config.action_controller.raise_on_missing_callback_actions = false

  # Logger
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = ENV.fetch("TEST_LOG_LEVEL", "debug")

  # Use a real queuing backend for Active Job (and separate queues per environment).
  config.active_job.queue_adapter = :test

  # HACK: Load initializers without load routes in rake tasks.
  config.after_initialize do
    Dir["#{config.root}/app/models/**/initializer.rb"].each do |file|
      require file
    end
  end
end
