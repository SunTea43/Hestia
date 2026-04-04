namespace :apartment do
  desc "Create all tenant schemas"
  task create_schemas: :environment do
    tenants_to_create = ENV["APARTMENT_TENANTS"]&.split(",")&.map(&:strip) || [ "default" ]

    tenants_to_create.each do |tenant|
      next if tenant == "default"  # skip default, already exists

      begin
        puts "Creating schema: #{tenant}"
        Apartment::Tenant.create(tenant)
      rescue Apartment::SchemaExists => e
        puts "⚠️  #{e.message}"
      end
    end
  end

  desc "Migrate all tenant schemas"
  task migrate: :environment do
    tenants_to_migrate = ENV["APARTMENT_TENANTS"]&.split(",")&.map(&:strip) || [ "default" ]

    tenants_to_migrate.each do |tenant|
      puts "\n" + "=" * 60
      puts "🚀 Migrating tenant schema: #{tenant}"
      puts "=" * 60

      begin
        Apartment::Tenant.switch!(tenant)

        # Use Rails migration running system for Rails 8
        # This will run all migrations that haven't been run yet in this schema
        if defined?(ActiveRecord::MigrationContext)
          migration_context = ActiveRecord::MigrationContext.new(
            Rails.root.join("db/migrate")
          )
          migration_context.up
        end

        puts "✅ Migrations completed for #{tenant}"
      rescue => e
        puts "❌ Error migrating #{tenant}: #{e.message}"
      ensure
        Apartment::Tenant.reset
      end
    end
  end

  desc "Seed all tenant schemas"
  task seed: :environment do
    # The regular db:seed will run, but it will use Apartment.switch to populate all tenants
    Rake::Task["db:seed"].invoke
  end

  desc "Create a new tenant"
  task "create:tenant", [ :tenant_name, :admin_email, :admin_password ] => :environment do |t, args|
    tenant_name = args[:tenant_name] || ENV["TENANT_NAME"]
    admin_email = args[:admin_email] || ENV["ADMIN_EMAIL"] || "admin@#{tenant_name}.local"
    admin_password = args[:admin_password] || ENV["ADMIN_PASSWORD"] || "password123"

    unless tenant_name.present?
      puts "❌ Error: Por favor proporciona el nombre del tenant"
      puts "   Uso: rails apartment:create:tenant[tenant_name,admin_email,admin_password]"
      puts "   O:   TENANT_NAME=tenant_name ADMIN_EMAIL=admin@tenant.com rails apartment:create:tenant"
      exit 1
    end

    # Validate tenant name
    unless tenant_name.match?(/^[a-z0-9_]+$/)
      puts "❌ El nombre del tenant debe contener solo letras minúsculas, números y guiones bajos"
      exit 1
    end

    # Check if tenant already exists
    schema_exists = begin
      ActiveRecord::Base.connection.execute(
        "SELECT 1 FROM information_schema.schemata WHERE schema_name = '#{tenant_name}'"
      ).to_a.any?
    rescue
      false
    end

    if schema_exists
      puts "❌ El tenant '#{tenant_name}' ya existe"
      exit 1
    end

    puts "🏢 Creando nuevo tenant: #{tenant_name}"
    puts "   Email admin: #{admin_email}"
    puts ""

    # Step 1: Create schema
    puts "1️⃣ Creando schema en PostgreSQL..."
    begin
      Apartment::Tenant.create(tenant_name)
      puts "✅ Schema creado"
    rescue Apartment::SchemaExists => e
      puts "⚠️  #{e.message}"
    end

    # Step 2: Run migrations
    puts "2️⃣ Ejecutando migraciones..."
    begin
      Apartment::Tenant.switch!(tenant_name)

      if defined?(ActiveRecord::MigrationContext)
        migration_context = ActiveRecord::MigrationContext.new(
          Rails.root.join("db/migrate")
        )
        migration_context.up
      end

      puts "✅ Migraciones completadas"
    rescue => e
      puts "❌ Error en migraciones: #{e.message}"
      raise
    ensure
      Apartment::Tenant.reset
    end

    # Step 3: Create admin user
    puts "3️⃣ Creando usuario administrador..."
    begin
      Apartment::Tenant.switch!(tenant_name)

      admin = User.find_or_create_by!(email: admin_email) do |user|
        user.password = admin_password
        user.password_confirmation = admin_password
        user.name = "Admin #{tenant_name.capitalize}"
        user.role = :admin
      end
      puts "✅ Usuario creado: #{admin.email}"
    ensure
      Apartment::Tenant.reset
    end

    # Step 4: Create default company
    puts "4️⃣ Creando empresa por defecto..."
    begin
      Apartment::Tenant.switch!(tenant_name)

      company = Company.find_or_create_by!(nit: "000.000.000-0") do |c|
        c.name = "#{tenant_name.capitalize} Corporation"
        c.address = "Tenant: #{tenant_name}"
      end
      puts "✅ Empresa creada: #{company.name}"

      # Link admin to company
      admin = User.find_by(email: admin_email)
      CompanyManager.find_or_create_by(user: admin, company: company)
      puts "✅ Admin vinculado a empresa"
    ensure
      Apartment::Tenant.reset
    end

    # Success summary
    puts ""
    puts "=" * 70
    puts "✅ Tenant '#{tenant_name}' creado exitosamente!"
    puts "=" * 70
    puts ""
    puts "📝 Información del Tenant:"
    puts "   Nombre: #{tenant_name}"
    puts "   Schema: #{tenant_name}"
    puts "   Admin Email: #{admin_email}"
    puts "   Admin Password: #{admin_password}"
    puts ""
    puts "🌐 Acceso local:"
    puts "   http://#{tenant_name}.localhost:3000"
    puts ""
    puts "⚠️  IMPORTANTE: Cambia la contraseña del admin en producción"
    puts "=" * 70
  end
end
