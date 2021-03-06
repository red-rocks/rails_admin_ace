require 'rails_admin/config/fields/types/text'
require 'json'

module RailsAdmin
  module Config
    module Fields
      module Types
        class AceEditor < RailsAdmin::Config::Fields::Types::CodeMirror
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)
          include RailsAdmin::Engine.routes.url_helpers

          register_instance_option :string_method do
            "#{name}_str"
          end

          register_instance_option :hash_method do
            "#{name}_hash"
          end

          register_instance_option :value do
            formatted_value
          end

          register_instance_option :tabbed do
            true
          end


          ############ localize ######################
          register_instance_option :translations_field do
            (string_method.to_s + '_translations').to_sym
          end

          register_instance_option :localized? do
            @abstract_model.model_name.constantize.public_instance_methods.include?(translations_field)
          end

          register_instance_option :pretty_value do
            if localized?
              I18n.available_locales.map { |l|
                ret = nil
                I18n.with_locale(l) do
                  _hash = bindings[:object].send(hash_method) || {}
                  ret = ("#{l}:<pre>" + JSON.pretty_generate(_hash) + "</pre>")
                end
                ret
              }.join.html_safe
            else
              _hash = bindings[:object].send(hash_method) || {}
              ("<pre>" + JSON.pretty_generate(_hash) + "</pre>").html_safe
            end
          end

          register_instance_option :formatted_value do
            if localized?
              puts bindings[:object].send((hash_method.to_s + '_translations').to_sym)
              puts '__'
              _val = bindings[:object].send((hash_method.to_s + '_translations').to_sym)
              _val.each_pair { |l, _hash|
                begin
                  _val[l] = JSON.pretty_generate(_hash)
                rescue
                end
              }
            else
              begin
                JSON.pretty_generate(bindings[:object].send hash_method)
              rescue
                bindings[:object].send hash_method
              end
            end
          end

          register_instance_option :allowed_methods do
            localized? ? [string_method, translations_field] : [string_method]
          end

          register_instance_option :partial do
            # localized? ? :enjoy_hash_ml : :enjoy_hash
            localized? ? :hancock_hash_ml : :hancock_hash
          end
        end
      end
    end
  end
end
