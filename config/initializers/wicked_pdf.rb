WickedPdf.configure do |config|
  config.exe_path = ENV["WKHTMLTOPDF_PATH"] if ENV["WKHTMLTOPDF_PATH"].present?
  config.enable_local_file_access = true
end