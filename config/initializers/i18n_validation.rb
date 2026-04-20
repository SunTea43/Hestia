# Validación de traducciones en español
# Este inicializador verifica que todas las claves de traducción en inglés
# tengan correspondencia en español. Si falta alguna traducción en español,
# lanza un error en desarrollo y test, pero no en producción.

if Rails.env.development? || Rails.env.test?
  require "yaml"

  def load_yaml_file(locale)
    file_path = Rails.root.join("config", "locales", "#{locale}.yml")
    return {} unless File.exist?(file_path)

    YAML.load_file(file_path, permitted_classes: [ Symbol ]).deep_symbolize_keys
  end

  def check_missing_translations(en_hash, es_hash, path = [])
    missing_keys = []

    en_hash.each do |key, value|
      current_path = path + [ key ]

      if value.is_a?(Hash)
        nested_es = es_hash[key] || {}
        missing_keys.concat(check_missing_translations(value, nested_es, current_path))
      else
        unless es_hash.key?(key)
          missing_keys << current_path.join(".")
        end
      end
    end

    missing_keys
  end

  en_translations = load_yaml_file(:en)
  es_translations = load_yaml_file(:es)

  # Obtener el contenido dentro de la clave del idioma (en/es)
  en_content = en_translations[:en] || {}
  es_content = es_translations[:es] || {}

  missing_keys = check_missing_translations(en_content, es_content)

  if missing_keys.any?
    raise StandardError, "Faltan traducciones en español para las siguientes claves: #{missing_keys.join(', ')}"
  end
end
